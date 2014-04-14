require_relative 'resource'
require_relative 'resource/fields'

module Contentful
  # Resource class for Entry.
  # https://www.contentful.com/developers/documentation/content-delivery-api/#entries
  class Entry
    include Contentful::Resource
    include Contentful::Resource::SystemProperties
    include Contentful::Resource::Fields
  end
end
