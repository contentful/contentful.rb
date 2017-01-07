module Contentful
  # An Assets's file info
  class File
    attr_reader :file_name, :content_type, :details, :url
    def initialize(json)
      @file_name = json.fetch('fileName', nil)
      @content_type = json.fetch('contentType', nil)
      @details = json.fetch('details', nil)
      @url = json.fetch('url', nil)
    end
  end
end
