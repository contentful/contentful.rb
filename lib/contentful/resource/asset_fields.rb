require_relative '../file'

module Contentful
  module Resource
    # Special fields for Asset. Don't include together wit Contentful::Resource::Fields
    #
    # It depends on system properties being available
    module AssetFields
      # Special field coercions for Asset.
      FIELDS_COERCIONS = {
        title: :string,
        description: :string,
        file: File
      }

      # Returns all fields of the asset
      #
      # @return [Hash] localized fields
      def fields(wanted_locale = default_locale)
        @fields[locale || wanted_locale] || {}
      end

      # @private
      def initialize(object, *)
        super

        initialize_fields_for_localized_resource(object)
      end

      # @private
      def inspect(info = nil)
        if fields.empty?
          super(info)
        else
          super("#{info} @fields=#{fields.inspect}")
        end
      end

      # @private
      module ClassMethods
        def fields_coercions
          FIELDS_COERCIONS
        end
      end

      # @private
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
