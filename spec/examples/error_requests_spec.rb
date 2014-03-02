require 'spec_helper'


describe 'Error Requests' do
  it 'will return 404 (Unauthorized) if resource not found' do
    client = create_client

    expect_vcr("not found"){
      client.entry! 'not found'
    }.to raise_error(Contentful::NotFound)
  end

  it 'will return 400 (BadRequest) if ...' do
    pending
  end

  it 'will return 403 (AccessDenied) if ...' do
    pending
  end

  it 'will return 401 (Unauthorized) if no credentials given' do
    client = Contentful::Client.new(space: "wrong", access_token: "credentials")

    expect_vcr("forbidden"){
      client.entry! 'nyancat'
    }.to raise_error(Contentful::Unauthorized)
  end

  it 'will return 500 (ServerError) if ...' do
    pending
  end
end
