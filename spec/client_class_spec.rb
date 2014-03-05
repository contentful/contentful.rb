require 'spec_helper'


describe Contentful::Client do
  describe '#get' do
    let(:request){
      Contentful::Request.new(self, '/content_types', nil, 'cat')
    }

    it 'uses #base_url'
    it 'uses #request_headers'
    it 'uses Request#url'
    it 'uses Request#query'
    it 'calls #get_http'

    describe 'build_resources parameter' do
      it 'returns Contentful::Resource object if second parameter is true [default]' do
        res = nil

        vcr('content_type'){
          res = create_client.get(request)
        }
        expect( res ).to be_a Contentful::Resource
      end

      it 'returns a Contentful::Response object if second parameter is not true' do
        res = nil

        vcr('content_type'){
          res = create_client.get(request, false)
        }
        expect( res ).to be_a Contentful::Response
      end
    end

  end
end
