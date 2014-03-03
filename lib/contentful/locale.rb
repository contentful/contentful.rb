require_relative 'resource'

module Contentful
  class Locale
    include Contentful::Resource

    property :code
    property :name
  end
end