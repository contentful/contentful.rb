module Contentful
  # Location Field Type
  # You can directly query for them: https://www.contentful.com/developers/documentation/content-delivery-api/#search-filter-geo
  class Location
    attr_reader :lat, :lon
    alias latitude lat
    alias longitude lon

    def initialize(json)
      @lat = json.fetch('lat', nil)
      @lon = json.fetch('lon', nil)
    end
  end
end
