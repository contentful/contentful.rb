module Contentful
  class Request
    attr_reader :client, :type, :id, :query

    # TODO no query_or_id magic
    def initialize(client, endpoint, query_or_id = {}, response_class = nil)
      @client = client
      @endpoint = endpoint
      @response_class = response_class

      if query_or_id.is_a?(String)
        @type = :single
        @query = nil
        @id = URI.escape(query_or_id)
      else
        @type = :multi
        @query = query_or_id.empty? ? nil : query_or_id
        @id = nil
      end
    end

    def url
      "#{@endpoint}/#{ @type == :single ? id : '' }"
    end

    def get
      client.get(self)
    end
  end
end
