module Contentful
  # This object represents a request that is to be made. It gets initialized by the client
  # with domain specific logic. The client later uses the Request's #url and #query methods
  # to execute the HTTP request.
  class Request
    attr_reader :client, :type, :query, :id

    def initialize(client, endpoint, query = {}, id = nil)
      @client = client
      @endpoint = endpoint
      @query = !query || query.empty? ? nil : Support.symbolize_keys(query)

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
      "#{@endpoint}#{ @type == :single ? "/#{id}" : '' }"
    end

    # Delegates the actual HTTP work to the client
    def get
      client.get(self)
    end

    # Returns a new Request object with the same data
    def copy
      Marshal.load(Marshal.dump(self))
    end
  end
end
