require_relative 'support'
require_relative 'base_resource'

module Contentful
  # Base definition of a Contentful Resource containing Field properties
  class FieldsResource < BaseResource
    def initialize(item, _configuration, localized = false, includes = [], *)
      super

      @fields = hydrate_fields(localized, includes)

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
        raw: raw_with_links
      }
    end

    # @private
    def marshal_load(raw_object)
      super(raw_object)
      localized = raw_object[:raw].fetch('fields', {}).all? { |_, v| v.is_a?(Hash) }
      @fields = hydrate_fields(localized, [])
      define_fields_methods!
    end

    # @private
    def raw_with_links
      links = fields.keys.select { |property| known_link?(property) }
      processed_raw = raw.clone
      raw['fields'].each do |k, v|
        processed_raw['fields'][k] = links.include?(Support.snakify(k).to_sym) ? send(Support.snakify(k)) : v
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

    def hydrate_fields(localized, includes)
      return {} unless raw.key?('fields')

      locale = internal_resource_locale
      result = { locale => {} }

      if localized
        raw['fields'].each do |name, locales|
          locales.each do |loc, value|
            result[loc] ||= {}
            result[loc][Support.snakify(name).to_sym] = coerce(
              Support.snakify(name),
              value,
              localized,
              includes
            )
          end
        end
      else
        raw['fields'].each do |name, value|
          result[locale][Support.snakify(name).to_sym] = coerce(
            Support.snakify(name),
            value,
            localized,
            includes
          )
        end
      end

      result
    end

    protected

    def coerce(_field_id, value, _localized, _includes)
      value
    end
  end
end
