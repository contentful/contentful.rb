require_relative 'resource/system_properties'

module Contentful
  module Resource
    COERCIONS = {
      string:  ->(v){ v.to_s },
      integer: ->(v){ v.to_i },
      boolean: ->(v){ !!v },
    }

    attr_reader :properties

    def initialize(object)
      @properties = extract_from_object object, :property, self.class.property_coercions.keys
    end

    def inspect(info = nil)
      "#<#{self.class}:#{object_id} @properties=#{properties.inspect}#{info}>"
    end


    private

    def extract_from_object(object, namespace, keys = nil)
      if object
        keys ||= object.keys
        keys.each.with_object({}){ |name, res|
          res[name.to_sym] = coerce_value_or_array(
            object.is_a?(Array) ? object : object[name.to_s],
            self.class.public_send(:"#{namespace}_coercions")[name.to_sym],
          )
        }
      end
    end

    def coerce_value_or_array(value, what = nil)
      if value.is_a? Array
        value.map{ |v| coerce_or_create_class(v, what) }
      else
        coerce_or_create_class(value, what)
      end
    end

    def coerce_or_create_class(value, what)
      case what
      when Symbol
        COERCIONS[what] ? COERCIONS[what][value] : value
      when Class
        what.new(value)
      else
        value
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
