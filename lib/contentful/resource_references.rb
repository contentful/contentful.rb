module Contentful
  # Method to retrieve references (incoming links) for a given entry or asset
  module ResourceReferences
    # Gets a collection of entries which links to current entry
    #
    # @param [Contentful::Client] client
    # @param [Hash] query
    #
    # @return [Contentful::Array<Contentful::Entry>, false]
    def incoming_references(client = nil, query = {})
      return false unless client

      query = is_a?(Contentful::Entry) ? query.merge(links_to_entry: id) : query.merge(links_to_asset: id)

      client.entries(query)
    end
  end
end
