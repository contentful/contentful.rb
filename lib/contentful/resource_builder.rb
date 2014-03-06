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
  # PARSING MECHANISM
  # - raise error if response not valid
  # - look for included objects and parse them to resources
  # - parse main object to resource
  # - replace links in included resources with included resources
  # - replace links in main resource with included resources
  # - return main resource
  class ResourceBuilder
    attr_reader :client, :response

    def initialize(client, response)
      @response = response
      @client = client
      @included_resources = {}
    end

    def run
      if response.status == :contentful_error
        if %w[NotFound BadRequest AccessDenied Unauthorized ServerError].include?(response.error_id)
          Contentful.const_get(response.error_id).new(response)
        else
          Error.new(response)
        end
      elsif response.status == :unparsable_json
        UnparsableJson.new(response)
      else
        create_all_resources! response
      end
    end

    def create_all_resources!(response)
      create_included_resources! response.object["includes"]
      res = create_resource(response.object)

      replace_links_in_included_resources_with_included_resources
      replace_links_with_included_resources(res)

      res
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

    def create_included_resources!(included_objects)
      if included_objects
        included_objects.each{ |type, objects|
          @included_resources[type] = Hash[
            objects.map{ |object|
              res = create_resource(object)
              [res.id, res]
            }
          ]
        }
      end
    end

    def replace_links_with_included_resources(res)
      unless @included_resources.empty?
        [:properties, :sys, :fields].each{ |_what|
          if what = res.public_send(_what)
            what.each{ |name, resource|
              if  resource.is_a? Link
                maybe_replace_link(resource, what, name)
              elsif resource.is_a?(Resource) && resource.sys
                replace_links_with_included_resources(res)
              end
            }
          end
        }
        if res.array?
          res.each.with_index{ |resource, index|
            if resource.is_a? Link
              maybe_replace_link(resource, res.items, index)
            else
              replace_links_with_included_resources(resource)
            end
          }
        end
      end
    end

    def replace_links_in_included_resources_with_included_resources
      @included_resources.each{ |_, for_type|
        for_type.each{ |_, res|
          replace_links_with_included_resources(res)
        }
      }
    end

    def maybe_replace_link(resource, parent, index)
      if  @included_resources[resource.link_type] &&
          @included_resources[resource.link_type].has_key?(resource.id)
        parent[index] = @included_resources[resource.link_type][resource.id]
      end
    end

  end
end
