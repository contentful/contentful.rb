require 'spec_helper'


describe Contentful::Client do
  describe '#get' do
    let(:client){ create_client }
    let(:request){
      Contentful::Request.new(nil, '/content_types', nil, 'cat')
    }


    it 'uses #base_url' do
      stub(client).base_url{ "https://cdn.contentful.com/spaces/cfexampleapi" }
      vcr('content_type'){ client.get(request) }
      expect( client ).to have_received.base_url
    end

    it 'uses #request_headers' do
      stub(client).request_headers{{
        'User-Agent' => 'RubyContentfulGem/0.1.0',
        'Authorization' => 'Bearer b4c0n73n7fu1',
        'Content-Type' => 'application/vnd.contentful.delivery.v1+json',
      }}
      vcr('content_type'){ client.get(request) }
      expect( client ).to have_received.request_headers
    end

    it 'uses Request#url' do
      stub(request).url{ "/content_types/cat" }
      vcr('content_type'){ client.get(request) }
      expect( request ).to have_received.url
    end

    it 'uses Request#query' do
      stub(request).query
      vcr('content_type'){ client.get(request) }
      expect( request ).to have_received.query
    end

    it 'calls #get_http' do
      stub(client).get_http{ raw_fixture('content_type') }
      client.get(request)
      expect( client ).to have_received.get_http(client.base_url + request.url, request.query, client.request_headers)
    end

    describe 'build_resources parameter' do
      it 'returns Contentful::Resource object if second parameter is true [default]' do
        res = vcr('content_type'){ client.get(request) }
        expect( res ).to be_a Contentful::Resource
      end

      it 'returns a Contentful::Response object if second parameter is not true' do
        res = vcr('content_type'){ client.get(request, false) }
        expect( res ).to be_a Contentful::Response
      end
    end

  end
end
