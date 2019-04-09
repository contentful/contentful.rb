require_relative 'request'
require_relative 'response'
require_relative 'resource_builder'
require_relative 'sync'
require_relative 'content_type_cache'

require 'http'
require 'logger'
require 'rbconfig'

module Contentful
  # The client object is initialized with a space and a key and then used
  # for querying resources from this space.
  # See README for details
  class Client
    # Default configuration for Contentful::Client
    DEFAULT_CONFIGURATION = {
      secure: true,
      raise_errors: true,
      raise_for_empty_fields: true,
      dynamic_entries: :manual,
      api_url: 'cdn.contentful.com',
      api_version: 1,
      environment: 'master',
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
      timeout_connect: nil,
      timeout_read: nil,
      timeout_write: nil,
      max_rate_limit_retries: 1,
      max_rate_limit_wait: 60,
      max_include_resolution_depth: 20,
      use_camel_case: false,
      application_name: nil,
      application_version: nil,
      integration_name: nil,
      integration_version: nil
    }

    attr_reader :configuration, :logger, :proxy

    # Wraps the actual HTTP request via proxy
    # @private
    def self.get_http(url, query, headers = {}, proxy = {}, timeout = {})
      http = HTTP[headers]
      http = http.timeout(timeout) if timeout.any?
      if proxy[:host]
        http.via(proxy[:host], proxy[:port], proxy[:username], proxy[:password]).get(url, params: query)
      else
        http.get(url, params: query)
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
    # @option given_configuration [Number] :timeout_read
    # @option given_configuration [Number] :timeout_write
    # @option given_configuration [Number] :timeout_connect
    # @option given_configuration [Number] :max_rate_limit_retries
    # @option given_configuration [Number] :max_rate_limit_wait
    # @option given_configuration [Number] :max_include_resolution_depth
    # @option given_configuration [Boolean] :use_camel_case
    # @option given_configuration [Boolean] :gzip_encoded
    # @option given_configuration [Boolean] :raw_mode
    # @option given_configuration [false, ::Logger] :logger
    # @option given_configuration [::Logger::DEBUG, ::Logger::INFO, ::Logger::WARN, ::Logger::ERROR] :log_level
    # @option given_configuration [Boolean] :raise_errors
    # @option given_configuration [Boolean] :raise_for_empty_fields
    # @option given_configuration [::Array<String>] :dynamic_entries
    # @option given_configuration [::Hash<String, Contentful::Resource>] :resource_mapping
    # @option given_configuration [::Hash<String, Contentful::Resource>] :entry_mapping
    # @option given_configuration [String] :application_name
    # @option given_configuration [String] :application_version
    # @option given_configuration [String] :integration_name
    # @option given_configuration [String] :integration_version
    def initialize(given_configuration = {})
      @configuration = default_configuration.merge(given_configuration)
      normalize_configuration!
      validate_configuration!
      setup_logger

      update_dynamic_entry_cache! if configuration[:dynamic_entries] == :auto
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

    # @private
    def timeout_params
      {
        connect: configuration[:timeout_connect],
        read: configuration[:timeout_read],
        write: configuration[:timeout_write]
      }.reject { |_, value| value.nil? }
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
      Request.new(self, environment_url('/content_types'), query, id).get
    end

    # Gets a collection of content types
    #
    # @param [Hash] query
    #
    # @return [Contentful::Array<Contentful::ContentType>]
    def content_types(query = {})
      Request.new(self, environment_url('/content_types'), query).get
    end

    # Gets a specific entry
    #
    # @param [String] id
    # @param [Hash] query
    #
    # @return [Contentful::Entry]
    def entry(id, query = {})
      normalize_select!(query)
      query['sys.id'] = id
      entries = Request.new(self, environment_url('/entries'), query).get

      return entries if configuration[:raw_mode]

      entries.first
    end

    # Gets a collection of entries
    #
    # @param [Hash] query
    #
    # @return [Contentful::Array<Contentful::Entry>]
    def entries(query = {})
      normalize_select!(query)
      Request.new(self, environment_url('/entries'), query).get
    end

    # Gets a specific asset
    #
    # @param [String] id
    # @param [Hash] query
    #
    # @return [Contentful::Asset]
    def asset(id, query = {})
      Request.new(self, environment_url('/assets'), query, id).get
    end

    # Gets a collection of assets
    #
    # @param [Hash] query
    #
    # @return [Contentful::Array<Contentful::Asset>]
    def assets(query = {})
      normalize_select!(query)
      Request.new(self, environment_url('/assets'), query).get
    end

    # Gets a collection of locales for the current environment
    #
    # @param [Hash] query
    #
    # @return [Contentful::Array<Contentful::Locale>]
    def locales(query = {})
      Request.new(self, environment_url('/locales'), query).get
    end

    # Returns the base url for all of the client's requests
    # @private
    def base_url
      "http#{configuration[:secure] ? 's' : ''}://#{configuration[:api_url]}/spaces/#{configuration[:space]}"
    end

    # Returns the url aware of the currently selected environment
    # @private
    def environment_url(path)
      "/environments/#{configuration[:environment]}#{path}"
    end

    # Returns the formatted part of the X-Contentful-User-Agent header
    # @private
    def format_user_agent_header(key, values)
      header = "#{key} #{values[:name]}"
      header = "#{header}/#{values[:version]}" if values[:version]
      "#{header};"
    end

    # Returns the X-Contentful-User-Agent sdk data
    # @private
    def sdk_info
      { name: 'contentful.rb', version: ::Contentful::VERSION }
    end

    # Returns the X-Contentful-User-Agent app data
    # @private
    def app_info
      { name: configuration[:application_name], version: configuration[:application_version] }
    end

    # Returns the X-Contentful-User-Agent integration data
    # @private
    def integration_info
      { name: configuration[:integration_name], version: configuration[:integration_version] }
    end

    # Returns the X-Contentful-User-Agent platform data
    # @private
    def platform_info
      { name: 'ruby', version: RUBY_VERSION }
    end

    # Returns the X-Contentful-User-Agent os data
    # @private
    def os_info
      os_name = case ::RbConfig::CONFIG['host_os']
                when /(cygwin|mingw|mswin|windows)/i then 'Windows'
                when /(darwin|macruby|mac os)/i      then 'macOS'
                when /(linux|bsd|aix|solarix)/i      then 'Linux'
                end
      { name: os_name, version: Gem::Platform.local.version }
    end

    # Returns the X-Contentful-User-Agent
    # @private
    def contentful_user_agent
      header = {
        'sdk' => sdk_info,
        'app' => app_info,
        'integration' => integration_info,
        'platform' => platform_info,
        'os' => os_info
      }

      result = []
      header.each do |key, values|
        next unless values[:name]
        result << format_user_agent_header(key, values)
      end
      result.join(' ')
    end

    # Returns the headers used for the HTTP requests
    # @private
    def request_headers
      headers = { 'X-Contentful-User-Agent' => contentful_user_agent }
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
      result = nil
      begin
        response = run_request(request)

        return response if !build_resource || configuration[:raw_mode]

        return fail_response(response) if response.status != :ok

        result = do_build_resource(response)
      rescue UnparsableResource => error
        raise error if configuration[:raise_errors]
        return error
      rescue Contentful::RateLimitExceeded => rate_limit_error
        reset_time = rate_limit_error.reset_time.to_i
        if should_retry(retries_left, reset_time, configuration[:max_rate_limit_wait])
          retries_left -= 1
          logger.info(retry_message(retries_left, reset_time)) if logger
          sleep(reset_time * Random.new.rand(1.0..1.2))
          retry
        end

        raise
      end

      result
    end

    # @private
    def retry_message(retries_left, reset_time)
      message = 'Contentful API Rate Limit Hit! '
      message += "Retrying - Retries left: #{retries_left}"
      message += "- Time until reset (seconds): #{reset_time}"
      message
    end

    # @private
    def fail_response(response)
      fail response.object if configuration[:raise_errors]
      response.object
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
          proxy_params,
          timeout_params
        ), request
      )
    end

    # Runs Resource Builder
    # @private
    def do_build_resource(response)
      logger.debug(response: response) if logger
      configuration[:resource_builder].new(
        response.object,
        configuration.merge(endpoint: response.request.endpoint),
        (response.request.query || {}).fetch(:locale, nil) == '*',
        0
      ).run
    end

    # Use this method together with the client's :dynamic_entries configuration.
    # See README for details.
    # @private
    def update_dynamic_entry_cache!
      return if configuration[:raw_mode]
      content_types(limit: 1000).map do |ct|
        ContentTypeCache.cache_set(configuration[:space], ct.id, ct)
      end
    end

    # Use this method to manually register a dynamic entry
    # See examples/dynamic_entries.rb
    # @private
    def register_dynamic_entry(key, klass)
      ContentTypeCache.cache_set(configuration[:space], key, klass)
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
      %i[space access_token api_url default_locale].each { |s| configuration[s] = configuration[s].to_s }
      configuration[:authentication_mechanism] = configuration[:authentication_mechanism].to_sym
    end

    def validate_configuration!
      fail ArgumentError, 'You will need to initialize a client with a :space' if configuration[:space].empty?
      fail ArgumentError, 'You will need to initialize a client with an :access_token' if configuration[:access_token].empty?
      fail ArgumentError, 'The client configuration needs to contain an :api_url' if configuration[:api_url].empty?
      fail ArgumentError, 'The client configuration needs to contain a :default_locale' if configuration[:default_locale].empty?
      fail ArgumentError, 'The :api_version must be a positive number or nil' unless configuration[:api_version].to_i >= 0
      fail ArgumentError, 'The authentication mechanism must be :header or :query_string' unless %i[header query_string].include?(
        configuration[:authentication_mechanism]
      )
      fail ArgumentError, 'The :dynamic_entries mode must be :auto or :manual' unless %i[auto manual].include?(
        configuration[:dynamic_entries]
      )
      fail ArgumentError, 'Timeout parameters must be all omitted or all present' unless timeout_params.empty? || timeout_params.length == 3
    end
  end
end
