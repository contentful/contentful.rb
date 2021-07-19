require_relative 'base_resource'
require_relative 'array_like'
require_relative 'includes'

module Contentful
  # Resource Class for Arrays (e.g. search results)
  # @see _ https://www.contentful.com/developers/documentation/content-delivery-api/#arrays
  # @note It also provides an #each method and includes Ruby's Enumerable module (gives you methods like #min, #first, etc)
  class Array < BaseResource
    # @private
    DEFAULT_LIMIT = 100

    include Contentful::ArrayLike

    attr_reader :total, :limit, :skip, :items, :endpoint, :query

    def initialize(item = nil,
                   configuration = {
                     default_locale: Contentful::Client::DEFAULT_CONFIGURATION[:default_locale]
                   },
                   endpoint = '',
                   query = {},
                   *)
      super(item, configuration)

      @endpoint = endpoint
      @total = item.fetch('total', nil)
      @limit = item.fetch('limit', nil)
      @skip = item.fetch('skip', nil)
      @items = item.fetch('items', [])
      @query = query
    end

    # @private
    def marshal_dump
      super.merge(endpoint: endpoint, query: query)
    end

    # @private
    def marshal_load(raw_object)
      super
      @endpoint = raw_object[:endpoint]
      @total = raw.fetch('total', nil)
      @limit = raw.fetch('limit', nil)
      @skip = raw.fetch('skip', nil)
      @query = raw_object[:query]
      @items = raw.fetch('items', []).map do |item|
        require_relative 'resource_builder'
        ResourceBuilder.new(
          item.raw,
          raw_object[:configuration].merge(includes_for_single: Includes.from_response(raw, false)),
          item.respond_to?(:localized) ? item.localized : false,
          0,
          raw_object[:configuration][:errors] || []
        ).run
      end
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
      return false if items.first.nil?

      new_skip = (skip || 0) + (limit || DEFAULT_LIMIT)

      plurals = {
        'Space' => 'spaces',
        'ContentType' => 'content_types',
        'Entry' => 'entries',
        'Asset' => 'assets',
        'Locale' => 'locales'
      }

      client.public_send(plurals[items.first.type], query.merge(limit: limit, skip: new_skip))
    end
  end
end
