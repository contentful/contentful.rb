# frozen_string_literal: true

module Contentful
  # Utility methods used by the contentful gem
  module Support
    class << self
      # Transforms CamelCase into snake_case (taken from zucker)
      #
      # @param [String] object camelCaseName
      # @param [Boolean] skip if true, skips returns original object
      #
      # @return [String] snake_case_name
      def snakify(object, skip = false)
        return object if skip

        String(object)
          .gsub(/::/, '/')
          .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
          .gsub(/([a-z\d])([A-Z])/, '\1_\2')
          .tr('-', '_')
          .downcase
      end

      def unresolvable?(value, errors)
        return true if value.nil?

        errors.any? { |i| i.fetch('details', {}).fetch('id', nil) == value['sys']['id'] }
      end

      # Checks if value is a link
      #
      # @param value
      #
      # @return [true, false]
      def link?(value)
        value.is_a?(::Hash) &&
          value.fetch('sys', {}).fetch('type', '') == 'Link'
      end

      # Checks if value is an array of links
      #
      # @param value
      #
      # @return [true, false]
      def link_array?(value)
        return link?(value[0]) if value.is_a?(::Array) && !value.empty?

        false
      end
    end
  end
end
