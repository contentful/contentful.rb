require 'contentful/constants'

module Contentful
  module Resource
    # Include this module into your Resource class to enable it
    # to deal with entry fields (but not asset fields)
    #
    # It depends on system properties being available
    module Fields
      # Returns all fields of the asset
      #
      # @return [Hash] fields for Resource on selected locale
      def fields(wanted_locale = nil)
        wanted_locale = (locale || default_locale) if wanted_locale.nil?
        @fields[wanted_locale.to_s] || {}
      end

      # Returns all fields of the asset with locales nested by field
      #
      # @return [Hash] fields for Resource grouped by field name
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

      # @private
      module ClassMethods
        # No coercions, since no content type available
        def fields_coercions
          {}
        end
      end

      # @private
      def self.included(base)
        base.extend(ClassMethods)
      end

      # @private
      def initialize(object = nil, *)
        super
        extract_fields_from_object! object if object
      end

      # @private
      def inspect(info = nil)
        if fields.empty?
          super(info)
        else
          super("#{info} @fields=#{fields.inspect}")
        end
      end

      # Provides a list of the available locales for a Resource
      def locales
        @fields.keys
      end

      private

      def extract_fields_from_object!(object)
        initialize_fields_for_localized_resource(object)
      end
    end
  end
end
