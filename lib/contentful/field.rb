require_relative 'resource'

module Contentful
  # A ContentType's field schema
  # See https://www.contentful.com/developers/documentation/content-management-api/#resources-content-types-fields
  class Field
    include Contentful::Resource

    property :id, :string
    property :name, :string
    property :type, :string
    property :linkType, :string
    property :items, Field
    property :required, :boolean
    property :localized, :boolean
  end
end
