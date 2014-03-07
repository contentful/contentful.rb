require_relative 'resource'

module Contentful
  # Resource Class for Arrays (e.g. search results)
  # https://www.contentful.com/developers/documentation/content-delivery-api/#arrays
  # It also provides an #each method and includes Ruby's Enumerable module (gives you methods like #min, #first, etc)
  class Array
    include Contentful::Resource
    include Contentful::Resource::SystemProperties
    include Enumerable

    property :total, :integer
    property :limit, :integer
    property :skip, :integer
    property :items

    def array?
      true
    end

    def each(&block)
      items.each(&block)
    end

  end
end