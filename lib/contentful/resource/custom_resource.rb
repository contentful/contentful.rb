module Contentful
  module Resource
    module CustomResource
      def initialize(*)
        super

        update_mappings!
      end

      def update_mappings!
        properties.keys.each do |name|
          define_singleton_method Contentful::Support.snakify(name).to_sym do |wanted_locale = default_locale|
            properties[name] ||= fields(wanted_locale)[name]
          end
        end
      end

      def marshal_load(raw_object)
        super raw_object
        update_mappings!
      end
    end
  end
end
