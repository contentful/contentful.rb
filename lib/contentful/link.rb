require_relative 'resource'

module Contentful
  class Link
    include Contentful::Resource
    include Contentful::Resource::SystemProperties

    def resolve(query = nil)
      # TODO add query after request refact
      client.public_send(
        Contentful::Support.client_method_for_type(link_type),
        *[(id unless link_type == "Space")].compact
      )
    end
  end
end