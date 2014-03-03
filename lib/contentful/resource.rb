require_relative 'resource/system_properties'

module Contentful
  module Resource
    attr_reader :properties

    def initialize(object)
      @properties = extract_from_object self.class.property_coercions.keys, object
    end

    def inspect(info = nil)
      "#<#{self.class}:#{object_id} @properties=#{properties.inspect}#{info}>"
    end


    private

    def extract_from_object(keys, object)
      keys.each.with_object({}){ |name, res|
        res[name.to_sym] = coerce_value(
          object.is_a?(Array) ? object : object[name.to_s],
          self.class.property_coercions[name.to_sym],
        )
      }
    end

    def coerce_value(value, property_class = nil)
      if !property_class
        value
      else
        if value.is_a? Array
          value.map{ |v| property_class.new(v) }
        else
          property_class.new(value)
        end
      end
    end

    module ClassMethods
      def property_coercions
        @property_coercions ||= {}
      end

      def property(name, property_class = nil)
        property_coercions[name.to_sym] = property_class
        define_method Contentful::Support.snakify(name) do
          properties[name.to_sym]
        end
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end
  end
end
