require_relative 'resource'

module Contentful
  class Field
    include Contentful::Resource

    property :id
    property :name
    property :type
    property :items
    property :required
    property :localized
  end
end