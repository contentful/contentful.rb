require 'spec_helper'
require 'contentful'


describe 'Client Configuration Options' do
  describe ':secure' do
    it 'will use https [default]' do
      expect(
        create_client.base_url
      ).to start_with 'https://'
    end

    it 'will use http when secure set to false' do
      expect(
        create_client(secure: false).base_url
      ).to start_with 'http://'
    end
  end

  describe ':raise_errors' do
    it 'will raise response errors if set to true [default]' do
      expect_vcr('not found'){
        create_client.entry! "not found"
      }.to raise_error Contentful::NotFound
    end

    it 'will not raise response errors if set to false' do
      res = nil
      expect_vcr('not found'){
        res = create_client(raise_errors: false).entry! "not found"
      }.not_to raise_error
      expect( res ).to be_instance_of Contentful::NotFound
    end
  end

  describe ':api_url' do
    it 'is "cdn.contentful.com" [default]' do
      expect(
        create_client.configuration[:api_url]
      ).to eq "cdn.contentful.com"
    end

    it 'will be used as base url' do
      expect(
        create_client(api_url: "cdn2.contentful.com").base_url
      ).to start_with "https://cdn2.contentful.com"
    end
  end

  describe ':api_version' do
    it 'is 1 [default]' do
      expect(
        create_client.configuration[:api_version]
      ).to eq 1
    end

    it 'is used for the http content type request header' do
      expect(
        create_client(api_version: 2).request_headers['Content-Type']
      ).to eq "application/vnd.contentful.delivery.v2+json"
    end
  end


end
