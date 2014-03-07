module Contentful
  # Utility methods used by the contentful gem
  module Support
    class << self
      # Transforms CamelCase into snake_case
      def snakify(object)
        object.to_s.gsub(/(?<!^)[A-Z]/) do "_#$&" end.downcase # from zucker
      end
    end
  end
end
