module Contentful

  # Method to retrieve references (incoming links) for a given entry or asset
  module ResourceReferences

    # Gets a collection of entries which links to current entry
    #
    # @param [Contentful::Client] client
    # @param [Hash] query
    #
    # @return [Contentful::Array<Contentful::Entry>, false]
    def getReferences(client = nil, query = {})
      return false unless client

      if self.is_a? Contentful::Entry
        query = query.merge links_to_entry: self.id
      else
        query = query.merge links_to_asset: self.id
      end
      client.entries query

    end
  end
end
