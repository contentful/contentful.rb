module Contentful
  class Request
    attr_reader :client, :endpoint, :type, :id, :options

    def initialize(client, endpoint, options_or_id = {}, response_class = nil)
      @client = client
      @endpoint = endpoint
      @response_class = response_class
      if options_or_id.is_a?(String)
        @type = :single
        @id = URI.escape(options_or_id)
      else
        @type = :array
        @options = options_or_id
      end
    end

    def query
    end

    def url
      "#{endpoint}/#{ type == :single ? id : '' }"
    end

    def get
      client.get(self)
    end
  end
end
