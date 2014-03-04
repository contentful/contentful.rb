require_relative 'resource'

module Contentful
  class Array
    include Contentful::Resource
    include Contentful::Resource::SystemProperties
    include Enumerable

    property :total, :integer
    property :limit, :integer
    property :skip, :integer
    property :items

    def array?
      true
    end

    def each(&block)
      items.each(&block)
    end

  end
end