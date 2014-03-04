require_relative 'request'
require_relative 'response'
require_relative 'resource_builder'

require 'http'


module Contentful
  class Client
    attr_reader :configuration, :dynamic_entry_cache

    def initialize(given_configuration = {})
      @configuration = default_configuration.merge(given_configuration)
      normalize_configuration!
      validate_configuration!

      if configuration[:dynamic_entries] == :auto
        update_dynamic_entry_cache!
      else
        @dynamic_entry_cache = {}
      end
    end

    def default_configuration
      {
        secure: true,
        raise_errors: true,
        dynamic_entries: false,
        resource_builder: ResourceBuilder,
        api_url: 'cdn.contentful.com',
        api_version: 1,
        authentication_mechanism: :header,
      }
    end

    def space
      Request.new(self, '').get
    end

    def content_type(id)
      Request.new(self, '/content_types', id).get
    end

    def content_types(query = nil)
      Request.new(self, '/content_types', query).get
    end

    def asset(id)
      Request.new(self, '/assets', id).get # , Contentul::Asset
    end

    def entry(id)
      Request.new(self, '/entries', id).get # , Contentul::Entry
    end

    def entries(query_options)
      Request.new(self, '/entries', query_options).get # , Contentul::Entry
    end

    def base_url
      "http#{configuration[:secure] ? 's' : ''}://#{configuration[:api_url]}/spaces/#{configuration[:space]}"
    end

    def request_headers
      headers = { "User-Agent" => "RubyContentfulGem/#{Contentful::VERSION}" }
      headers["Authorization"] = "Bearer #{configuration[:access_token]}" if configuration[:authentication_mechanism] == :header
      headers["Content-Type"]  = "application/vnd.contentful.delivery.v#{configuration[:api_version].to_i}+json" if configuration[:api_version]

      headers
    end

    def request_query(query)
      if configuration[:authentication_mechanism] == :query_string
        query["access_token"] = configuration[:access_token]
      end

      query
    end

    def get(request, build_resources = true)
      response = Response.new(
        get_http(
          base_url + request.url,
          request_query(request.query),
          request_headers,
        )
      )

      return response unless build_resources

      result = configuration[:resource_builder].new(self, response).parse
      raise result if result.is_a?(Error) && configuration[:raise_errors]
      result
    end

    def get_http(url, query, headers = {})
      HTTP[headers].get(url, params: query)
    end


    def update_dynamic_entry_cache!
      @dynamic_entry_cache = Hash[
        content_types.map{ |ct|
          [
            ct.id.to_sym,
            DynamicEntry.create(ct),
          ]
        }
      ]
    end

    private

    def normalize_configuration!
      [:space, :access_token, :api_url].each{ |s| configuration[s] = configuration[s].to_s }
      configuration[:authentication_mechanism] = configuration[:authentication_mechanism].to_sym
    end

    def validate_configuration!
      if configuration[:space].empty?
        raise ArgumentError, "You will need to initialize a client with a :space"
      end

      if configuration[:access_token].empty?
        raise ArgumentError, "You will need to initialize a client with an :access_token"
      end

      if configuration[:api_url].empty?
        raise ArgumentError, "The client configuration needs to contain an :api_url"
      end

      unless configuration[:api_version].to_i >= 0
        raise ArgumentError, "The :api_version must be a positive number or nil"
      end

      unless [:header, :query_string].include? configuration[:authentication_mechanism]
        raise ArgumentError, "The authentication mechanism must be :header or :query_string"
      end
    end
  end
end

$client = Contentful::Client.new(
  space: 'cfexampleapi',
  access_token: 'b4c0n73n7fu1',
)
