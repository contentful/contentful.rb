# frozen_string_literal: true

require_relative 'support'

module Contentful
  # Base definition of a Contentful Resource containing Sys properties
  class BaseResource
    attr_reader :raw, :default_locale, :sys, :_metadata

    # rubocop:disable Metrics/ParameterLists
    def initialize(item, configuration = {}, _localized = false, _includes = Includes.new, entries = {}, depth = 0, _errors = [])
      entries["#{item['sys']['type']}:#{item['sys']['id']}"] = self if entries && item.key?('sys')
      @raw = item
      @default_locale = configuration[:default_locale]
      @depth = depth
      @configuration = configuration
      @sys = hydrate_sys
      @_metadata = hydrate_metadata

      define_sys_methods!
    end

    # @private
    def inspect
      "<#{repr_name} id='#{sys[:id]}'>"
    end

    # Definition of equality
    def ==(other)
      self.class == other.class && sys[:id] == other.sys[:id]
    end

    # @private
    def marshal_dump
      entry_mapping = @configuration[:entry_mapping].each_with_object({}) do |(k, v), res|
        res[k] = v.to_s
      end

      {
        # loggers usually have a file handle that can't be marshalled, so let's not return that
        configuration: @configuration.merge(entry_mapping: entry_mapping, logger: nil),
        raw: raw
      }
    end

    # @private
    def marshal_load(raw_object)
      raw_object[:configuration][:entry_mapping] = raw_object[:configuration].fetch(:entry_mapping, {}).each_with_object({}) do |(k, v), res|
        begin
          v = v.to_s unless v.is_a?(::String)
          res[k] = v.split('::').inject(Object) { |o, c| o.const_get c }
        rescue
          next
        end
      end

      @raw = raw_object[:raw]
      @configuration = raw_object[:configuration]
      @default_locale = @configuration[:default_locale]
      @sys = hydrate_sys
      @_metadata = hydrate_metadata
      @depth = 0
      define_sys_methods!
    end

    # Issues the request that was made to fetch this response again.
    # Only works for Entry, Asset, ContentType and Space
    def reload(client = nil)
      return client.send(Support.snakify(self.class.name.split('::').last), id) unless client.nil?

      false
    end

    private

    def define_sys_methods!
      @sys.each do |k, v|
        define_singleton_method(k) { v } unless self.class.method_defined?(k)
      end
    end

    LINKS = %w[space contentType environment].freeze
    TIMESTAMPS = %w[createdAt updatedAt deletedAt].freeze

    def hydrate_sys
      result = {}
      raw.fetch('sys', {}).each do |k, v|
        if LINKS.include?(k)
          v = build_link(v)
        elsif TIMESTAMPS.include?(k)
          v = DateTime.parse(v)
        end
        result[Support.snakify(k, @configuration[:use_camel_case]).to_sym] = v
      end
      result
    end

    def hydrate_metadata
      result = {}
      raw.fetch('metadata', {}).each do |k, v|
        v = v.map { |tag| build_link(tag) } if k == 'tags'
        result[Support.snakify(k, @configuration[:use_camel_case]).to_sym] = v
      end
      result
    end

    protected

    def repr_name
      self.class
    end

    def internal_resource_locale
      sys.fetch(:locale, nil) || default_locale
    end

    def build_link(item)
      require_relative 'link'
      ::Contentful::Link.new(item, @configuration)
    end
  end
end
