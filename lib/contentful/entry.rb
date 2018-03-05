require_relative 'fields_resource'
require_relative 'content_type_cache'
require_relative 'resource_references'

module Contentful
  # Resource class for Entry.
  # @see _ https://www.contentful.com/developers/documentation/content-delivery-api/#entries
  class Entry < FieldsResource
    include Contentful::ResourceReferences

    # Returns true for resources that are entries
    def entry?
      true
    end

    private

    def coerce(field_id, value, includes, errors, entries = {})
      if Support.link?(value) && !Support.unresolvable?(value, errors)
        return build_nested_resource(value, includes, entries)
      end
      return coerce_link_array(value, includes, errors, entries) if Support.link_array?(value)

      content_type_key = Support.snakify('contentType', @configuration[:use_camel_case])
      content_type = ContentTypeCache.cache_get(sys[:space].id, sys[content_type_key.to_sym].id)

      unless content_type.nil?
        content_type_field = content_type.field_for(field_id)
        return content_type_field.coerce(value) unless content_type_field.nil?
      end

      super(field_id, value, includes, errors, entries)
    end

    def coerce_link_array(value, includes, errors, entries)
      items = []
      value.each do |link|
        items << build_nested_resource(link, includes, entries) unless Support.unresolvable?(link, errors)
      end

      items
    end

    # Maximum include depth is 10 in the API, but we raise it to 20 (by default),
    # in case one of the included items has a reference in an upper level,
    # so we can keep the include chain for that object as well
    # Any included object after the maximum include resolution depth will be just a Link
    def build_nested_resource(value, includes, entries)
      if @depth < @configuration.fetch(:max_include_resolution_depth, 20)
        resource = Support.resource_for_link(value, includes)
        return resolve_include(resource, includes, entries) unless resource.nil?
      end

      build_link(value)
    end

    def resolve_include(resource, includes, entries)
      require_relative 'resource_builder'

      ResourceBuilder.new(
        resource,
        @configuration.merge(
          includes_for_single:
            @configuration.fetch(:includes_for_single, []) + includes,
          _entries_cache: entries
        ),
        localized,
        @depth + 1,
        includes
      ).run
    end

    def known_link?(name)
      field_name = name.to_sym
      return true if known_contentful_object?(fields[field_name])
      fields[field_name].is_a?(Enumerable) && fields[field_name].any? { |object| known_contentful_object?(object) }
    end

    def known_contentful_object?(object)
      (object.is_a?(Contentful::Entry) || object.is_a?(Contentful::Asset))
    end

    protected

    def repr_name
      content_type_key = Support.snakify('contentType', @configuration[:use_camel_case]).to_sym
      "#{super}[#{sys[content_type_key].id}]"
    end
  end
end
