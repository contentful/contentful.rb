require_relative 'error'
require 'multi_json'
require 'zlib'

module Contentful
  # An object representing an answer by the contentful service. It is later used
  # to build a Resource, which is done by the ResourceBuilder.
  #
  # The Response parses the http response (as returned by the underlying http library) to
  # a JSON object. Responses can be asked the following methods:
  # - #raw (raw HTTP response by the HTTP library)
  # - #object (the parsed JSON object)
  # - #request (the request the response is refering to)
  #
  # It also sets a #status which can be one of:
  # - :ok (seems to be a valid resource object)
  # - :contentful_error (valid error object)
  # - :not_contentful (valid json, but missing the contentful's sys property)
  # - :unparsable_json (invalid json)
  #
  # Error Repsonses also contain a:
  # - :error_message
  class Response
    attr_reader :raw, :object, :status, :error_message, :request

    def initialize(raw, request = nil)
      @raw = raw
      @request = request
      @status = :ok

      if valid_http_response?
        parse_json!
      elsif no_content_response?
        @status = :no_content
      elsif invalid_response?
        parse_contentful_error
      elsif service_unavailable_response?
        service_unavailable_error
      else
        parse_http_error
      end
    end

    private

    def error_object?
      object['sys']['type'] == 'Error'
    end

    def parse_contentful_error
      @object = load_json
      @error_message = object['message'] if error_object?
      parse_http_error
    end

    def valid_http_response?
      [200, 201].include?(raw.status)
    end

    def service_unavailable_response?
      @raw.status == 503
    end

    def service_unavailable_error
      @status = :error
      @error_message = '503 - Service Unavailable'
      @object = Error[@raw.status].new(self)
    end

    def parse_http_error
      @status = :error
      @object = Error[raw.status].new(self)
    end

    def invalid_response?
      [400, 404].include?(raw.status)
    end

    def no_content_response?
      raw.to_s == '' && raw.status == 204
    end

    def parse_json!
      @object = load_json
    rescue MultiJson::LoadError => error
      @error_message = error.message
      @status = :error
      UnparsableJson.new(self)
    end

    def load_json
      MultiJson.load(unzip_response(raw))
    end

    def unzip_response(response)
      parsed_response = response.to_s
      if response.headers['Content-Encoding'].eql?('gzip')
        sio = StringIO.new(parsed_response)
        gz = Zlib::GzipReader.new(sio)
        gz.read
      else
        parsed_response
      end
    end
  end
end
