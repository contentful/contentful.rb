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
  # Transforms a Contentful::Response into a Contentful::Resource or a Contentful::Error
  # See example/resource_mapping.rb for avanced usage
  class ResourceBuilder
    DEFAULT_RESOURCE_MAPPING = {
      'Space' => Space,
      'ContentType' => ContentType,
      'Entry' => :try_dynamic_entry,
      'Asset' => Asset,
      'Array' => Array,
      'Link' => Link,
    }

    attr_reader :client, :response, :resource_mapping


    def initialize(client, response, resource_mapping = {})
      @response = response
      @client = client
      @included_resources = {}
      @resource_mapping = default_resource_mapping.merge(resource_mapping)
    end

    # Starts the parsing process.
    # Either returns an Error, or the parsed Resource
    def run
      case response.status
      when :contentful_error
        Error[response.raw.response.status].new(response)
      when :unparsable_json
        UnparsableJson.new(response)
      when :not_contentful
        Error.new(response)
      else
        begin
          create_all_resources!
        rescue UnparsableResource => error
          error
        end
      end
    end

    # PARSING MECHANISM
    # - raise error if response not valid
    # - look for included objects and parse them to resources
    # - parse main object to resource
    # - replace links in included resources with included resources
    # - replace links in main resource with included resources
    # - return main resource
    def create_all_resources!
      create_included_resources! response.object["includes"]
      res = create_resource(response.object)

      unless @included_resources.empty?
        replace_links_in_included_resources_with_included_resources
        replace_links_with_included_resources(res)
      end

      res
    end

    # Creates a single resource from the
    def create_resource(object)
      res = detect_resource_class(object).new(object, response.request, client)
      replace_children res, object
      replace_child_array res.items if res.array?

      res
    end

    # When using Dynamic Entry Mode: Automatically converts Entry to DynamicEntry
    def try_dynamic_entry(object)
      get_dynamic_entry(object) || Entry
    end

    # Finds the proper DynamicEntry class for an entry
    def get_dynamic_entry(object)
      if id = object["sys"] &&
          object["sys"]["contentType"] &&
          object["sys"]["contentType"]["sys"] &&
          object["sys"]["contentType"]["sys"]["id"]
        client.dynamic_entry_cache[id.to_sym]
      end
    end

    # Uses the resource mapping to find the proper Resource class to initialize
    # for this Response object type
    #
    # The mapping value can be a
    # - Class
    # - Proc: Will be called, expected to return the proper Class
    # - Symbol: Will be called as method of the ResourceBuilder itself
    def detect_resource_class(object)
      type = object["sys"] && object["sys"]["type"]
      case res_class = resource_mapping[type]
      when Symbol
        public_send(res_class, object)
      when Proc
        res_class[object]
      when nil
        raise UnsparsableResource.new(response)
      else
        res_class
      end
    end

    # The default mapping for #detect_resource_class
    def default_resource_mapping
      DEFAULT_RESOURCE_MAPPING
    end


    private

    def detect_child_objects(object)
      if object.is_a? Hash
        object.select{ |_,v| v.is_a?(Hash) && v.has_key?("sys") }
      else
        {}
      end
    end

    def detect_child_arrays(object)
      if object.is_a? Hash
        object.select{ |_,v|
          v.is_a?(::Array) &&
          v.first &&
          v.first.is_a?(Hash) &&
          v.first.has_key?("sys")
        }
      else
        {}
      end
    end

    def replace_children(res, object)
      object.each{ |name, potential_objects|
        detect_child_objects(potential_objects).each{ |child_name, child_object|
          res.public_send(name)[child_name.to_sym] = create_resource(child_object)
        }
        next if name == "includes"
        detect_child_arrays(potential_objects).each{ |child_name, child_array|
          replace_child_array res.public_send(name)[child_name.to_sym]
        }
      }
    end

    def replace_child_array(child_array)
      child_array.map!{ |resource_object| create_resource(resource_object) }
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
      [:properties, :sys, :fields].each{ |_what|
        if what = res.public_send(_what)
          what.each{ |name, child_res|
            replace_link_or_check_recursively child_res, what, name, res
          }
        end
      }
      if res.array?
        res.each.with_index{ |child_res, index|
          replace_link_or_check_recursively child_res, res.items, index, child_res
        }
      end
    end

    def replace_link_or_check_recursively(res, what, name, resource_to_replace)
      if res.is_a? Link
        maybe_replace_link(res, what, name)
      elsif res.is_a?(Resource) && res.sys
        replace_links_with_included_resources(resource_to_replace)
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
