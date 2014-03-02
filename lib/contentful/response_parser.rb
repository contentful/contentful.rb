require_relative 'error'


module Contentful
  class ResponseParser
    attr_reader :response

    def initialize(given_response)
      @response = given_response
    end

    def parse
      if response.status == :contentful_error
        Error[response.raw.response.status].new(response)
      elsif response.status == :unparsable_json
        UnparsableJson.new(response)
      else
        Object.new
      end
    end
  end
end