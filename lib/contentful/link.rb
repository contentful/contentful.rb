require_relative 'resource'

module Contentful
  class Link
    include Contentful::Resource
    include Contentful::Resource::SystemProperties
  end
end