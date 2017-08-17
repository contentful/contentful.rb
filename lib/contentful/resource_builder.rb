require_relative 'error'
require_relative 'space'
require_relative 'content_type'
require_relative 'entry'
require_relative 'asset'
require_relative 'array'
require_relative 'link'
require_relative 'deleted_entry'
require_relative 'deleted_asset'

module Contentful
  # Transforms a Contentful::Response into a Contentful::Resource or a Contentful::Error
  # See example/resource_mapping.rb for advanced usage
  class ResourceBuilder
    # Default Resource Mapping
    # @see _ README for more information on Resource Mapping
    DEFAULT_RESOURCE_MAPPING = {
      'Space' => Space,
      'ContentType' => ContentType,
      'Entry' => Entry,
      'Asset' => Asset,
      'Array' => Array,
      'Link' => Link,
      'DeletedEntry' => DeletedEntry,
      'DeletedAsset' => DeletedAsset
    }
    # Default Entry Mapping
    # @see _ README for more information on Entry Mapping
    DEFAULT_ENTRY_MAPPING = {}

    attr_reader :json, :default_locale, :endpoint, :depth, :localized, :resource_mapping, :entry_mapping, :resource

    def initialize(json, configuration = {}, localized = false, depth = 0, endpoint = nil)
      @json = json
      @default_locale = configuration.fetch(:default_locale, ::Contentful::Client::DEFAULT_CONFIGURATION[:default_locale])
      @resource_mapping = default_resource_mapping.merge(configuration.fetch(:resource_mapping, {}))
      @entry_mapping = default_entry_mapping.merge(configuration.fetch(:entry_mapping, {}))
      @includes_for_single = configuration.fetch(:includes_for_single, [])
      @localized = localized
      @depth = depth
      @endpoint = endpoint
      @configuration = configuration
    end

    # Starts the parsing process.
    #
    # @return [Contentful::Resource, Contentful::Error]
    def run
      return build_array if array?
      build_single
    rescue UnparsableResource => error
      error
    end

    private

    def build_array
      includes = fetch_includes
      result = json['items'].map do |item|
        build_item(item, includes)
      end
      array_class = fetch_array_class
      array_class.new(json.dup.merge('items' => result), @configuration, endpoint)
    end

    def build_single
      includes = @includes_for_single
      build_item(json, includes)
    end

    def build_item(item, includes = [])
      buildables = %w(Entry Asset ContentType Space DeletedEntry DeletedAsset)
      item_type = buildables.detect { |b| b.to_s == item['sys']['type'] }
      fail UnparsableResource, 'Item type is not known, could not parse' if item_type.nil?
      item_class = resource_class(item)

      item_class.new(item, @configuration, localized?, includes, depth)
    end

    def fetch_includes
      Support.includes_from_response(json)
    end

    def resource_class(item)
      return fetch_custom_resource_class(item) if %w(Entry DeletedEntry Asset DeletedAsset).include?(item['sys']['type'])
      resource_mapping[item['sys']['type']]
    end

    def fetch_custom_resource_class(item)
      case item['sys']['type']
      when 'Entry'
        resource_class = entry_mapping[item['sys']['contentType']['sys']['id']]
        return resource_class unless resource_class.nil?

        return fetch_custom_resource_mapping(item, 'Entry', Entry)
      when 'Asset'
        return fetch_custom_resource_mapping(item, 'Asset', Asset)
      when 'DeletedEntry'
        return fetch_custom_resource_mapping(item, 'DeletedEntry', DeletedEntry)
      when 'DeletedAsset'
        return fetch_custom_resource_mapping(item, 'DeletedAsset', DeletedAsset)
      end
    end

    def fetch_custom_resource_mapping(item, type, default_class)
      resources = resource_mapping[type]
      return default_class if resources.nil?

      return resources if resources.is_a?(Class)
      return resources[item] if resources.respond_to?(:call)

      default_class
    end

    def fetch_array_class
      return SyncPage if sync?
      ::Contentful::Array
    end

    def localized?
      return true if @localized
      return true if array? && sync?
      false
    end

    def array?
      json.fetch('sys', {}).fetch('type', '') == 'Array'
    end

    def sync?
      json.fetch('nextSyncUrl', nil) || json.fetch('nextPageUrl', nil)
    end

    # The default mapping for #detect_resource_class
    def default_resource_mapping
      DEFAULT_RESOURCE_MAPPING.dup
    end

    # The default entry mapping
    def default_entry_mapping
      DEFAULT_ENTRY_MAPPING.dup
    end
  end
end
