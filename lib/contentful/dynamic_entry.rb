require_relative 'resource'
require_relative 'resource/fields'

module Contentful
  class DynamicEntry < Entry
    def self.create(content_type)
       unless content_type.is_a? Contentful::ContentType
         content_type = Contentful::ContentType.new(content_type)
       end

      Class.new DynamicEntry do
        content_type.fields.each{ |f|
          define_method f.id.to_sym do
            fields[f.id.to_sym]
          end
        }
      end
    end
  end
end