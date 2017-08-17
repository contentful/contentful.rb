require_relative 'base_resource'
require_relative 'array_like'

module Contentful
  # Wrapper Class for Sync results
  class SyncPage < BaseResource
    include Contentful::ArrayLike

    attr_reader :sync, :items, :next_sync_url, :next_page_url

    def initialize(item,
                   configuration = {
                     default_locale: Contentful::Client::DEFAULT_CONFIGURATION[:default_locale]
                   }, *)
      super(item, configuration, true)

      @items = item.fetch('items', [])
      @next_sync_url = item.fetch('nextSyncUrl', nil)
      @next_page_url = item.fetch('nextPageUrl', nil)
    end

    # @private
    def inspect
      "<#{repr_name} next_sync_url='#{next_sync_url}' last_page=#{last_page?}>"
    end

    # Requests next sync page from API
    #
    # @return [Contentful::SyncPage, void]
    def next_page
      sync.get(next_page_url) if next_page?
    end

    # Returns wether there is a next sync page
    #
    # @return [Boolean]
    def next_page?
      # rubocop:disable Style/DoubleNegation
      !!next_page_url
      # rubocop:enable Style/DoubleNegation
    end

    # Returns wether it is the last sync page
    #
    # @return [Boolean]
    def last_page?
      !next_page_url
    end
  end
end
