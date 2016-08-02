require_relative 'resource'
require_relative 'resource/fields'
require_relative 'location'

module Contentful
  # Wrapper for Entries with Cached Content Types
  class DynamicEntry < Entry
    # Coercions from Contentful Types to Ruby native types
    KNOWN_TYPES = {
      'String'   => :string,
      'Text'     => :string,
      'Symbol'   => :string,
      'Integer'  => :integer,
      'Float'    => :float,
      'Boolean'  => :boolean,
      'Date'     => :date,
      'Location' => Location
    }

    # @private
    def self.create(content_type)
      unless content_type.is_a? ContentType
        content_type = ContentType.new(content_type)
      end

      fields_coercions = Hash[
                         content_type.fields.map do |field|
                           [field.id.to_sym, KNOWN_TYPES[field.type]]
                         end
      ]

      Class.new DynamicEntry do
        content_type.fields.each do |f|
          define_method Support.snakify(f.id).to_sym do |wanted_locale = nil|
            fields(wanted_locale)[f.id.to_sym]
          end
        end

        define_singleton_method :fields_coercions do
          fields_coercions
        end

        define_singleton_method :content_type do
          content_type
        end

        define_singleton_method :to_s do
          "Contentful::DynamicEntry[#{content_type.id}]"
        end

        define_singleton_method :inspect do
          "Contentful::DynamicEntry[#{content_type.id}]"
        end
      end
    end
  end
end
