module Contentful
  # All errors raised by the contentful gem are either instances of Contentful::Error
  # or inherit from Contentful::Error
  class Error < StandardError
    attr_reader :response

    def initialize(response)
      @response = response
      super @response.error_message
    end

    # Shortcut for creating specialized error classes
    # USAGE rescue Contentful::Error[404]
    def self.[](no)
      case no
      when 404
        NotFound
      when 400
        BadRequest
      when 403
        AccessDenied
      when 401
        Unauthorized
      when 500
        ServerError
      else
        Error
      end
    end
  end

  # 404
  class NotFound < Error; end

  # 400
  class BadRequest < Error; end

  # 403
  class AccessDenied < Error; end

  # 401
  class Unauthorized < Error; end

  # 500
  class ServerError < Error; end

  # Raised when response is no valid json
  class UnparsableJson < Error; end

  # Raised when response is not parsable as a Contentful::Resource
  class UnparsableResource < Error; end
end