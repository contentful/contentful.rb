require_relative 'base_resource'

module Contentful
  # Resource Class for Links
  # https://www.contentful.com/developers/documentation/content-delivery-api/#links
  class Link < BaseResource
    # Queries contentful for the Resource the Link is refering to
    # Takes an optional query hash
    def resolve(client, query = {})
      id_and_query = [(id unless link_type == 'Space')].compact + [query]
      client.public_send(
        Contentful::Support.snakify(link_type).to_sym,
        *id_and_query
      )
    end
  end
end
