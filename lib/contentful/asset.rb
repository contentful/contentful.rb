require_relative 'resource'
require_relative 'resource/asset_fields'

module Contentful
  class Asset
    include Contentful::Resource
    include Contentful::Resource::SystemProperties
    include Contentful::Resource::AssetFields


    def image_url(options = {})
      query = {
        w:  options[:w]  || options[:width],
        h:  options[:h]  || options[:height],
        fm: options[:fm] || options[:format],
        q:  options[:q]  || options[:quality],
      }.reject{ |k,v| v.nil? }

      if query.empty?
        file.url
      else
        "#{file.url}?#{ URI.encode_www_form(query) }"
      end
    end
  end
end
