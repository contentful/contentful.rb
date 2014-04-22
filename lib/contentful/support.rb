module Contentful
  # Utility methods used by the contentful gem
  module Support
    class << self
      # Transforms CamelCase into snake_case (taken from zucker)
      def snakify(object)
        snake = String(object).gsub(/(?<!^)[A-Z]/) { "_#$&" }
        snake.downcase
      end
    end
  end
end
