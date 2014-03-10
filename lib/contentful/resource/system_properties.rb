module Contentful
  module Resource
    # Adds the feature to have system properties to a Resource.
    module SystemProperties
      attr_reader :sys

      SYS_COERCIONS = {
        type: :string,
        id: :string,
        space: nil,
        contentType: nil,
        linkType: :string,
        revision: :integer,
        createdAt: :date,
        updatedAt: :date,
        locale: :string,
      }

      def initialize(object, *)
        super
        @sys = extract_from_object object["sys"], :sys
      end

      def inspect(info = nil)
        if sys.empty?
          super(info)
        else
          super("#{info} @sys=#{sys.inspect}")
        end
      end

      module ClassMethods
        def sys_coercions
          SYS_COERCIONS
        end
      end

      def self.included(base)
        base.extend(ClassMethods)

        base.sys_coercions.keys.each{ |name|
          base.send :define_method, Contentful::Support.snakify(name) do
            sys[name.to_sym]
          end
        }
      end
    end
  end
end
