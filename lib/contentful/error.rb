module Contentful
  # All errors raised by the contentful gem are either instances of Contentful::Error
  # or inherit from Contentful::Error
  class Error < StandardError
    attr_reader :response

    def initialize(response)
      @response = response
      super best_available_message
    end

    # Shortcut for creating specialized error classes
    # USAGE rescue Contentful::Error[404]
    def self.[](error_status_code)
      errors = {
        400 => BadRequest,
        401 => Unauthorized,
        403 => AccessDenied,
        404 => NotFound,
        429 => RateLimitExceeded,
        500 => ServerError,
        502 => BadGateway,
        503 => ServiceUnavailable
      }

      errors.key?(error_status_code) ? errors[error_status_code] : Error
    end

    protected

    def default_error_message
      "The following error was received: #{@response.raw.body}"
    end

    def handle_details(details)
      details.to_s
    end

    def additional_info?
      false
    end

    def additional_info
      []
    end

    def best_available_message
      error_message = [
        "HTTP status code: #{@response.raw.status}"
      ]

      begin
        response_json = @response.load_json
        message = response_json.fetch('message', default_error_message)
        details = response_json.fetch('details', nil)
        request_id = response_json.fetch('requestId', nil)

        error_message << "Message: #{message}"
        error_message << "Details: #{handle_details(details)}" if details
        error_message << "Request ID: #{request_id}" if request_id
      rescue
        error_message << "Message: #{default_error_message}"
      end

      error_message << additional_info if additional_info?

      error_message.join("\n")
    end
  end

  # 400
  class BadRequest < Error
    protected

    def default_error_message
      'The request was malformed or missing a required parameter.'
    end

    def handle_details(details)
      return details if details.is_a?(String)

      handle_detail = proc do |detail|
        return detail if detail.is_a?(String)
        detail.fetch('details', nil)
      end

      inner_details = details['errors'].map { |detail| handle_detail[detail] }.reject(&:nil?)
      inner_details.join("\n\t")
    end
  end

  # 401
  class Unauthorized < Error
    protected

    def default_error_message
      'The authorization token was invalid.'
    end
  end

  # 403
  class AccessDenied < Error
    protected

    def default_error_message
      'The specified token does not have access to the requested resource.'
    end

    def handle_details(details)
      "\n\tReasons:\n\t\t#{details['reasons'].join("\n\t\t")}"
    end
  end

  # 404
  class NotFound < Error
    protected

    def default_error_message
      'The requested resource or endpoint could not be found.'
    end

    def handle_details(details)
      return details if details.is_a?(String)

      type = details['type'] || (details['sys'] || {})['type']
      message = "The requested #{type} could not be found."

      resource_id = details.fetch('id', nil)
      message += " ID: #{resource_id}." if resource_id

      message
    end
  end

  # 429
  class RateLimitExceeded < Error
    # Rate Limit Reset Header Key
    RATE_LIMIT_RESET_HEADER_KEY = 'x-contentful-ratelimit-reset'

    def reset_time?
      # rubocop:disable Style/DoubleNegation
      !!reset_time
      # rubocop:enable Style/DoubleNegation
    end

    # Time until next available request, in seconds.
    def reset_time
      @reset_time ||= @response.raw[RATE_LIMIT_RESET_HEADER_KEY]
    end

    protected

    def additional_info?
      reset_time?
    end

    def additional_info
      ["Time until reset (seconds): #{reset_time}"]
    end

    def default_error_message
      'Rate limit exceeded. Too many requests.'
    end
  end

  # 500
  class ServerError < Error
    protected

    def default_error_message
      'Internal server error.'
    end
  end

  # 502
  class BadGateway < Error
    protected

    def default_error_message
      'The requested space is hibernated.'
    end
  end

  # 503
  class ServiceUnavailable < Error
    protected

    def default_error_message
      'The request was malformed or missing a required parameter.'
    end
  end

  # Raised when response is no valid json
  class UnparsableJson < Error
    protected

    def default_error_message
      @response.error_message
    end
  end

  # Raised when response is not parsable as a Contentful::Resource
  class UnparsableResource < StandardError; end
end
