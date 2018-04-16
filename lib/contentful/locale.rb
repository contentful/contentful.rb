require_relative 'base_resource'

module Contentful
  # A Locale definition as included in Space
  # Read more about Localization at https://www.contentful.com/developers/documentation/content-delivery-api/#i18n
  class Locale < BaseResource
    attr_reader :code, :name, :default, :fallback_code

    def initialize(item, *)
      @code = item.fetch('code', nil)
      @name = item.fetch('name', nil)
      @default = item.fetch('default', false)
      @fallback_code = item.fetch('fallbackCode', nil)
    end
  end
end
