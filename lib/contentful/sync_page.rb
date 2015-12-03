require_relative 'resource'
require_relative 'resource/array_like'

module Contentful
  class SyncPage
    attr_reader :sync

    include Contentful::Resource
    include Contentful::Resource::SystemProperties
    include Contentful::Resource::ArrayLike

    property :items
    property :nextSyncUrl
    property :nextPageUrl

    def next_page
      sync.get(next_page_url) if next_page?
    end

    def next_page?
      !!next_page_url
    end

    def last_page?
      !next_page_url
    end
  end
end
