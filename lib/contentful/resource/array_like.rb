module Contentful
  module Resource
    # Useful methods for array-like resources that can be included if an
    # :items property exists
    module ArrayLike
      include Enumerable

      # Returns true for array-like resources
      def array?
        true
      end

      # Delegates to items#each
      def each_item(&block)
        items.each(&block)
      end
      alias_method :each, :each_item

      # Delegates to items#empty?
      def empty?
        items.empty?
      end

      # Delegetes to items#size
      def size
        items.size
      end
      alias_method :length, :size
    end
  end
end
