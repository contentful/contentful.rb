require_relative 'resource'

module Contentful
  # Resource Class for Arrays (e.g. search results)
  # https://www.contentful.com/developers/documentation/content-delivery-api/#arrays
  # It also provides an #each method and includes Ruby's Enumerable module (gives you methods like #min, #first, etc)
  class Array
    DEFAULT_LIMIT = 100

    include Contentful::Resource
    include Contentful::Resource::SystemProperties
    include Enumerable

    property :total, :integer
    property :limit, :integer
    property :skip, :integer
    property :items

    # Only returns true for Contentful::Array
    def array?
      true
    end

    # Simplifies pagination
    def next_page
      if request
        new_skip    = (skip || 0) + (limit || DEFAULT_LIMIT)
        new_request = request.copy
        new_request.query[:skip] = new_skip
        new_request.get
      else
        false
      end
    end

    # Delegates to items#each
    def each(&block)
      items.each(&block)
    end

    # Delegates to items#empty?
    def empty?
      items.empty?
    end
  end
end
