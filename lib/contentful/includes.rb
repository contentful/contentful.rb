module Contentful
  # The includes hashes returned when include_level is specified
  class Includes
    
    attr_accessor :includes
    attr_accessor :lookup
    
    def initialize(array_of_hashes=[], lookup=nil)
      @includes = array_of_hashes
      @lookup = lookup || build_lookup
    end
    
    def +(other)
      dup.tap do |copy|
        copy.includes += other.includes
        copy.lookup.merge!(other.lookup)
      end
    end
    
    def dup
      Includes.new(includes.dup, lookup.dup)
    end
    
    def find_link(link)
      key = "#{link['sys']['linkType']}:#{link['sys']['id']}"
      lookup[key]
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
