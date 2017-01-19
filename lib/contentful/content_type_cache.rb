module Contentful
  # Cache for Content Types
  class ContentTypeCache
    @cache = {}

    class << self
      attr_reader :cache
    end

    # Clears the Content Type Cache
    def self.clear!
      @cache = {}
    end

    # Gets a Content Type from the Cache
    def self.cache_get(space_id, content_type_id)
      @cache.fetch(space_id, {}).fetch(content_type_id.to_sym, nil)
    end

    # Sets a Content Type in the Cache
    def self.cache_set(space_id, content_type_id, klass)
      @cache[space_id] ||= {}
      @cache[space_id][content_type_id.to_sym] = klass
    end
  end
end
