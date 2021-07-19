require_relative 'error'
require_relative 'fields_resource'
require_relative 'content_type_cache'
require_relative 'resource_references'
require_relative 'includes'

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
      if Support.link?(value)
        return nil if Support.unresolvable?(value, errors)
        return build_nested_resource(value, includes, entries, errors)
      end
      return coerce_link_array(value, includes, errors, entries) if Support.link_array?(value)

      content_type_key = Support.snakify('contentType', @configuration[:use_camel_case])
      content_type = ContentTypeCache.cache_get(sys[:space].id, sys[content_type_key.to_sym].id)

      unless content_type.nil?
        content_type_field = content_type.field_for(field_id)
        coercion_configuration = @configuration.merge(
          includes_for_single:
            @configuration.fetch(:includes_for_single, Includes.new) + includes,
          _entries_cache: entries,
          localized: localized,
          depth: @depth,
          errors: errors
        )
        return content_type_field.coerce(value, coercion_configuration) unless content_type_field.nil?
      end

      super(field_id, value, includes, errors, entries)
    end

    def coerce_link_array(value, includes, errors, entries)
      items = []
      value.each do |link|
        nested_resource = build_nested_resource(link, includes, entries, errors) unless Support.unresolvable?(link, errors)
        items << nested_resource unless nested_resource.nil?
      end

      items
    end

    # Maximum include depth is 10 in the API, but we raise it to 20 (by default),
    # in case one of the included items has a reference in an upper level,
    # so we can keep the include chain for that object as well
    # Any included object after the maximum include resolution depth will be just a Link
    def build_nested_resource(value, includes, entries, errors)
      if @depth < @configuration.fetch(:max_include_resolution_depth, 20)
        resource = includes.find_link(value)
        return resolve_include(resource, includes, entries, errors) unless resource.nil?
      end

      build_link(value)
    end

    def resolve_include(resource, includes, entries, errors)
      require_relative 'resource_builder'

      ResourceBuilder.new(
        resource,
        @configuration.merge(
          includes_for_single:
            @configuration.fetch(:includes_for_single, Includes.new) + includes,
          _entries_cache: entries
        ),
        localized,
        @depth + 1,
        errors
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

    def method_missing(name, *args, &block)
      return empty_field_error(name) if content_type_field?(name)

      super
    end

    def respond_to_missing?(name, include_private = false)
      content_type_field?(name) || super
    end

    protected

    def content_type_field?(name)
      content_type_key = Support.snakify('contentType', @configuration[:use_camel_case])

      content_type = ContentTypeCache.cache_get(
        sys[:space].id,
        sys[content_type_key.to_sym].id
      )

      return false if content_type.nil?

      !content_type.field_for(name).nil?
    end

    def empty_field_error(name)
      return nil unless @configuration[:raise_for_empty_fields]
      fail EmptyFieldError, name
    end

    def repr_name
      content_type_key = Support.snakify('contentType', @configuration[:use_camel_case]).to_sym
      "#{super}[#{sys[content_type_key].id}]"
    end
  end
end
