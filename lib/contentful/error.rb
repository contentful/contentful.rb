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
    def self.[](error_status_code)
      case error_status_code
      when 404
        NotFound
      when 400
        BadRequest
      when 403
        AccessDenied
      when 401
        Unauthorized
      when 429
        RateLimitExceeded
      when 500
        ServerError
      when 503
        ServiceUnavailable
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

  # 429
  class RateLimitExceeded < Error; end

  # 500
  class ServerError < Error; end

  # 503
  class ServiceUnavailable < Error; end

  # Raised when response is no valid json
  class UnparsableJson < Error; end

  # Raised when response is not parsable as a Contentful::Resource
  class UnparsableResource < StandardError; end
end
