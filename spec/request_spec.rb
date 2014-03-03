require 'spec_helper'

describe Contentful::Request do
  describe '#get' do
    it 'calls client' do
      client = create_client
      stub(client).get
      request = Contentful::Request.new(client, '/content_types', 'nyancat')
      request.get
      expect( client ).to have_received.get(request)
    end
  end

  context '[single resource]' do
    let(:request){
      Contentful::Request.new(create_client, '/content_types', 'nyancat')
    }

    describe '#query' do
      it 'is empty' do
        expect( request.query ).to be_nil
      end
    end

    describe '#url' do
      it 'contais endpoint' do
        expect( request.url ).to include 'content_types'
      end

      it 'contains id' do
        expect( request.url ).to include 'nyancat'
      end
    end
  end

  context '[multi resource]' do
    let(:request){
      Contentful::Request.new(create_client, '/content_types', {"something" => 'requested'})
    }

    describe '#query' do
      it 'contains query' do
        expect( request.query ).not_to be_empty
        expect( request.query["something"] ).to eq 'requested'
      end
    end

    describe '#url' do
      it 'contais endpoint' do
        expect( request.url ).to include 'content_types'
      end
    end
  end
end
