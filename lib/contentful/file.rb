require_relative 'resource'

module Contentful
  class File
    include Contentful::Resource

    property :fileName, :string
    property :contentType, :string
    property :details
    property :url, :string
  end
end