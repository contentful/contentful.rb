module Contentful
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
        self
      end
    end
  end


  class NotFound < Error; end
  class BadRequest < Error; end
  class AccessDenied < Error; end
  class Unauthorized < Error; end
  class ServerError < Error; end

  class UnparsableJson < Error; end
  class UnparsableResource < Error; end
end