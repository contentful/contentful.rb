require_relative 'error'

require 'multi_json'


module Contentful
  class Response
    attr_reader :raw, :object, :status, :error_message


    def initialize(raw)
      @raw = raw
      @status = :ok
      @error_message = false

      if parse_json!
        parse_contentful_error!
      end
    end


    private

    def parse_json!
      @object = MultiJson.load(raw.to_s)
      true
    rescue MultiJson::LoadError => e
      @status = :unparsable_json
      @error_message = e.message
      @object = e
      false
    end

    def parse_contentful_error!
      if object && object["sys"] && object["sys"]["type"] == 'Error'
        @status = :contentful_error
        @error_message = object['message']
        true
      else
        false
      end
    end

  end
end