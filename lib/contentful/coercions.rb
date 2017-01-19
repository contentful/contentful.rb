require_relative 'location'

module Contentful
  # Basic Coercion
  class BaseCoercion
    attr_reader :value, :options
    def initialize(value, options = {})
      @value = value
      @options = options
    end

    # Coerces value
    def coerce
      value
    end
  end

  # Coercion for String Types
  class StringCoercion < BaseCoercion
    # Coerces value to String
    def coerce
      value.to_s
    end
  end

  # Coercion for Text Types
  class TextCoercion < StringCoercion; end

  # Coercion for Symbol Types
  class SymbolCoercion < StringCoercion; end

  # Coercion for Integer Types
  class IntegerCoercion < BaseCoercion
    # Coerces value to Integer
    def coerce
      value.to_i
    end
  end

  # Coercion for Float Types
  class FloatCoercion < BaseCoercion
    # Coerces value to Float
    def coerce
      value.to_f
    end
  end

  # Coercion for Boolean Types
  class BooleanCoercion < BaseCoercion
    # Coerces value to Boolean
    def coerce
      # rubocop:disable Style/DoubleNegation
      !!value
      # rubocop:enable Style/DoubleNegation
    end
  end

  # Coercion for Date Types
  class DateCoercion < BaseCoercion
    # Coerces value to DateTime
    def coerce
      DateTime.parse(value)
    end
  end

  # Coercion for Location Types
  class LocationCoercion < BaseCoercion
    # Coerces value to Location
    def coerce
      Location.new(value)
    end
  end

  # Coercion for Object Types
  class ObjectCoercion < BaseCoercion
    # Coerces value to hash, symbolizing each key
    def coerce
      symbolize_recursive(value)
    end

    private

    def symbolize_recursive(hash)
      {}.tap do |h|
        hash.each { |key, value| h[key.to_sym] = map_value(value) }
      end
    end

    def map_value(thing)
      case thing
      when Hash
        symbolize_recursive(thing)
      when Array
        thing.map { |v| map_value(v) }
      else
        thing
      end
    end
  end

  # Coercion for Link Types
  # Nothing should be done here as include resolution is handled within
  # entries due to depth handling (explained within Entry).
  # Only present as a placeholder for proper resolution within ContentType.
  class LinkCoercion < BaseCoercion; end

  # Coercion for Array Types
  class ArrayCoercion < BaseCoercion
    # Coerces value for each element
    def coerce
      value.map do |e|
        options[:coercion_class].new(e).coerce
      end
    end
  end
end
