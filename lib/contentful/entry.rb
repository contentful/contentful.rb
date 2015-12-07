require_relative 'resource'
require_relative 'resource/fields'

module Contentful
  # Resource class for Entry.
  # https://www.contentful.com/developers/documentation/content-delivery-api/#entries
  class Entry
    include Contentful::Resource
    include Contentful::Resource::SystemProperties
    include Contentful::Resource::Fields

    def marshal_dump
      access_token = client.configuration[:access_token]
      space = client.configuration[:space]
      raw_client = Contentful::Client.new(access_token: access_token, space: space, raw_mode: true)

      raw_client.entry(id).object
    end

    def marshal_load(raw_object)
      @properties = extract_from_object(raw_object, :property, self.class.property_coercions.keys)
      @sys = raw_object.key?('sys') ? extract_from_object(raw_object['sys'], :sys) : {}
      extract_fields_from_object!(raw_object)
    end
  end
end
