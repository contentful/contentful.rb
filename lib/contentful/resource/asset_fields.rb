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
        file: File,
      }

      def fields
        @fields[locale]
      end

      def initialize(object, *)
        super
        @fields = {}
        @fields[locale] = extract_from_object object['fields'], :fields
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

        base.fields_coercions.keys.each{ |name|
          base.send :define_method, Contentful::Support.snakify(name) do
            fields[name.to_sym]
          end
        }
      end
    end
  end
end
