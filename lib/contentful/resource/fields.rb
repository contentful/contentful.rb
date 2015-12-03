require 'contentful/constants'

module Contentful
  module Resource
    # Include this module into your Resource class to enable it
    # to deal with entry fields (but not asset fields)
    #
    # It depends on system properties being available
    module Fields
      # Returns all fields of the asset
      def fields(wanted_locale = default_locale)
        wanted_locale = wanted_locale.to_s
        @fields.has_key?(wanted_locale) ? @fields[wanted_locale] : @fields[locale]
      end

      # Returns all fields of the asset with locales nested by field
      def fields_with_locales
        remapped_fields = {}
        locales.each do |locale|
          fields(locale).each do |name, value|
            remapped_fields[name] ||= {}
            remapped_fields[name][locale.to_sym] = value
          end
        end

        remapped_fields
      end

      def initialize(object = nil, *)
        super
        extract_fields_from_object! object if object
      end

      def inspect(info = nil)
        if fields.empty?
          super(info)
        else
          super("#{info} @fields=#{fields.inspect}")
        end
      end

      private

      def locales
        @fields.keys
      end

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
