require_relative 'error'
require 'multi_json'

module Contentful
  # An object representing an answer by the contentful service. It is later used
  # to build a Resource, done by the ResourceBuilder
  #
  # It parses the #raw response (as returned by the underlying http library) to
  # a JSON #object.
  #
  # It also sets a #status which can be one of:
  # - :ok (seems to be a valid resource object)
  # - :contentful_error (valid error object)
  # - :not_contentful (valid json, but missing the contentful's sys property)
  # - :unparsable_json (invalid json)
  class Response
    attr_reader :raw, :object, :status, :error_id, :error_message

    def initialize(raw)
      @raw = raw
      @status = :ok
      @error_code = nil
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
      if @object && @object["sys"]
        if @object["sys"]["type"] == 'Error'
          @status = :contentful_error
          @error_message = object['message']
          @error_id = object["sys"]["id"]
          true
        else
          false
        end
      else
        @status = :not_contentful
        @error_message = "No contentful system properties found in object"
      end
    end

  end
end