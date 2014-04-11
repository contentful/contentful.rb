module Contentful
  # Utility methods used by the contentful gem
  module Support
    class << self
      # Transforms CamelCase into snake_case (taken from zucker)
      def snakify(object)
        snake = String(object).gsub(/(?<!^)[A-Z]/) { "_#$&" }
        snake.downcase
      end

      # Transforms each hash key into a symbol (like in AS)
      def symbolize_keys(hash)
        result = {}
        # XXX remove inline rescue
        hash.each_key { |key| result[(key.to_sym rescue key)] = hash[key] }
        result
      end
    end
  end
end
