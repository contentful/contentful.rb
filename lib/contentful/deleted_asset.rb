require_relative 'resource'

module Contentful
  # Resource class for deleted entries
  # https://www.contentful.com/developers/documentation/content-delivery-api/http/#sync-item-types
  class DeletedAsset
    include Contentful::Resource
    include Contentful::Resource::SystemProperties
  end
end
