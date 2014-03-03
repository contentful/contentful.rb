require_relative 'resource'
require_relative 'field'

module Contentful
  class ContentType
    include Contentful::Resource
    include Contentful::Resource::SystemProperties


    property :name, :string
    property :description, :string
    property :fields, Field
    property :displayField, :string
  end
end