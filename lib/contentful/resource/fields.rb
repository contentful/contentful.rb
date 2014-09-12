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
