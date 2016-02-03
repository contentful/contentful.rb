module Contentful
  module Resource
    # Adds the feature to have system properties to a Resource.
    module SystemProperties
      # @private
      # Coercions for System Properties to native types
      SYS_COERCIONS = {
        type: :string,
        id: :string,
        space: nil,
        contentType: nil,
        linkType: :string,
        revision: :integer,
        createdAt: :date,
        updatedAt: :date,
        locale: :string
      }
      attr_reader :sys

      # @private
      def initialize(object = nil, *)
        super
        @sys = object ? extract_from_object(object['sys'], :sys) : {}
      end

      # @private
      def inspect(info = nil)
        if sys.empty?
          super(info)
        else
          super("#{info} @sys=#{sys.inspect}")
        end
      end

      # @private
      module ClassMethods
        # @private
        def sys_coercions
          SYS_COERCIONS
        end
      end

      # @private
      def self.included(base)
        base.extend(ClassMethods)

        base.sys_coercions.keys.each do |name|
          base.send :define_method, Contentful::Support.snakify(name) do
            sys[name.to_sym]
          end
        end
      end
    end
  end
end
