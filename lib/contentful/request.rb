module Contentful
  # This object represents a request that is to be made. It gets initialized by the client
  # with domain specific logic. The client later uses the Request's #url and #query methods
  # to execute the HTTP request.
  class Request
    attr_reader :client, :type, :query, :id, :endpoint

    def initialize(client, endpoint, query = {}, id = nil)
      @client = client
      @endpoint = endpoint

      @query = (normalize_query(query) if query && !query.empty?)

      if id
        @type = :single
        @id = URI.escape(id)
      else
        @type = :multi
        @id = nil
      end
    end

    # Returns the final URL, relative to a contentful space
    def url
      "#{@endpoint}#{@type == :single ? "/#{id}" : ''}"
    end

    # Delegates the actual HTTP work to the client
    def get
      client.get(self)
    end

    # Returns true if endpoint is an absolute url
    def absolute?
      @endpoint.start_with?('http')
    end

    # Returns a new Request object with the same data
    def copy
      Marshal.load(Marshal.dump(self))
    end

    private

    def normalize_query(query)
      Hash[
        query.map do |key, value|
          [
            key.to_sym,
            value.is_a?(::Array) ? value.join(',') : value
          ]
        end
      ]
    end
  end
end
