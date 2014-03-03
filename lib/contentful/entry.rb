require_relative 'resource'
require_relative 'resource/fields'

module Contentful
  class Entry
    include Contentful::Resource
    include Contentful::Resource::SystemProperties
    include Contentful::Resource::Fields


    # def self.entry_class(content_type)
    # end
  end
end