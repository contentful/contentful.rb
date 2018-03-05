require_relative 'support'
require_relative 'base_resource'

module Contentful
  # Base definition of a Contentful Resource containing Field properties
  class FieldsResource < BaseResource
    attr_reader :localized

    # rubocop:disable Metrics/ParameterLists
    def initialize(item, _configuration, localized = false, includes = [], entries = {}, depth = 0, errors = [])
      super

      @localized = localized
      @fields = hydrate_fields(includes, entries, errors)
      define_fields_methods!
    end

    # Returns all fields of the asset
    #
    # @return [Hash] fields for Resource on selected locale
    def fields(wanted_locale = nil)
      wanted_locale = internal_resource_locale if wanted_locale.nil?
      @fields.fetch(wanted_locale.to_s, {})
    end

    # Returns all fields of the asset with locales nested by field
    #
    # @return [Hash] fields for Resource grouped by field name
    def fields_with_locales
      remapped_fields = {}
      locales.each do |locale|
        fields(locale).each do |name, value|
          remapped_fields[name] ||= {}
          remapped_fields[name][locale.to_sym] = value
        end
      end

      remapped_fields
    end

    # Provides a list of the available locales for a Resource
    def locales
      @fields.keys
    end

    # @private
    def marshal_dump
      {
        configuration: @configuration,
        raw: raw_with_links,
        localized: localized
      }
    end

    # @private
    def marshal_load(raw_object)
      super(raw_object)
      @localized = raw_object[:localized]
      @fields = hydrate_fields(raw_object[:configuration].fetch(:includes_for_single, []), {}, [])
      define_fields_methods!
    end

    # @private
    def raw_with_links
      links = fields.keys.select { |property| known_link?(property) }
      processed_raw = raw.clone
      raw['fields'].each do |k, v|
        links_key = Support.snakify(k, @configuration[:use_camel_case])
        processed_raw['fields'][k] = links.include?(links_key.to_sym) ? send(links_key) : v
      end

      processed_raw
    end

    private

    def define_fields_methods!
      fields.each do |k, v|
        define_singleton_method k do
          v
        end
      end
    end

    def hydrate_localized_fields(includes, errors, entries)
      locale = internal_resource_locale
      result = { locale => {} }
      raw['fields'].each do |name, locales|
        locales.each do |loc, value|
          result[loc] ||= {}
          name = Support.snakify(name, @configuration[:use_camel_case])
          result[loc][name.to_sym] = coerce(
            name,
            value,
            includes,
            errors,
            entries
          )
        end
      end

      result
    end

    def hydrate_nonlocalized_fields(includes, errors, entries)
      result = { locale => {} }
      locale = internal_resource_locale
      raw['fields'].each do |name, value|
        name = Support.snakify(name, @configuration[:use_camel_case])
        result[locale][name.to_sym] = coerce(
          name,
          value,
          includes,
          errors,
          entries
        )
      end

      result
    end

    def hydrate_fields(includes, entries, errors)
      return {} unless raw.key?('fields')

      if localized
        hydrate_localized_fields(includes, errors, entries)
      else
        hydrate_nonlocalized_fields(includes, errors, entries)
      end
    end

    protected

    def coerce(_field_id, value, _includes, _errors, _entries)
      value
    end
  end
end
