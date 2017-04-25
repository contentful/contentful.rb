require_relative 'base_resource'
require_relative 'array_like'

module Contentful
  # Resource Class for Arrays (e.g. search results)
  # @see _ https://www.contentful.com/developers/documentation/content-delivery-api/#arrays
  # @note It also provides an #each method and includes Ruby's Enumerable module (gives you methods like #min, #first, etc)
  class Array < BaseResource
    # @private
    DEFAULT_LIMIT = 100

    include Contentful::ArrayLike

    attr_reader :total, :limit, :skip, :items, :endpoint

    def initialize(item = nil,
                   default_locale = Contentful::Client::DEFAULT_CONFIGURATION[:default_locale],
                   endpoint = '', *)
      super(item, { default_locale: default_locale })

      @endpoint = endpoint
      @total = item.fetch('total', nil)
      @limit = item.fetch('limit', nil)
      @skip = item.fetch('skip', nil)
      @items = item.fetch('items', [])
    end

    # @private
    def marshal_dump
      super.merge(endpoint: endpoint)
    end

    # @private
    def marshal_load(raw_object)
      super
      @endpoint = raw_object[:endpoint]
      @total = raw.fetch('total', nil)
      @limit = raw.fetch('limit', nil)
      @skip = raw.fetch('skip', nil)
      @items = raw.fetch('items', [])
    end

    # @private
    def inspect
      "<#{repr_name} total=#{total} skip=#{skip} limit=#{limit}>"
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
