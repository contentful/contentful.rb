require_relative 'resource'
require_relative 'field'

module Contentful
  # Resource Class for Content Types
  # https://www.contentful.com/developers/documentation/content-delivery-api/#content-types
  class ContentType
    include Contentful::Resource
    include Contentful::Resource::SystemProperties

    property :name, :string
    property :description, :string
    property :fields, Field
    property :displayField, :string
  end
end
