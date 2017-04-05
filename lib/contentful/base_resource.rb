require_relative 'support'

module Contentful
  # Base definition of a Contentful Resource containing Sys properties
  class BaseResource
    attr_reader :raw, :default_locale, :sys

    def initialize(item, configuration = {}, _localized = false, _includes = [], depth = 0)
      @raw = item
      @default_locale = configuration[:default_locale]
      @depth = depth
      @sys = hydrate_sys
      @configuration = configuration

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
      {
        configuration: @configuration,
        raw: raw
      }
    end

    # @private
    def marshal_load(raw_object)
      @raw = raw_object[:raw]
      @configuration = raw_object[:configuration]
      @default_locale = @configuration[:default_locale]
      @sys = hydrate_sys
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
        define_singleton_method k do
          v
        end
      end
    end

    def hydrate_sys
      result = {}
      raw.fetch('sys', {}).each do |k, v|
        if %w(space contentType).include?(k)
          v = build_link(v)
        elsif %w(createdAt updatedAt deletedAt).include?(k)
          v = DateTime.parse(v)
        end
        result[Support.snakify(k).to_sym] = v
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
      ::Contentful::Link.new(item)
    end
  end
end
