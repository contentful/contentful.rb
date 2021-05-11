module Contentful
  # The includes hashes returned when include_level is specified
  class Includes
    include Enumerable
    
    attr_accessor :includes
    attr_accessor :lookup
    
    def initialize(array_of_hashes=[], lookup=nil)
      self.includes = array_of_hashes
      self.lookup = lookup || build_lookup
    end
    
    def self.from_response(json, raw = true)
      includes = if raw
                   json['items'].dup
                 else
                   json['items'].map(&:raw)
                 end

      %w[Entry Asset].each do |type|
        if json.fetch('includes', {}).key?(type)
          includes.concat(json['includes'].fetch(type, []))
        end
      end
      
      new includes
    end
    
    def find_link(link)
      key = "#{link['sys']['linkType']}:#{link['sys']['id']}"
      lookup[key]
    end
    
    # Below are methods to make it behave more like an Array to provide
    # backwards compatibility in a performant way.
    
    def +(other)
      dup.tap do |copy|
        copy.includes += other.includes
        copy.lookup.merge!(other.lookup)
      end
    end
    
    def dup
      Includes.new(includes.dup, lookup.dup)
    end
    
    def each(&block)
      includes.each(&block)
    end

    def marshal_dump
      includes
    end
    
    def marshal_load(array)
      self.includes = array
      self.lookup = build_lookup
    end
    
    private
    
    def build_lookup
      includes.inject({}) do |h,i|
        key = "#{i['sys']['type']}:#{i['sys']['id']}"
        h[key] = i
        h
      end
    end
    
  end
end
