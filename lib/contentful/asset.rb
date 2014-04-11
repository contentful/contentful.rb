require_relative 'resource'
require_relative 'resource/asset_fields'

module Contentful
  # Resource class for Asset.
  # https://www.contentful.com/developers/documentation/content-delivery-api/#assets
  class Asset
    include Contentful::Resource
    include Contentful::Resource::SystemProperties
    include Contentful::Resource::AssetFields

    # Returns the image url of an asset
    # Allows you to pass in the following options for image resizing:
    #   :width
    #   :height
    #   :format
    #   :quality
    # See https://www.contentful.com/developers/documentation/content-delivery-api/#image-asset-resizing
    def image_url(options = {})
      query = {
        w:  options[:w]  || options[:width],
        h:  options[:h]  || options[:height],
        fm: options[:fm] || options[:format],
        q:  options[:q]  || options[:quality]
      }.reject { |k, v| v.nil? }

      if query.empty?
        file.url
      else
        "#{file.url}?#{URI.encode_www_form(query)}"
      end
    end
  end
end
