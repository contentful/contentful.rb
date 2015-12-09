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
      raw_with_links
    end

    def marshal_load(raw_object)
      @properties = extract_from_object(raw_object, :property, self.class.property_coercions.keys)
      @sys = raw_object.key?('sys') ? extract_from_object(raw_object['sys'], :sys) : {}
      extract_fields_from_object!(raw_object)
    end

    def raw_with_links
      links = properties.keys.select { |property| is_known_link?(property) }
      processed_raw = Marshal.load(Marshal.dump(raw)) # Deep Copy
      raw['fields'].each do |k, v|
        processed_raw['fields'][k] = links.include?(k.to_sym) ? self.send(snakify(k)) : v
      end

      processed_raw
    end

    private

    def is_known_link?(name)
      field_name = name.to_sym
      fields[field_name].is_a?(Contentful::Entry) ||
        fields[field_name].is_a?(Contentful::Asset)
    end

    def snakify(name)
      Contentful::Support.snakify(name).to_sym
    end
  end
end
