require_relative 'resource'
require_relative 'locale'

module Contentful
  class Space
    include Contentful::Resource
    include Contentful::Resource::SystemProperties

    property :name
    property :locales, Locale
  end
end