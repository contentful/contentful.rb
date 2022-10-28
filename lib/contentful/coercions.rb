require_relative 'location'
require_relative 'link'

module Contentful
  # Basic Coercion
  class BaseCoercion
    attr_reader :value, :options
    def initialize(value, options = {})
      @value = value
      @options = options
    end

    # Coerces value
    def coerce(*)
      value
    end
  end

  # Coercion for String Types
  class StringCoercion < BaseCoercion
    # Coerces value to String
    def coerce(*)
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
    def coerce(*)
      value.to_i
    end
  end

  # Coercion for Float Types
  class FloatCoercion < BaseCoercion
    # Coerces value to Float
    def coerce(*)
      value.to_f
    end
  end

  # Coercion for Boolean Types
  class BooleanCoercion < BaseCoercion
    # Coerces value to Boolean
    def coerce(*)
      # rubocop:disable Style/DoubleNegation
      !!value
      # rubocop:enable Style/DoubleNegation
    end
  end

  # Coercion for Date Types
  class DateCoercion < BaseCoercion
    # Coerces value to DateTime
    def coerce(*)
      return nil if value.nil?
      return value if value.is_a?(Date)

      DateTime.parse(value)
    end
  end

  # Coercion for Location Types
  class LocationCoercion < BaseCoercion
    # Coerces value to Location
    def coerce(*)
      Location.new(value)
    end
  end

  # Coercion for Object Types
  class ObjectCoercion < BaseCoercion
    # Coerces value to hash, symbolizing each key
    def coerce(*)
      JSON.parse(JSON.dump(value), symbolize_names: true)
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
    def coerce(*)
      value.map do |e|
        options[:coercion_class].new(e).coerce
      end
    end
  end

  # Coercion for RichText Types
  class RichTextCoercion < BaseCoercion
    # Resolves includes and removes unresolvable nodes
    def coerce(configuration)
      coerce_block(value, configuration)
    end

    private

    def link?(node)
      !node['data'].is_a?(::Contentful::Entry) &&
        !node.fetch('data', {}).empty? &&
        node['data']['target']
    end

    def content_block?(node)
      !node.fetch('content', []).empty?
    end

    def coerce_block(block, configuration)
      return block unless block.is_a?(Hash) && block.key?('content')

      invalid_nodes = []
      coerced_nodes = {}
      block['content'].each_with_index do |node, index|
        if link?(node)
          link = coerce_link(node, configuration)

          if !link.nil?
            node['data']['target'] = link
          else
            invalid_nodes << index
          end
        elsif content_block?(node)
          coerced_nodes[index] = coerce_block(node, configuration)
        end
      end

      coerced_nodes.each do |index, coerced_node|
        block['content'][index] = coerced_node
      end

      invalid_nodes.each do |index|
        block['content'].delete_at(index)
      end

      block
    end

    def coerce_link(node, configuration)
      return node unless node.key?('data') && node['data'].key?('target')
      return node['data']['target'] unless node['data']['target'].is_a?(::Hash)
      return node unless node['data']['target']['sys']['type'] == 'Link'

      return nil if Support.unresolvable?(node['data']['target'], configuration[:errors])

      resource = configuration[:includes_for_single].find_link(node['data']['target'])

      # Resource is valid but unreachable
      return Link.new(node['data']['target'], configuration) if resource.nil?

      ResourceBuilder.new(
        resource,
        configuration,
        configuration[:localized],
        configuration[:depth] + 1,
        configuration[:errors]
      ).run
    end
  end
end
