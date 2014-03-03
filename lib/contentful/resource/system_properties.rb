module Contentful
  module Resource

    # Include this module into your resource class to add "sys" property accessors
    module SystemProperties
      attr_reader :sys

      def initialize(object)
        super
        @sys = extract_from_object object["sys"] && object["sys"].keys, object["sys"]
      end

      def type
        @sys[:type]
      end

      def id
        @sys[:id]
      end

      def space
        @sys[:space]
      end

      def content_type
        @sys[:contentType]
      end

      def link_type
        @sys[:linkType]
      end

      def revision
        @sys[:revision]
      end

      def created_at
        @sys[:createdAt]
      end

      def updated_at
        @sys[:updatedAt]
      end

      def locale
        @sys[:locale]
      end

      def inspect(info = nil)
        super(
          "#{info} @sys=#{sys.inspect}"
        )
      end
    end
  end
end