require_relative 'resource'
require_relative 'resource/fields'

module Contentful
  class Asset
    include Contentful::Resource
    include Contentful::Resource::SystemProperties
    include Contentful::Resource::Fields

  end
end