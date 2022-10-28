require_relative 'array_like'

module Contentful
  # The includes hashes returned when include_level is specified
  class Includes
    include ArrayLike

    attr_accessor :items, :lookup

    def initialize(items = [], lookup = nil)
      self.items = items
      self.lookup = lookup || build_lookup
    end

    def self.from_response(json, raw = true)
      includes = if raw
                   json['items'].dup
                 else
                   json['items'].map(&:raw)
                 end

      %w[Entry Asset].each do |type|
        includes.concat(json['includes'].fetch(type, [])) if json.fetch('includes', {}).key?(type)
      end

      new includes || []
    end

    def find_link(link)
      key = "#{link['sys']['linkType']}:#{link['sys']['id']}"
      lookup[key]
    end

    # Override some of the features of Array to take into account the lookup
    # field in a performant way.

    # If the lookups are the same then these two objects are effectively the same
    def ==(other)
      object_id == other.object_id || lookup == other.lookup
    end

    def +(other)
      # If we're being asked to add to itself, just return without duplicating
      return self if self == other

      dup.tap do |copy|
        copy.items += other.items
        copy.lookup.merge!(other.lookup)
      end
    end

    def dup
      self.class.new(items.dup, lookup.dup)
    end

    def marshal_dump
      items
    end

    def marshal_load(array)
      self.items = array
      self.lookup = build_lookup
    end

    private

    def build_lookup
      items.each_with_object({}) do |i, h|
        key = "#{i['sys']['type']}:#{i['sys']['id']}"
        h[key] = i
      end
    end
  end
end
