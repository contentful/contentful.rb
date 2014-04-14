require_relative 'resource'
require_relative 'locale'

module Contentful
  # Resource class for Space.
  # https://www.contentful.com/developers/documentation/content-delivery-api/#spaces
  class Space
    include Contentful::Resource
    include Contentful::Resource::SystemProperties

    property :name, :string
    property :locales, Locale
  end
end
