require_relative 'resource/system_properties'

module Contentful
  # Include this module to tranform a class into a contentful resource.
  # It
  module Resource
    COERCIONS = {
      string:  ->(v){ v.to_s },
      integer: ->(v){ v.to_i },
      boolean: ->(v){ !!v },
      date: ->(v){ DateTime.parse(v) },
    }

    attr_reader :properties, :client

    def initialize(object, client = nil)
      @properties = extract_from_object object, :property, self.class.property_coercions.keys
      @client = client
    end

    def inspect(info = nil)
      "#<#{self.class}:#{object_id} @properties=#{properties.inspect}#{info}>"
    end

    def array?
      false
    end

    def sys
      nil
    end

    def fields
      nil
    end


    private

    def extract_from_object(object, namespace, keys = nil)
      if object
        keys ||= object.keys
        keys.each.with_object({}){ |name, res|
          res[name.to_sym] = coerce_value_or_array(
            object.is_a?(::Array) ? object : object[name.to_s],
            self.class.public_send(:"#{namespace}_coercions")[name.to_sym],
          )
        }
      else
        {}
      end
    end

    def coerce_value_or_array(value, what = nil)
      if value.is_a? ::Array
        value.map{ |v| coerce_or_create_class(v, what) }
      else
        coerce_or_create_class(value, what)
      end
    end

    def coerce_or_create_class(value, what)
      case what
      when Symbol
        COERCIONS[what] ? COERCIONS[what][value] : value
      when Class
        what.new(value, client)
      else
        value
      end
    end

    # Register the resources properties on class level by using the #property method
    module ClassMethods
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
    end

    def self.included(base)
      base.extend(ClassMethods)
    end
  end
end
