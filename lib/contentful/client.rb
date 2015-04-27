require_relative 'request'
require_relative 'response'
require_relative 'resource_builder'
require_relative 'sync'

require 'http'
require 'logger'

module Contentful
  # The client object is initialized with a space and a key and then used
  # for querying resources from this space.
  # See README for details
  class Client
    DEFAULT_CONFIGURATION = {
      secure: true,
      raise_errors: true,
      dynamic_entries: :manual,
      api_url: 'cdn.contentful.com',
      api_version: 1,
      authentication_mechanism: :header,
      resource_builder: ResourceBuilder,
      resource_mapping: {},
      entry_mapping: {},
      default_locale: 'en-US',
      raw_mode: false,
      gzip_encoded: true,
      logger: false,
      log_level: Logger::INFO,
      proxy_host: nil,
      proxy_username: nil,
      proxy_password: nil,
      proxy_port: nil
    }

    attr_reader :configuration, :dynamic_entry_cache, :logger, :proxy

    # Wraps the actual HTTP request via proxy
    def self.get_http(url, query, headers = {}, proxy = {})
      if proxy[:host]
        HTTP[headers].via(proxy[:host], proxy[:port], proxy[:username], proxy[:password]).get(url, params: query)
      else
        HTTP[headers].get(url, params: query)
      end
    end

    def initialize(given_configuration = {})
      @configuration = default_configuration.merge(given_configuration)
      normalize_configuration!
      validate_configuration!
      setup_logger

      if configuration[:dynamic_entries] == :auto
        update_dynamic_entry_cache!
      else
        @dynamic_entry_cache = {}
      end
    end

    def setup_logger
      @logger = configuration[:logger]
      logger.level = configuration[:log_level] if logger
    end

    def proxy_params
      {
        host: configuration[:proxy_host],
        port: configuration[:proxy_port],
        username: configuration[:proxy_username],
        password: configuration[:proxy_password]
      }
    end

    # Returns the default configuration
    def default_configuration
      DEFAULT_CONFIGURATION.dup
    end

    # Gets the client's space
    # Takes an optional hash of query options
    # Returns a Contentful::Space
    def space(query = {})
      Request.new(self, '', query).get
    end

    # Gets a specific content type
    # Takes an id and an optional hash of query options
    # Returns a Contentful::ContentType
    def content_type(id, query = {})
      Request.new(self, '/content_types', query, id).get
    end

    # Gets a collection of content types
    # Takes an optional hash of query options
    # Returns a Contentful::Array of Contentful::ContentType
    def content_types(query = {})
      Request.new(self, '/content_types', query).get
    end

    # Gets a specific entry
    # Takes an id and an optional hash of query options
    # Returns a Contentful::Entry
    def entry(id, query = {})
      Request.new(self, '/entries', query, id).get
    end

    # Gets a collection of entries
    # Takes an optional hash of query options
    # Returns a Contentful::Array of Contentful::Entry
    def entries(query = {})
      Request.new(self, '/entries', query).get
    end

    # Gets a specific asset
    # Takes an id and an optional hash of query options
    # Returns a Contentful::Asset
    def asset(id, query = {})
      Request.new(self, '/assets', query, id).get
    end

    # Gets a collection of assets
    # Takes an optional hash of query options
    # Returns a Contentful::Array of Contentful::Asset
    def assets(query = {})
      Request.new(self, '/assets', query).get
    end

    # Returns the base url for all of the client's requests
    def base_url
      "http#{configuration[:secure] ? 's' : ''}://#{configuration[:api_url]}/spaces/#{configuration[:space]}"
    end

    # Returns the headers used for the HTTP requests
    def request_headers
      headers = { 'User-Agent' => "RubyContentfulGem/#{Contentful::VERSION}" }
      headers['Authorization'] = "Bearer #{configuration[:access_token]}" if configuration[:authentication_mechanism] == :header
      headers['Content-Type'] = "application/vnd.contentful.delivery.v#{configuration[:api_version].to_i}+json" if configuration[:api_version]
      headers['Accept-Encoding'] = 'gzip' if configuration[:gzip_encoded]
      headers
    end

    # Patches a query hash with the client configurations for queries
    def request_query(query)
      if configuration[:authentication_mechanism] == :query_string
        query['access_token'] = configuration[:access_token]
      end
      query
    end

    # Get a Contentful::Request object
    # Set second parameter to false to deactivate Resource building and
    # return Response objects instead
    def get(request, build_resource = true)
      url = request.absolute? ? request.url : base_url + request.url
      logger.info(request: { url: url, query: request.query, header: request_headers }) if logger
      response = Response.new(
          self.class.get_http(
              url,
              request_query(request.query),
              request_headers,
              proxy_params
          ), request
      )

      return response if !build_resource || configuration[:raw_mode]
      logger.debug(response: response) if logger
      result = configuration[:resource_builder].new(
          self,
          response,
          configuration[:resource_mapping],
          configuration[:entry_mapping],
          configuration[:default_locale]
      ).run

      fail result if result.is_a?(Error) && configuration[:raise_errors]
      result
    end

    # Use this method together with the client's :dynamic_entries configuration.
    # See README for details.
    def update_dynamic_entry_cache!
      @dynamic_entry_cache = Hash[
                             content_types(limit: 1000).map do |ct|
                               [
                                 ct.id.to_sym,
                                 DynamicEntry.create(ct)
                               ]
                             end
      ]
    end

    # Use this method to manually register a dynamic entry
    # See examples/dynamic_entries.rb
    def register_dynamic_entry(key, klass)
      @dynamic_entry_cache[key.to_sym] = klass
    end

    # Create a new synchronisation object
    # Takes sync options or a sync_url
    # You will need to call #each_page or #first_page on it
    def sync(options = { initial: true })
      Sync.new(self, options)
    end

    private

    def normalize_configuration!
      [:space, :access_token, :api_url, :default_locale].each { |s| configuration[s] = configuration[s].to_s }
      configuration[:authentication_mechanism] = configuration[:authentication_mechanism].to_sym
    end

    def validate_configuration!
      if configuration[:space].empty?
        fail ArgumentError, 'You will need to initialize a client with a :space'
      end

      if configuration[:access_token].empty?
        fail ArgumentError, 'You will need to initialize a client with an :access_token'
      end

      if configuration[:api_url].empty?
        fail ArgumentError, 'The client configuration needs to contain an :api_url'
      end

      if configuration[:default_locale].empty?
        fail ArgumentError, 'The client configuration needs to contain a :default_locale'
      end

      unless configuration[:api_version].to_i >= 0
        fail ArgumentError, 'The :api_version must be a positive number or nil'
      end

      unless [:header, :query_string].include? configuration[:authentication_mechanism]
        fail ArgumentError, 'The authentication mechanism must be :header or :query_string'
      end

      unless [:auto, :manual].include? configuration[:dynamic_entries]
        fail ArgumentError, 'The :dynamic_entries mode must be :auto or :manual'
      end
    end
  end
end
