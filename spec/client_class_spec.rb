require 'spec_helper'

describe Contentful::Client do
  describe '#get' do
    let(:client) { create_client }
    let(:proxy_client) { create_client(proxy_host: '183.207.232.194',
                                       proxy_port: 8080,
                                       secure: false) }
    let(:request) do
      Contentful::Request.new(nil, '/content_types', nil, 'cat')
    end

    it 'uses #base_url' do
      stub(client).base_url { 'https://cdn.contentful.com/spaces/cfexampleapi' }
      vcr('content_type') { client.get(request) }
      expect(client).to have_received.base_url
    end

    it 'uses #request_headers' do
      stub(client).request_headers do
        {
            'User-Agent' => 'RubyContentfulGem/0.1.0',
            'Authorization' => 'Bearer b4c0n73n7fu1',
            'Content-Type' => 'application/vnd.contentful.delivery.v1+json',
        }
      end
      vcr('content_type') { client.get(request) }
      expect(client).to have_received.request_headers
    end

    it 'uses Request#url' do
      stub(request).url { '/content_types/cat' }
      vcr('content_type') { client.get(request) }
      expect(request).to have_received.url
    end

    it 'uses Request#query' do
      stub(request).query
      vcr('content_type') { client.get(request) }
      expect(request).to have_received.query
    end

    it 'calls #get_http' do
      stub(client.class).get_http { raw_fixture('content_type') }
      client.get(request)
      expect(client.class).to have_received.get_http(client.base_url + request.url, request.query, client.request_headers, client.proxy_params)
    end

    it 'calls #get_http via proxy' do
      stub(proxy_client.class).get_http { raw_fixture('content_type') }
      proxy_client.get(request)
      expect(proxy_client.class).to have_received.get_http(proxy_client.base_url + request.url, request.query, proxy_client.request_headers, proxy_client.proxy_params)
      expect(proxy_client.proxy_params[:host]).to eq '183.207.232.194'
      expect(proxy_client.proxy_params[:port]).to eq 8080
    end

    describe 'build_resources parameter' do
      it 'returns Contentful::Resource object if second parameter is true [default]' do
        res = vcr('content_type') { client.get(request) }
        expect(res).to be_a Contentful::Resource
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
