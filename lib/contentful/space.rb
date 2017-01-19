require_relative 'base_resource'
require_relative 'locale'

module Contentful
  # Resource class for Space.
  # https://www.contentful.com/developers/documentation/content-delivery-api/#spaces
  class Space < BaseResource
    attr_reader :name, :locales

    def initialize(item, *)
      super

      @name = item.fetch('name', nil)
      @locales = item.fetch('locales', []).map { |locale| Locale.new(locale) }
    end

    # @private
    def reload(client = nil)
      return client.space unless client.nil?

      false
    end
  end
end
