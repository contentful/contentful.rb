module Contentful
  # Utility methods used by the contentful gem
  module Support
    class << self
      # Transforms CamelCase into snake_case (taken from zucker)
      #
      # @param [String] object camelCaseName
      #
      # @return [String] snake_case_name
      def snakify(object)
        snake = String(object).gsub(/(?<!^)[A-Z]/) { "_#{$&}" }
        snake.downcase
      end

      # Returns true if resource is localized
      #
      # @return [Boolean]
      def localized?(value)
        return false unless value.is_a? ::Hash
        value.keys.any? { |possible_locale| Contentful::Constants::KNOWN_LOCALES.include?(possible_locale) }
      end
    end
  end
end
