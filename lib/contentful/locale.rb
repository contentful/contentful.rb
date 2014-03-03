require_relative 'resource'

module Contentful
  class Locale
    include Contentful::Resource

    property :code, :string
    property :name, :string
  end
end