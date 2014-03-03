require_relative 'resource'

module Contentful
  class Collection
    include Contentful::Resource
    include Contentful::Resource::SystemProperties

  end
end