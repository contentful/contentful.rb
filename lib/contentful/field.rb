require_relative 'location'
require_relative 'coercions'

module Contentful
  # A ContentType's field schema
  # See https://www.contentful.com/developers/documentation/content-management-api/#resources-content-types-fields
  class Field
    # Coercions from Contentful Types to Ruby native types
    KNOWN_TYPES = {
      'String'   => StringCoercion,
      'Text'     => TextCoercion,
      'Symbol'   => SymbolCoercion,
      'Integer'  => IntegerCoercion,
      'Number'   => FloatCoercion,
      'Boolean'  => BooleanCoercion,
      'Date'     => DateCoercion,
      'Location' => LocationCoercion,
      'Object'   => ObjectCoercion,
      'Array'    => ArrayCoercion,
      'Link'     => LinkCoercion
    }

    attr_reader :raw, :id, :name, :type, :link_type, :items, :required, :localized

    def initialize(json)
      @raw = json
      @id = json.fetch('id', nil)
      @name = json.fetch('name', nil)
      @type = json.fetch('type', nil)
      @link_type = json.fetch('linkType', nil)
      @items = json.key?('items') ? Field.new(json.fetch('items', {})) : nil
      @required = json.fetch('required', false)
      @localized = json.fetch('localized', false)
    end

    # Coerces value to proper type
    def coerce(value)
      return value if type.nil?

      options = {}
      options[:coercion_class] = KNOWN_TYPES[items.type] unless items.nil?
      KNOWN_TYPES[type].new(value, options).coerce
    end
  end
end
