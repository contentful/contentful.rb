require_relative 'resource'

module Contentful
  # A Locale definition as included in Space
  # Read more about Localization at https://www.contentful.com/developers/documentation/content-delivery-api/#i18n
  class Locale
    include Contentful::Resource

    property :code, :string
    property :name, :string
    property :default, :boolean
  end
end
