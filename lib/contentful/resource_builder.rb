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
        Contentful::Array
      when 'Link'
        Contentful::Link
      else
        fail # TODO
      end
    end

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

    def create_resource(object)
      res = detect_resource_class(object).new(object)
      replace_children res, object

      res
    end
  end
end