module Contentful
  # An Assets's file info
  class File
    def initialize(json, configuration)
      @configuration = configuration

      define_fields!(json)
    end

    private

    def define_fields!(json)
      json.each do |k, v|
        method_name = @configuration[:use_camel_case] ? k : Support.snakify(k)
        define_singleton_method method_name do
          v
        end
      end
    end
  end
end
