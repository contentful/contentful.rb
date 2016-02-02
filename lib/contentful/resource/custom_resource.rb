module Contentful
  module Resource
    # Module for simplifying Custom Resource Creation
    # Allows auto-mapping of fields to properties and properties to fields
    module CustomResource
      # @private
      def initialize(*)
        super

        update_mappings!
      end

      # @private
      def update_mappings!
        properties.keys.each do |name|
          define_singleton_method Contentful::Support.snakify(name).to_sym do |wanted_locale = default_locale|
            properties[name] ||= fields(wanted_locale)[name]
          end
        end
      end

      # @private
      def marshal_load(raw_object)
        super raw_object
        update_mappings!
      end
    end
  end
end
