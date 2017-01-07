require 'spec_helper'

describe 'Client Configuration Options' do
  describe ':space' do
    it 'is required' do
      expect do
        Contentful::Client.new(access_token: 'b4c0n73n7fu1')
      end.to raise_error(ArgumentError)
    end
  end

  describe ':access_token' do
    it 'is required' do
      expect do
        Contentful::Client.new(space: 'cfexampleapi')
      end.to raise_error(ArgumentError)
    end
  end

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
      expect_vcr('not found')do
        create_client.content_type 'not found'
      end.to raise_error Contentful::NotFound
    end

    it 'will not raise response errors if set to false' do
      res = nil

      expect_vcr('not found')do
        res = create_client(raise_errors: false).content_type 'not found'
      end.not_to raise_error
      expect(res).to be_instance_of Contentful::NotFound
    end
  end

  describe ':dynamic_entries' do
    before :each do
      Contentful::ContentTypeCache.clear!
    end

    it 'will create dynamic entries if dynamic_entry_cache is not empty' do
      client = create_client(dynamic_entries: :manual)
      vcr('entry_cache') { client.update_dynamic_entry_cache! }
      entry = vcr('nyancat') { client.entry('nyancat') }

      expect(entry).to be_a Contentful::Entry
    end

    context ':auto' do
      it 'will call update dynamic_entry_cache on start-up' do
        vcr('entry_cache') do
          create_client(dynamic_entries: :auto)
        end
        expect(Contentful::ContentTypeCache.cache).not_to be_empty
      end
    end

    context ':manual' do
      it 'will not call #update_dynamic_entry_cache! on start-up' do
        create_client(dynamic_entries: :manual)
        expect(Contentful::ContentTypeCache.cache).to be_empty
      end
    end

    describe '#update_dynamic_entry_cache!' do
      let(:client) { create_client(dynamic_entries: :manual) }

      it 'will fetch all content_types' do
        expect(client).to receive(:content_types).with(limit: 1000) { {} }
        client.update_dynamic_entry_cache!
      end

      it 'will save dynamic entries in @dynamic_entry_cache' do
        vcr('entry_cache')do
          client.update_dynamic_entry_cache!
        end
        expect(Contentful::ContentTypeCache.cache).not_to be_empty
      end
    end

    describe '#register_dynamic_entry' do
      let(:client) { create_client(dynamic_entries: :manual) }

      it 'can be used to register a dynamic entry manually' do
        cat = vcr('content_type') { client.content_type 'cat' }
        client.register_dynamic_entry 'cat', cat

        expect(Contentful::ContentTypeCache.cache).not_to be_empty
      end
    end
  end

  describe ':api_url' do
    it 'is "cdn.contentful.com" [default]' do
      expect(
        create_client.configuration[:api_url]
      ).to eq 'cdn.contentful.com'
    end

    it 'will be used as base url' do
      expect(
        create_client(api_url: 'cdn2.contentful.com').base_url
      ).to start_with 'https://cdn2.contentful.com'
    end
  end

  describe ':api_version' do
    it 'is 1 [default]' do
      expect(
        create_client.configuration[:api_version]
      ).to eq 1
    end

    it 'will used for the http content type request header' do
      expect(
        create_client(api_version: 2).request_headers['Content-Type']
      ).to eq 'application/vnd.contentful.delivery.v2+json'
    end
  end

  describe ':authentication_mechanism' do
    describe ':header [default]' do
      it 'will add the :access_token as authorization bearer token request header' do
        expect(
          create_client.request_headers['Authorization']
        ).to eq 'Bearer b4c0n73n7fu1'
      end

      it 'will not add :access_token to query' do
        expect(
          create_client.request_query({})['access_token']
        ).to be_nil
      end
    end

    describe ':query_string' do
      it 'will add the :access_token to query' do
        expect(
          create_client(authentication_mechanism: :query_string).
              request_query({})['access_token']
        ).to eq 'b4c0n73n7fu1'
      end

      it 'will not add the :access_token as authorization bearer token request header' do
        expect(
          create_client(authentication_mechanism: :query_string).
              request_headers['Authorization']
        ).to be_nil
      end
    end
  end

  describe ':resource_mapping' do
    it 'lets you register your own resource classes for certain response types' do
      class MyBetterAsset < Contentful::Asset
        def https_image_url
          image_url.sub %r{\A//}, 'https://'
        end
      end

      client = create_client(
        resource_mapping: {
          'Asset' => MyBetterAsset,
        }
      )

      nyancat = vcr('asset') { client.asset 'nyancat' }
      expect(nyancat).to be_a MyBetterAsset
      expect(nyancat.https_image_url).to start_with 'https'
    end
  end

  describe ':entry_mapping' do
    it 'lets you register your own entry classes for certain entry types' do
      class Cat < Contentful::Entry
      end

      client = create_client(
        entry_mapping: {
          'cat' => Cat
        }
      )

      nyancat = vcr('entry') { client.entry 'nyancat' }
      finn    = vcr('human') { client.entry 'finn' }
      expect(nyancat).to be_a Cat
      expect(finn).to be_a Contentful::Entry
    end
  end
end
