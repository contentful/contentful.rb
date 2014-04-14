require_relative 'resource'

module Contentful
  # Location Field Type
  # You can directly query for them: https://www.contentful.com/developers/documentation/content-delivery-api/#search-filter-geo
  class Location
    include Contentful::Resource

    property :lat, :float
    property :lon, :float
  end
end
