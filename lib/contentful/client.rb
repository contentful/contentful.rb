require_relative 'request'
require_relative 'response'
require_relative 'response_parser'

require 'http'


module Contentful
  class Client
    attr_reader :configuration

    def initialize(given_configuration = {})
      @configuration = default_configuration.merge(given_configuration)
      normalize_configuration!
      validate_configuration!
    end

    def default_configuration
      {
        secure: true,
        raise_errors: true,
        response_parser: ResponseParser,
        api_url: 'cdn.contentful.com',
        api_version: 1,
        authentication_mechanism: :header,
      }
    end

    def space
      Request.new(self, '')
    end

    def entry!(id)
      Request.new(self, '/entries', id).get # , Contentul::Entry
    end

    def entries(query_options)
      Request.new(self, '/entries', query_options) # , Contentul::Entry
    end

    def base_url
      "http#{configuration[:secure] && :s}://#{configuration[:api_url]}/spaces/#{configuration[:space]}"
    end

    def request_headers
      {
        "Content-Type" => "application/vnd.contentful.delivery.v#{configuration[:api_version].to_i}+json",
        "Authorization" => "Bearer #{configuration[:access_token]}",
        "User-Agent" => "RubyContentfulGem/#{Contentful::VERSION}"
      }
    end

    def get(request)
      response = Response.new(
        get_http(
          base_url + request.url,
          request.query,
          request_headers,
        )
      )

      result = configuration[:response_parser].new(response).parse
      raise result if result.is_a?(Error) && configuration[:raise_errors]

      result
    end

    def get_http(url, query, headers = {})
      HTTP[headers].get(url, params: query)
    end


    private

    def normalize_configuration!
      %I[space access_token api_url].each{ |s| configuration[s] = configuration[s].to_s }
      configuration[:authentication_mechanism] = configuration[:authentication_mechanism].to_sym
    end

    def validate_configuration!
      if configuration[:space].empty?
        raise ArgumentError "You will need to initialize a client with a :space"
      end

      if configuration[:access_token].empty?
        raise ArgumentError "You will need to initialize a client with an :access_token"
      end

      if configuration[:api_url].empty?
        raise ArgumentError "The client configuration needs to contain an :api_url"
      end

      unless configuration[:api_version].to_i > 0
        raise ArgumentError "The :api_version must be a positive number"
      end

      unless %I[header query_string].include? configuration[:authentication_mechanism]
        raise ArgumentError "The authentication mechanism must be :header or :query_string"
      end
    end
  end
end

$client = Contentful::Client.new(
  space: 'cfexampleapi',
  access_token: 'b4c0n73n7fu1',
)


__END__

GET /spaces/:space_id Getting a Space
GET /spaces/:space_id/content_types Searching Content Types
GET /spaces/:space_id/content_types/:id Getting a Content Type
GET /spaces/:space_id/entries Searching Entries
GET /spaces/:space_id/entries/:id Getting an Entry
GET /spaces/:space_id/assets  Searching Assets
GET /spaces/:space_id/assets/:id  Getting an Asset
GET /spaces/:space_id/sync