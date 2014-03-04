require_relative 'resource'
require_relative 'resource/asset_fields'

module Contentful
  class Asset
    include Contentful::Resource
    include Contentful::Resource::SystemProperties
    include Contentful::Resource::AssetFields
  end
end