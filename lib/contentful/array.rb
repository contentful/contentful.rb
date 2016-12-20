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

    attr_reader :endpoint

    def initialize(object = nil,
                   default_locale = Contentful::Client::DEFAULT_CONFIGURATION[:default_locale],
                   endpoint = '')
      super(object, default_locale)
      @endpoint = endpoint
    end

    # Simplifies pagination
    #
    # @return [Contentful::Array, false]
    def next_page(client = nil)
      return false if client.nil?

      new_skip = (skip || 0) + (limit || DEFAULT_LIMIT)
      client.send(endpoint.delete('/'), limit: limit, skip: new_skip)
    end
  end
end
