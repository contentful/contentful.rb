require_relative 'resource'

module Contentful
  # A Locale definition as included in Space
  class Locale
    include Contentful::Resource

    property :code, :string
    property :name, :string
  end
end