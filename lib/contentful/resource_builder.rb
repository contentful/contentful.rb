require_relative 'error'
require_relative 'resource'
require_relative 'space'
require_relative 'content_type'
require_relative 'entry'
require_relative 'dynamic_entry'
require_relative 'asset'
require_relative 'collection'
require_relative 'link'


module Contentful
  class ResourceBuilder
    attr_reader :response

    def initialize(given_response)
      @response = given_response
    end

    def parse
      if response.status == :contentful_error
        if %w[NotFound BadRequest AccessDenied Unauthorized ServerError].include?(response.error_id)
          Contentful.const_get(response.error_id).new(response)
        else
          Error.new(response)
        end
      elsif response.status == :unparsable_json
        UnparsableJson.new(response)
      else
        create_resource response.object
      end
    end

    def detect_resource_class(object)
      case object["sys"]["type"]
      when 'Space'
        Contentful::Space
      when 'ContentType'
        Contentful::ContentType
      when 'Entry'
        Contentful::Entry
      when 'Asset'
        Contentful::Asset
      when 'Array'
        Contentful::Collection
      when 'Link'
        Contentful::Link
      else
        fail # TODO
      end
    end

    # TODO improve / refactor

    def detect_child_objects(object)
      if object.is_a?(Hash)
        object.select{ |k,v| v.is_a?(Hash) && v.has_key?("sys") }
      else
        {}
      end
    end

    def replace_children(res, object)
      object.keys.each{ |which|
        detect_child_objects(object[which.to_s]).each{ |name, child_object|
          res.public_send(which)[name.to_sym] = create_resource(child_object)
        }
      }
    end

    def replace_children_array(res, array_field)
      items = res.public_send(array_field)
      items.map!{ |resource_object| create_resource(resource_object) }
    end

    def create_resource(object)
      res = detect_resource_class(object).new(object)
      replace_children res, object
      if res.array?
        replace_children_array(res, :items)
      end

      res
    end
  end
end

__END__

Symbol  String  Basic list of characters.
Text  String  Same as String, but can be filtered via Full-Text Search.
Date  String  See Date & Time Format.

Integer Number  Number type without decimals. Values from -2^53 to 2^53.
Float Number  Number type with decimals.

Boolean Boolean Flag, true or false.


Link  Object  See Links
Array Array List of values. Value type depends on field.items.type.
Object  Object  Arbitrary Object.