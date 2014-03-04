require_relative 'error'
require_relative 'resource'
require_relative 'space'
require_relative 'content_type'
require_relative 'entry'
require_relative 'dynamic_entry'
require_relative 'asset'
require_relative 'array'
require_relative 'link'


module Contentful
  class ResourceBuilder
    attr_reader :client, :response

    def initialize(client, response)
      @response = response
      @client = client
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
      case object["sys"] && object["sys"]["type"]
      when 'Space'
        Contentful::Space
      when 'ContentType'
        Contentful::ContentType
      when 'Entry'
        if @client.configuration[:dynamic_entries]
          get_dynamic_entry(object) || Contentful::Entry
        else
          Contentful::Entry
        end
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

    def get_dynamic_entry(object)
      if id = object["sys"] &&
          object["sys"]["contentType"] &&
          object["sys"]["contentType"]["sys"] &&
          object["sys"]["contentType"]["sys"]["id"]
        client.dynamic_entry_cache[id.to_sym]
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
      res = detect_resource_class(object).new(object, client)
      replace_children res, object
      if res.array?
        replace_children_array(res, :items)
      end

      res
    end
  end
end
