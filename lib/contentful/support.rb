module Contentful
  # Utility methods used by the contentful gem
  module Support
    class << self
      # Transforms CamelCase into snake_case (taken from zucker)
      def snakify(object)
        object.to_s.gsub(/(?<!^)[A-Z]/) do "_#$&" end.downcase
      end

      # Transforms each hash key into a symbol (like in AS)
      def symbolize_keys(h)
        result = {}
        h.each_key{ |key| result[(key.to_sym rescue key)] = h[key] }
        result
      end
    end
  end
end
