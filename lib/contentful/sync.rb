require_relative 'resource_builder'
require_relative 'deleted_entry'
require_relative 'deleted_asset'
require_relative 'sync_page'

module Contentful
  class Sync
    attr_reader :next_sync_url

    def initialize(client, options_or_url)
      @client = client
      @next_sync_url = nil
      @first_page_options_or_url = options_or_url
    end

    # Iterates over all pages of the current sync
    # Please Keep in Mind: Iterating fires a new request for each page
    def each_page(&block)
      page = first_page
      block.call(page)

      until completed?
        page = page.next_page
        block.call(page)
      end
    end

    # Returns the first sync result page
    def first_page
      get(@first_page_options_or_url)
    end

    # Returns false as long as last sync page has not been reached
    def completed?
      !!next_sync_url
    end

    # Directly iterates over all resources that have changed
    def each_item(&block)
      each_page do |page|
        page.each_item do |item|
          block.call item
        end
      end
    end

    def get(options_or_url)
      if options_or_url.is_a? String
        page = Request.new(@client, options_or_url).get
      else
        page = Request.new(@client, '/sync', options_or_url).get
      end

      if @client.configuration[:raw_mode]
        return page
      end

      link_page_to_sync! page
      update_sync_state_from! page

      page
    end

    private

    def link_page_to_sync!(page)
      page.instance_variable_set :@sync, self
    end

    def update_sync_state_from!(page)
      @next_sync_url = page.next_sync_url
    end
  end
end
