require_relative 'resource_builder'
require_relative 'deleted_entry'
require_relative 'deleted_asset'
require_relative 'sync_page'

module Contentful
  # Resource class for Sync.
  # @see _ https://www.contentful.com/developers/docs/references/content-delivery-api/#/reference/synchronization
  class Sync
    attr_reader :next_sync_url

    def initialize(client, options_or_url)
      @client = client
      @next_sync_url = nil
      @first_page_options_or_url = options_or_url
    end

    # Iterates over all pages of the current sync
    #
    # @note Please Keep in Mind: Iterating fires a new request for each page
    #
    # @yield [Contentful::SyncPage]
    def each_page
      page = first_page
      yield page if block_given?

      until completed?
        page = page.next_page
        yield page if block_given?
      end
    end

    # Returns the first sync result page
    #
    # @return [Contentful::SyncPage]
    def first_page
      get(@first_page_options_or_url)
    end

    # Returns false as long as last sync page has not been reached
    #
    # @return [Boolean]
    def completed?
      # rubocop:disable Style/DoubleNegation
      !!next_sync_url
      # rubocop:enable Style/DoubleNegation
    end

    # Directly iterates over all resources that have changed
    #
    # @yield [Contentful::Entry, Contentful::Asset]
    def each_item(&block)
      each_page do |page|
        page.each_item(&block)
      end
    end

    # @private
    def get(options_or_url)
      page = fetch_page(options_or_url)

      return page if @client.configuration[:raw_mode]

      link_page_to_sync! page
      update_sync_state_from! page

      page
    end

    private

    def fetch_page(options_or_url)
      return Request.new(@client, options_or_url).get if options_or_url.is_a? String
      Request.new(@client, '/sync', options_or_url).get
    end

    def link_page_to_sync!(page)
      page.instance_variable_set :@sync, self
    end

    def update_sync_state_from!(page)
      @next_sync_url = page.next_sync_url
    end
  end
end
