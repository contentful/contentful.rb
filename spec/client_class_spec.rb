require 'spec_helper'

describe Contentful::Client do
  describe '#get' do
    let(:client) { create_client }
    let(:proxy_client) { create_client(proxy_host: '183.207.232.194',
                                       proxy_port: 8080,
                                       secure: false) }
    let(:request) { Contentful::Request.new(nil, '/content_types', nil, 'cat') }

    it 'uses #base_url' do
      expect(client).to receive(:base_url).and_call_original

      vcr('content_type') {
        client.get(request)
      }
    end

    it 'uses #request_headers' do
      expect(client).to receive(:request_headers).and_call_original
      vcr('content_type') { client.get(request) }
    end

    it 'uses Request#url' do
      expect(request).to receive(:url).and_call_original
      vcr('content_type') { client.get(request) }
    end

    it 'uses Request#query' do
      expect(request).to receive(:query).twice.and_call_original
      vcr('content_type') { client.get(request) }
    end

    it 'calls #get_http' do
      expect(client.class).to receive(:get_http).with(client.base_url + request.url, request.query, client.request_headers, client.proxy_params) { raw_fixture('content_type') }
      client.get(request)
    end

    it 'calls #get_http via proxy' do
      expect(proxy_client.class).to receive(:get_http).with(proxy_client.base_url + request.url, request.query, proxy_client.request_headers, proxy_client.proxy_params) { raw_fixture('content_type') }
      proxy_client.get(request)
      expect(proxy_client.proxy_params[:host]).to eq '183.207.232.194'
      expect(proxy_client.proxy_params[:port]).to eq 8080
    end

    describe 'build_resources parameter' do
      it 'returns Contentful::Resource object if second parameter is true [default]' do
        res = vcr('content_type') { client.get(request) }
        expect(res).to be_a Contentful::BaseResource
      end

      it 'returns a Contentful::Response object if second parameter is not true' do
        res = vcr('content_type') { client.get(request, false) }
        expect(res).to be_a Contentful::Response
      end
    end

  end

  describe '#sync' do
    it 'creates a new Sync object' do
      expect(create_client.sync).to be_a Contentful::Sync
    end
  end
end
