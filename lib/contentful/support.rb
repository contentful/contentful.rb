module Contentful
  module Support
    class << self
      def snakify(object)
        object.to_s.gsub(/(?<!^)[A-Z]/) do "_#$&" end.downcase # from zucker
      end
    end
  end
end
