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
    # Default configuration for Contentful::Client
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
      proxy_port: nil,
      max_rate_limit_retries: 1,
      max_rate_limit_wait: 60
    }
    # Rate Limit Reset Header Key
    RATE_LIMIT_RESET_HEADER_KEY = 'x-contentful-ratelimit-reset'

    attr_reader :configuration, :dynamic_entry_cache, :logger, :proxy

    # Wraps the actual HTTP request via proxy
    # @private
    def self.get_http(url, query, headers = {}, proxy = {})
      if proxy[:host]
        HTTP[headers].via(proxy[:host], proxy[:port], proxy[:username], proxy[:password]).get(url, params: query)
      else
        HTTP[headers].get(url, params: query)
      end
    end

    # @see _ https://github.com/contentful/contentful.rb#client-configuration-options
    # @param [Hash] given_configuration
    # @option given_configuration [String] :space Required
    # @option given_configuration [String] :access_token Required
    # @option given_configuration [String] :api_url Modifying this to 'preview.contentful.com' gives you access to our Preview API
    # @option given_configuration [String] :api_version
    # @option given_configuration [String] :default_locale
    # @option given_configuration [String] :proxy_host
    # @option given_configuration [String] :proxy_username
    # @option given_configuration [String] :proxy_password
    # @option given_configuration [Number] :proxy_port
    # @option given_configuration [Number] :max_rate_limit_retries
    # @option given_configuration [Number] :max_rate_limit_wait
    # @option given_configuration [Boolean] :gzip_encoded
    # @option given_configuration [Boolean] :raw_mode
    # @option given_configuration [false, ::Logger] :logger
    # @option given_configuration [::Logger::DEBUG, ::Logger::INFO, ::Logger::WARN, ::Logger::ERROR] :log_level
    # @option given_configuration [Boolean] :raise_errors
    # @option given_configuration [::Array<String>] :dynamic_entries
    # @option given_configuration [::Hash<String, Contentful::Resource>] :resource_mapping
    # @option given_configuration [::Hash<String, Contentful::Resource>] :entry_mapping
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

    # @private
    def setup_logger
      @logger = configuration[:logger]
      logger.level = configuration[:log_level] if logger
    end

    # @private
    def proxy_params
      {
        host: configuration[:proxy_host],
        port: configuration[:proxy_port],
        username: configuration[:proxy_username],
        password: configuration[:proxy_password]
      }
    end

    # Returns the default configuration
    # @private
    def default_configuration
      DEFAULT_CONFIGURATION.dup
    end

    # Gets the client's space
    #
    # @param [Hash] query
    #
    # @return [Contentful::Space]
    def space(query = {})
      Request.new(self, '', query).get
    end

    # Gets a specific content type
    #
    # @param [String] id
    # @param [Hash] query
    #
    # @return [Contentful::ContentType]
    def content_type(id, query = {})
      Request.new(self, '/content_types', query, id).get
    end

    # Gets a collection of content types
    #
    # @param [Hash] query
    #
    # @return [Contentful::Array<Contentful::ContentType>]
    def content_types(query = {})
      Request.new(self, '/content_types', query).get
    end

    # Gets a specific entry
    #
    # @param [String] id
    # @param [Hash] query
    #
    # @return [Contentful::Entry]
    def entry(id, query = {})
      Request.new(self, '/entries', query, id).get
    end

    # Gets a collection of entries
    #
    # @param [Hash] query
    #
    # @return [Contentful::Array<Contentful::Entry>]
    def entries(query = {})
      normalize_select!(query)
      Request.new(self, '/entries', query).get
    end

    # Gets a specific asset
    #
    # @param [String] id
    # @param [Hash] query
    #
    # @return [Contentful::Asset]
    def asset(id, query = {})
      Request.new(self, '/assets', query, id).get
    end

    # Gets a collection of assets
    #
    # @param [Hash] query
    #
    # @return [Contentful::Array<Contentful::Asset>]
    def assets(query = {})
      normalize_select!(query)
      Request.new(self, '/assets', query).get
    end

    # Returns the base url for all of the client's requests
    # @private
    def base_url
      "http#{configuration[:secure] ? 's' : ''}://#{configuration[:api_url]}/spaces/#{configuration[:space]}"
    end

    # Returns the headers used for the HTTP requests
    # @private
    def request_headers
      headers = { 'User-Agent' => "RubyContentfulGem/#{Contentful::VERSION}" }
      headers['Authorization'] = "Bearer #{configuration[:access_token]}" if configuration[:authentication_mechanism] == :header
      headers['Content-Type'] = "application/vnd.contentful.delivery.v#{configuration[:api_version].to_i}+json" if configuration[:api_version]
      headers['Accept-Encoding'] = 'gzip' if configuration[:gzip_encoded]
      headers
    end

    # Patches a query hash with the client configurations for queries
    # @private
    def request_query(query)
      if configuration[:authentication_mechanism] == :query_string
        query['access_token'] = configuration[:access_token]
      end
      query
    end

    # Get a Contentful::Request object
    # Set second parameter to false to deactivate Resource building and
    # return Response objects instead
    #
    # @private
    def get(request, build_resource = true)
      retries_left = configuration[:max_rate_limit_retries]
      begin
        response = run_request(request)

        return response if !build_resource || configuration[:raw_mode]

        result = do_build_resource(response)

        fail result if result.is_a?(Error) && configuration[:raise_errors]
      rescue Contentful::RateLimitExceeded => rate_limit_error
        reset_time = rate_limit_error.response.raw[RATE_LIMIT_RESET_HEADER_KEY].to_i
        if should_retry(retries_left, reset_time, configuration[:max_rate_limit_wait])
          retries_left -= 1
          retry_message = 'Contentful API Rate Limit Hit! '
          retry_message += "Retrying - Retries left: #{retries_left}"
          retry_message += "- Time until reset (seconds): #{reset_time}"
          logger.info(retry_message) if logger
          sleep(reset_time * Random.new.rand(1.0..1.2))
          retry
        end

        raise
      end

      result
    end

    # @private
    def should_retry(retries_left, reset_time, max_wait)
      retries_left > 0 && max_wait > reset_time
    end

    # Runs request and parses Response
    # @private
    def run_request(request)
      url = request.absolute? ? request.url : base_url + request.url
      logger.info(request: { url: url, query: request.query, header: request_headers }) if logger
      Response.new(
        self.class.get_http(
          url,
          request_query(request.query),
          request_headers,
          proxy_params
        ), request
      )
    end

    # Runs Resource Builder
    # @private
    def do_build_resource(response)
      logger.debug(response: response) if logger
      configuration[:resource_builder].new(
        self,
        response,
        configuration[:resource_mapping],
        configuration[:entry_mapping],
        configuration[:default_locale]
      ).run
    end

    # Use this method together with the client's :dynamic_entries configuration.
    # See README for details.
    # @private
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
    # @private
    def register_dynamic_entry(key, klass)
      @dynamic_entry_cache[key.to_sym] = klass
    end

    # Create a new synchronisation object
    #
    # @param [Hash, String] options Options or Sync URL
    #
    # @note You will need to call #each_page or #first_page on it
    #
    # @return [Contentful::Sync]
    def sync(options = { initial: true })
      Sync.new(self, options)
    end

    private

    # If the query contains the :select operator, we enforce :sys properties.
    # The SDK requires sys.type to function properly, but as other of our SDKs
    # require more parts of the :sys properties, we decided that every SDK should
    # include the complete :sys block to provide consistency accross our SDKs.
    def normalize_select!(query)
      return unless query.key?(:select)

      query[:select] = query[:select].split(',').map(&:strip) if query[:select].is_a? String
      query[:select] = query[:select].reject { |p| p.start_with?('sys.') }
      query[:select] << 'sys' unless query[:select].include?('sys')
    end

    def normalize_configuration!
      [:space, :access_token, :api_url, :default_locale].each { |s| configuration[s] = configuration[s].to_s }
      configuration[:authentication_mechanism] = configuration[:authentication_mechanism].to_sym
    end

    def validate_configuration!
      fail ArgumentError, 'You will need to initialize a client with a :space' if configuration[:space].empty?

      fail ArgumentError, 'You will need to initialize a client with an :access_token' if configuration[:access_token].empty?

      fail ArgumentError, 'The client configuration needs to contain an :api_url' if configuration[:api_url].empty?

      fail ArgumentError, 'The client configuration needs to contain a :default_locale' if configuration[:default_locale].empty?

      fail ArgumentError, 'The :api_version must be a positive number or nil' unless configuration[:api_version].to_i >= 0

      fail ArgumentError, 'The authentication mechanism must be :header or :query_string' unless [:header, :query_string].include?(
        configuration[:authentication_mechanism]
      )

      fail ArgumentError, 'The :dynamic_entries mode must be :auto or :manual' unless [:auto, :manual].include?(
        configuration[:dynamic_entries]
      )
    end
  end
end
