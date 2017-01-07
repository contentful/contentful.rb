module Contentful
  # Useful methods for array-like resources that can be included if an
  # :items property exists
  module ArrayLike
    include Enumerable

    # Returns true for array-like resources
    #
    # @return [true]
    def array?
      true
    end

    # Delegates to items#each
    #
    # @yield [Contentful::Entry, Contentful::Asset]
    def each_item(&block)
      items.each(&block)
    end
    alias each each_item

    # Delegates to items#empty?
    #
    # @return [Boolean]
    def empty?
      items.empty?
    end

    # Delegetes to items#size
    #
    # @return [Number]
    def size
      items.size
    end
    alias length size

    # Delegates to items#[]
    #
    # @return [Contentful::Entry, Contentful::Asset]
    def [](index)
      items[index]
    end

    # Delegates to items#last
    #
    # @return [Contentful::Entry, Contentful::Asset]
    def last
      items.last
    end
  end
end
