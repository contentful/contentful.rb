module Contentful
  module Resource
    module Fields
      attr_reader :fields

      # Include this module into your resource class to enable it
      # to deal with fields
      # TODO coercions
      def initialize(object, *)
        super
        @fields = extract_from_object object["fields"], :fields
      end

      def inspect(info = nil)
        super(
          "#{info} @fields=#{fields.inspect}"
        )
      end

      module ClassMethods
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