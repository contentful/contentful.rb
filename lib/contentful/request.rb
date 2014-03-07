module Contentful
  # This object represents a request that is to be made
  # The client uses it's #url and #client method to build the final url
  # The actual request is made by the client object
  class Request
    attr_reader :client, :type, :query, :id

    def initialize(client, endpoint, query = {}, id = nil, response_class = nil)
      @client = client
      @endpoint = endpoint
      @query = !query || query.empty? ? nil : query
      @response_class = response_class

      if id
        @type = :single
        @id = URI.escape(id)
      else
        @type = :multi
        @id = nil
      end
    end

    def url
      "#{@endpoint}#{ @type == :single ? "/#{id}" : '' }"
    end

    def get
      client.get(self)
    end
  end
end
