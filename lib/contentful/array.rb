require_relative 'resource'
require_relative 'resource/array_like'

module Contentful
  # Resource Class for Arrays (e.g. search results)
  # @see _ https://www.contentful.com/developers/documentation/content-delivery-api/#arrays
  # @note It also provides an #each method and includes Ruby's Enumerable module (gives you methods like #min, #first, etc)
  class Array
    # @private
    DEFAULT_LIMIT = 100

    include Contentful::Resource
    include Contentful::Resource::SystemProperties
    include Contentful::Resource::ArrayLike

    property :total, :integer
    property :limit, :integer
    property :skip, :integer
    property :items

    # Simplifies pagination
    #
    # @return [Contentful::Array, false]
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
  end
end
