require_relative '../file'

module Contentful
  module Resource
    # Special fields for Asset. Don't include together wit Contentful::Resource::Fields
    #
    # It depends on system properties being available
    module AssetFields
      FIELDS_COERCIONS = {
        title: :string,
        description: :string,
        file: File
      }

      # Returns all fields of the asset
      def fields(wanted_locale = default_locale)
        @fields[locale || wanted_locale]
      end

      def initialize(object, *)
        super
        @fields = {}

        if nested_locale_fields?
          object['fields'].each do |field_name, nested_child_object|
            nested_child_object.each do |object_locale, real_child_object|
              @fields[object_locale] ||= {}
              @fields[object_locale].merge! extract_from_object(
                { field_name => real_child_object }, :fields
              )
            end
          end
        else
          @fields[locale] = extract_from_object object['fields'], :fields
        end
      end

      def inspect(info = nil)
        if fields.empty?
          super(info)
        else
          super("#{info} @fields=#{fields.inspect}")
        end
      end

      module ClassMethods
        def fields_coercions
          FIELDS_COERCIONS
        end
      end

      def self.included(base)
        base.extend(ClassMethods)

        base.fields_coercions.keys.each do |name|
          base.send :define_method, Contentful::Support.snakify(name) do
            fields[name.to_sym]
          end
        end
      end
    end
  end
end
