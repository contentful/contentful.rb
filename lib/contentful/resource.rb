require_relative 'resource/system_properties'
require 'contentful/constants'
require 'date'

module Contentful
  # Include this module to declare a class to be a contentful resource.
  # This is done by the default in the existing resource classes
  #
  # You can define your own classes that behave like contentful resources:
  # See examples/custom_classes.rb to see how.
  #
  # Take a look at examples/resource_mapping.rb on how to register them to be returned
  # by the client by default
  #
  # @see _ examples/custom_classes.rb Custom Class as Resource
  # @see _ examples/resource_mapping.rb Mapping a Custom Class
  module Resource
    # @private
    # rubocop:disable Style/DoubleNegation
    COERCIONS = {
      string:  ->(v) { v.nil? ? nil : v.to_s },
      integer: ->(v) { v.to_i },
      float:   ->(v) { v.to_f },
      boolean: ->(v) { !!v },
      date:    ->(v) { DateTime.parse(v) }
    }
    # rubocop:enable Style/DoubleNegation

    attr_reader :properties, :request, :client, :default_locale, :raw

    # @private
    def initialize(object = nil,
                   request = nil,
                   client = nil,
                   default_locale = Contentful::Client::DEFAULT_CONFIGURATION[:default_locale])
      self.class.update_coercions!
      @default_locale = default_locale

      @properties = {}
      self.class.property_coercions.keys.each do |property_name|
        @properties[property_name] = nil
      end

      @properties = @properties.merge(
        extract_from_object(object, :property,
                            self.class.property_coercions.keys)
      )
      @request = request
      @client = client
      @raw = object
    end

    # @private
    def inspect(info = nil)
      properties_info = properties.empty? ? '' : " @properties=#{properties.inspect}"
      "#<#{self.class}:#{properties_info}#{info}>"
    end

    # Returns true for resources that are entries
    def entry?
      false
    end

    # Returns true for resources that behave like an array
    def array?
      false
    end

    # Resources that don't include SystemProperties return nil for #sys
    def sys
      nil
    end

    # Resources that don't include Fields or AssetFields return nil for #fields
    def fields
      nil
    end

    # Issues the request that was made to fetch this response again.
    # Only works for top-level resources
    def reload
      if request
        request.get
      else
        false
      end
    end

    # Register the resources properties on class level by using the #property method
    # @private
    module ClassMethods
      # By default, fields come flattened in the current locale. This is different for sync
      def property_coercions
        @property_coercions ||= {}
      end

      # Defines which properties of a resource your class expects
      # Define them in :camelCase, they will be available as #snake_cased methods
      #
      # You can pass in a second "type" argument:
      # - If it is a class, it will be initialized for the property
      # - Symbols are looked up in the COERCION constant for a lambda that
      #   defines a type conversion to apply
      #
      # Note: This second argument is not meant for contentful sub-resources,
      # but for structured objects (like locales in a space)
      # Sub-resources are handled by the resource builder
      def property(name, property_class = nil)
        property_coercions[name.to_sym] = property_class
        define_method Contentful::Support.snakify(name) do
          properties[name.to_sym]
        end
      end

      # Ensure inherited classes pick up coercions
      def update_coercions!
        return if @coercions_updated

        if superclass.respond_to? :property_coercions
          @property_coercions = superclass.property_coercions.dup.merge(@property_coercions || {})
        end

        if superclass.respond_to? :sys_coercions
          @sys_coercions = superclass.sys_coercions.dup.merge(@sys_coercions || {})
        end

        if superclass.respond_to? :fields_coercions
          @fields_coercions = superclass.fields_coercions.dup.merge(@fields_coercions || {})
        end

        @coercions_updated = true
      end
    end

    # @private
    def self.included(base)
      base.extend(ClassMethods)
    end

    private

    def initialize_fields_for_localized_resource(object)
      @fields = {}

      object.fetch('fields', {}).each do |field_name, nested_child_object|
        if Support.localized?(nested_child_object)
          nested_child_object.each do |object_locale, real_child_object|
            @fields[object_locale] ||= {}
            @fields[object_locale].merge! extract_from_object(
              { field_name => real_child_object }, :fields
            )
          end
        else
          # if sys.locale property not present (due to select operator) use default_locale
          @fields[locale || default_locale] ||= {}
          @fields[locale || default_locale].merge! extract_from_object({ field_name => nested_child_object }, :fields)
        end
      end
    end

    def extract_from_object(object, namespace, keys = nil)
      if object
        keys ||= object.keys
        keys.each.with_object({}) do |name, res|
          value = object.is_a?(::Array) ? object : object[name.to_s]
          kind = self.class.public_send(:"#{namespace}_coercions")[name.to_sym]
          res[name.to_sym] = coerce_value_or_array(value, kind)
        end
      else
        {}
      end
    end

    def coerce_value_or_array(value, what = nil)
      if value.is_a? ::Array
        value.map { |v| coerce_or_create_class(v, what) }
      elsif should_coerce_hash?(value)
        ::Hash[value.map do |k, v|
          to_coerce = pre_coerce(v)
          coercion = v.is_a?(Numeric) ? v : coerce_or_create_class(to_coerce, what)
          [k.to_sym, coercion]
        end]
      else
        coerce_or_create_class(value, what)
      end
    end

    def pre_coerce(value)
      case value
      when Numeric, true, false, nil
        value
      when Hash
        result = {}
        value.each_key do |k|
          result[k.to_sym] = pre_coerce(value[k])
        end
        result
      when ::Array
        value.map { |e| pre_coerce(e) }
      else
        value.to_s
      end
    end

    def should_coerce_hash?(value)
      value.is_a?(::Hash) &&
        !is_a?(Asset) &&
        !is_a?(Field) &&
        !location?(value) &&
        !link?(value) &&
        !image?(value)
    end

    def location?(value)
      value.key?('lat') || value.key?('lon')
    end

    def link?(value)
      value.key?('sys') && value['sys']['type'] == 'Link'
    end

    def image?(value)
      value.key?('image')
    end

    def coerce_or_create_class(value, what)
      case what
      when Symbol
        COERCIONS[what] ? COERCIONS[what][value] : value
      when Proc
        what[value]
      when Class
        what.new(value, client) if value
      else
        value
      end
    end
  end
end
