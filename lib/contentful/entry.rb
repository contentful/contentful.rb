require_relative 'resource'
require_relative 'resource/fields'

module Contentful
  # Resource class for Entry.
  # @see _ https://www.contentful.com/developers/documentation/content-delivery-api/#entries
  class Entry
    include Contentful::Resource
    include Contentful::Resource::SystemProperties
    include Contentful::Resource::Fields

    # @private
    def marshal_dump
      raw_with_links
    end

    # @private
    def marshal_load(raw_object)
      @properties = extract_from_object(raw_object, :property, self.class.property_coercions.keys)
      @sys = raw_object.key?('sys') ? extract_from_object(raw_object['sys'], :sys) : {}
      extract_fields_from_object!(raw_object)
      @raw = raw_object
    end

    # @private
    def raw_with_links
      links = properties.keys.select { |property| known_link?(property) }
      processed_raw = raw.clone
      raw['fields'].each do |k, v|
        processed_raw['fields'][k] = links.include?(k.to_sym) ? send(snakify(k)) : v
      end

      processed_raw
    end

    # Returns true for resources that are entries
    def entry?
      true
    end

    private

    def known_link?(name)
      field_name = name.to_sym
      return true if known_contentful_object?(fields[field_name])
      fields[field_name].is_a?(Enumerable) && known_contentful_object?(fields[field_name].first)
    end

    def known_contentful_object?(object)
      (object.is_a?(Contentful::Entry) || object.is_a?(Contentful::Asset))
    end

    def snakify(name)
      Contentful::Support.snakify(name).to_sym
    end
  end
end
