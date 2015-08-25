module Contentful
  module Resource
    # Include this module into your Resource class to enable it
    # to deal with entry fields (but not asset fields)
    #
    # It depends on system properties being available
    module Fields
      # Returns all fields of the asset
      def fields(wanted_locale = default_locale)
        @fields[locale || wanted_locale]
      end

      def initialize(object, *)
        super
        extract_fields_from_object! object
      end

      def inspect(info = nil)
        if fields.empty?
          super(info)
        else
          super("#{info} @fields=#{fields.inspect}")
        end
      end

      private

      def extract_fields_from_object!(object)
        initialize_fields_for_localized_resource(object)
      end

      module ClassMethods
        # No coercions, since no content type available
        def fields_coercions
          {}
        end
      end

      def self.included(base)
        base.extend(ClassMethods)
      end
    end
  end
end
