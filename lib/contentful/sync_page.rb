require_relative 'resource'
require_relative 'resource/array_like'

module Contentful
  # Wrapper Class for Sync results
  class SyncPage
    attr_reader :sync

    include Contentful::Resource
    include Contentful::Resource::SystemProperties
    include Contentful::Resource::ArrayLike

    property :items
    property :nextSyncUrl
    property :nextPageUrl

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
