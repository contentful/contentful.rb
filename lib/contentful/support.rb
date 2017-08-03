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
        String(object)
          .gsub(/::/, '/')
          .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
          .gsub(/([a-z\d])([A-Z])/, '\1_\2')
          .tr('-', '_')
          .downcase
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

      # Returns the resource that matches the link
      #
      # @param [Hash] link
      # @param [::Array] includes
      #
      # @return [Hash]
      def resource_for_link(link, includes)
        includes.detect do |i|
          i['sys']['id'] == link['sys']['id'] &&
            i['sys']['type'] == link['sys']['linkType']
        end
      end

      # Returns combined include array from an API Response
      #
      # @param [Hash] json JSON Response
      # @param [Bool] raw Response pre-proccessed?
      #
      # @return [Array]
      def includes_from_response(json, raw = true)
        includes = if raw
                     json['items'].dup
                   else
                     json['items'].map(&:raw)
                   end

        %w(Entry Asset).each do |type|
          if json.fetch('includes', {}).key?(type)
            includes.concat(json['includes'].fetch(type, []))
          end
        end

        includes
      end
    end
  end
end
