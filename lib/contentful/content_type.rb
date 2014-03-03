require_relative 'resource'
require_relative 'field'

module Contentful
  class ContentType
    include Contentful::Resource
    include Contentful::Resource::SystemProperties


    property :name
    property :description
    property :fields, Field
    property :displayField
  end
end