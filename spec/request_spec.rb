require 'spec_helper'

describe Contentful::Request do
  describe '#get' do
    it 'calls client' do
      client = create_client
      request = Contentful::Request.new(client, '/content_types', nil, 'nyancat')

      expect(client).to receive(:get).with(request)

      request.get
    end
  end

  describe '#query' do
    it 'converts arrays given in query to comma strings' do
      client = create_client
      request = Contentful::Request.new(client, '/entries', 'fields.likes[in]' => %w(jake finn))
      expect(request.query[:'fields.likes[in]']).to eq 'jake,finn'
    end
  end

  context '[single resource]' do
    let(:request)do
      Contentful::Request.new(create_client, '/content_types', nil, 'nyancat')
    end

    describe '#url' do
      it 'contais endpoint' do
        expect(request.url).to include 'content_types'
      end

      it 'contains id' do
        expect(request.url).to include 'nyancat'
      end
    end
  end

  context '[multi resource]' do
    let(:request)do
      Contentful::Request.new(create_client, '/content_types', 'something' => 'requested')
    end

    describe '#query' do
      it 'contains query' do
        expect(request.query).not_to be_empty
        expect(request.query[:something]).to eq 'requested'
      end
    end

    describe '#url' do
      it 'contais endpoint' do
        expect(request.url).to include 'content_types'
      end
    end
  end
end
