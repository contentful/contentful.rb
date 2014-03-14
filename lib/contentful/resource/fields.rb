module Contentful
  module Resource
    # Include this module into your Resource class to enable it
    # to deal with entry fields (but not asset fields)
    #
    # It depends on system properties being available
    module Fields
      # Returns all fields of the asset
      def fields
        @fields[locale]
      end

      def initialize(object, *)
        super
        @fields = {}
        @fields[locale] = extract_from_object object["fields"], :fields
      end

      def inspect(info = nil)
        if fields.empty?
          super(info)
        else
          super("#{info} @fields=#{fields.inspect}")
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
