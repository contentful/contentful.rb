require_relative 'resource'
require_relative 'resource/asset_fields'

module Contentful
  # Resource class for Asset.
  # https://www.contentful.com/developers/documentation/content-delivery-api/#assets
  class Asset
    include Contentful::Resource
    include Contentful::Resource::SystemProperties
    include Contentful::Resource::AssetFields

    # @private
    def marshal_dump
      raw
    end

    # @private
    def marshal_load(raw_object)
      @properties = extract_from_object(raw_object, :property, self.class.property_coercions.keys)
      @sys = raw_object.key?('sys') ? extract_from_object(raw_object['sys'], :sys) : {}
      initialize_fields_for_localized_resource(raw_object)
      @raw = raw_object
    end

    # Generates a URL for the Contentful Image API
    #
    # @param [Hash] options
    # @option options [Integer] :width
    # @option options [Integer] :height
    # @option options [String] :format
    # @option options [String] :quality
    # @option options [String] :focus
    # @option options [String] :fit
    # @option options [String] :fl File Layering - 'progressive'
    # @see _ https://www.contentful.com/developers/documentation/content-delivery-api/#image-asset-resizing
    #
    # @return [String] Image API URL
    def image_url(options = {})
      query = {
        w: options[:w] || options[:width],
        h: options[:h] || options[:height],
        fm: options[:fm] || options[:format],
        q: options[:q] || options[:quality],
        f: options[:f] || options[:focus],
        fit: options[:fit],
        fl: options[:fl]
      }.reject { |_k, v| v.nil? }

      if query.empty?
        file.url
      else
        "#{file.url}?#{URI.encode_www_form(query)}"
      end
    end

    alias url image_url
  end
end
