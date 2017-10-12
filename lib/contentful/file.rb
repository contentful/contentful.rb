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
        define_singleton_method Support.snakify(k, @configuration[:use_camel_case]) do
          v
        end
      end
    end
  end
end
