require 'spec_helper'

describe 'Error Requests' do
  it 'will return 404 (Unauthorized) if resource not found' do
    expect_vcr('not found')do
      create_client.entry 'not found'
    end.to raise_error(Contentful::NotFound)
  end

  it 'will return 400 (BadRequest) if invalid parameters have been passed' do
    expect_vcr('bad request')do
      create_client.entries(some: 'parameter')
    end.to raise_error(Contentful::BadRequest)
  end

  it 'will return 403 (AccessDenied) if ...' do
    pending
  end

  it 'will return 401 (Unauthorized) if wrong credentials given' do
    client = Contentful::Client.new(space: 'wrong', access_token: 'credentials')

    expect_vcr('unauthorized'){
      client.entry 'nyancat'
    }.to raise_error(Contentful::Unauthorized)
  end

  it 'will return 500 (ServerError) if ...' do
    pending
  end
end
