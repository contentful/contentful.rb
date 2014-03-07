require_relative 'request'
require_relative 'response'
require_relative 'resource_builder'
require 'http'

module Contentful
  # The client object is initialized with a space and a key and then used
  # for querying resources from this space.
  # See README for details
  class Client
    attr_reader :configuration, :dynamic_entry_cache

    def self.get_http(url, query, headers = {})
      HTTP[headers].get(url, params: query)
    end

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
        api_url: 'cdn.contentful.com',
        api_version: 1,
        authentication_mechanism: :header,
        resource_builder: ResourceBuilder,
        raw_mode: false,
      }
    end

    def space(query = {})
      Request.new(self, '', query).get
    end

    def content_type(id, query = {})
      Request.new(self, '/content_types', query, id).get
    end

    def content_types(query = {})
      Request.new(self, '/content_types', query).get
    end

    def entry(id, query = {})
      Request.new(self, '/entries', query, id).get # , Contentul::Entry
    end

    def entries(query = {})
      Request.new(self, '/entries', query).get # , Contentul::Entry
    end

    def asset(id, query = {})
      Request.new(self, '/assets', query, id).get # , Contentul::Asset
    end

    def assets(query = {})
      Request.new(self, '/assets', query).get
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

    def get(request, build_resource = true)
      response = Response.new(
        self.class.get_http(
          base_url + request.url,
          request_query(request.query),
          request_headers,
        )
      )

      return response if !build_resource || configuration[:raw_mode]

      result = configuration[:resource_builder].new(self, response).run
      raise result if result.is_a?(Error) && configuration[:raise_errors]
      result
    end

    # Use this method together with the client's :dynamic_entries configuration.
    # See README for details.
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

