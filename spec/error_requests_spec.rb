require 'spec_helper'

class NonCachingClient < Contentful::Client
  def request_headers
    headers = super
    headers['Cf-No-Cache'] = 'foobar'
    headers
  end
end

class RetryLoggerMock < Logger
  attr_reader :retry_attempts

  def initialize(*)
    super
    @retry_attempts = 0
  end

  def info(message)
    super
    @retry_attempts += 1 if message.include?('Contentful API Rate Limit Hit! Retrying')
  end
end

describe 'Error Requests' do
  it 'will return 404 (Unauthorized) if resource not found' do
    expect_vcr('not found')do
      create_client.content_type 'not found'
    end.to raise_error(Contentful::NotFound)
  end

  it 'will return 400 (BadRequest) if invalid parameters have been passed' do
    expect_vcr('bad request')do
      create_client.entries(some: 'parameter')
    end.to raise_error(Contentful::BadRequest)
  end

  it 'will return 403 (AccessDenied) if ...' do
    skip
  end

  it 'will return 401 (Unauthorized) if wrong credentials are given' do
    client = Contentful::Client.new(space: 'wrong', access_token: 'credentials')

    expect_vcr('unauthorized'){
      client.entry('nyancat')
    }.to raise_error(Contentful::Unauthorized)
  end

  it 'will return 500 (ServerError) if ...' do
    skip
  end

  it 'will return a 429 if the ratelimit is reached and is not set to retry' do
    client = Contentful::Client.new(space: 'wrong', access_token: 'credentials', max_rate_limit_retries: 0)
    expect_vcr('ratelimit') {
      client.entry('nyancat')
    }.to raise_error(Contentful::RateLimitExceeded)
  end

  it 'will retry on 429 by default' do
    logger = RetryLoggerMock.new(STDOUT)
    client = NonCachingClient.new(
      api_url: 'cdnorigin.flinkly.com',
      space: '164vhtp008kz',
      access_token: '7699b6c6f6cee9b6abaa216c71fbcb3eee56cb6f082f57b5e21b2b50f86bdea0',
      raise_errors: true,
      logger: logger
    )

    vcr('ratelimit_retry') {
      3.times {
        client.assets
      }
    }

    expect(logger.retry_attempts).to eq 1
  end

  it 'will return 503 (ServiceUnavailable) when the service is unavailable' do
    client = Contentful::Client.new(space: 'wrong', access_token: 'credentials')

    expect_vcr('unavailable'){
      client.entry('nyancat')
    }.to raise_error(Contentful::ServiceUnavailable)
  end
end
