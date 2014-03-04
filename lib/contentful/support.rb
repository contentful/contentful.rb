module Contentful
  module Support
    class << self
      def snakify(object)
        object.to_s.gsub(/(?<!^)[A-Z]/) do "_#$&" end.downcase # from zucker
      end

      def client_method_for_type(string)
        {
          "Space" => :space,
          "ContentType" => :content_types,
          "Entry" => :entries,
          "Asset" => :assets,

        }[string]
      end
    end
  end
end
