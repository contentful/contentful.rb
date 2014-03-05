require_relative 'resource'

module Contentful
  class Link
    include Contentful::Resource
    include Contentful::Resource::SystemProperties

    def resolve(query = {})
      id_and_query = [(id unless link_type == "Space")].compact + [query]
      client.public_send(
        Contentful::Support.snakify(link_type).to_sym,
        *id_and_query
      )
    end
  end
end