module Contentful
  module Resource
    module Fields
      attr_reader :fields

      # Include this module into your resource class to enable it
      # to deal with fields
      def initialize(object)
        super
        @fields = extract_from_object object["fields"].keys, object["fields"]
      end

      def inspect(info = nil)
        super(
          "#{info} @fields=#{fields.inspect}"
        )
      end

    end
  end
end