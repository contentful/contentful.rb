module Contentful
  module Resource

    # Include this module into your resource class to add "sys" property accessors
    # TODO coercions
    module SystemProperties
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
      attr_reader :sys

      def initialize(object)
        super
        @sys = extract_from_object object["sys"], :sys
      end


      def inspect(info = nil)
        super(
          "#{info} @sys=#{sys.inspect}"
        )
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
