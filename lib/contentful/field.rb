require_relative 'resource'

module Contentful
  class Field
    include Contentful::Resource

    property :id, :string
    property :name, :string
    property :type, :string
    property :items
    property :required, :boolean
    property :localized, :boolean
  end
end