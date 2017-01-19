module Contentful
  # A Locale definition as included in Space
  # Read more about Localization at https://www.contentful.com/developers/documentation/content-delivery-api/#i18n
  class Locale
    attr_reader :code, :name, :default

    def initialize(json)
      @code = json.fetch('code', nil)
      @name = json.fetch('name', nil)
      @default = json.fetch('default', false)
    end
  end
end
