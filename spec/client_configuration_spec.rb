require 'spec_helper'

describe 'Client Configuration Options' do
  describe ':space' do
    it 'is required' do
      expect do
        Contentful::Client.new(access_token: 'b4c0n73n7fu1')
      end.to raise_error(ArgumentError)
    end
  end

  describe ':secure' do
    it 'will use https when secure set to true' do
      expect(
        create_client(secure: true).base_url
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
      expect_vcr('notfound')do
        create_client.entry 'notfound'
      end.to raise_error Contentful::NotFound
    end

    it 'will not raise response errors if set to false' do
      res = nil

      expect_vcr('notfound')do
        res = create_client(raise_errors: false).entry 'notfound'
      end.not_to raise_error
      expect(res).to be_instance_of Contentful::NotFound
    end
  end

  describe ':dynamic_entries' do
    it 'will create static if dynamic_entry_cache is empty' do
      entry = vcr('nyancat') { create_client(dynamic_entries: :manual).entry('nyancat') }
      expect(entry).not_to be_a Contentful::DynamicEntry
    end

    it 'will create dynamic entries if dynamic_entry_cache is not empty' do
      client = create_client(dynamic_entries: :manual)
      vcr('entry_cache') { client.update_dynamic_entry_cache! }
      entry = vcr('nyancat') { client.entry('nyancat') }

      expect(entry).to be_a Contentful::DynamicEntry
    end

    context ':auto' do
      it 'will call update dynamic_entry_cache on start-up' do
        client = vcr('entry_cache')do
          create_client(dynamic_entries: :auto)
        end
        expect(client.dynamic_entry_cache).not_to be_empty
        expect(client.dynamic_entry_cache.values.first.ancestors).to \
            include Contentful::DynamicEntry
      end
    end

    context ':manual' do
      it 'will not call #update_dynamic_entry_cache! on start-up' do
        client = create_client(dynamic_entries: :manual)
        expect(client.dynamic_entry_cache).to be_empty
      end
    end

    describe '#update_dynamic_entry_cache!' do
      let(:client) { create_client(dynamic_entries: :manual) }

      it 'will fetch all content_types' do
        stub(client).content_types { {} }
        client.update_dynamic_entry_cache!
        expect(client).to have_received.content_types(limit: 1000)
      end

      it 'will save dynamic entries in @dynamic_entry_cache' do
        vcr('entry_cache')do
          client.update_dynamic_entry_cache!
        end
        expect(client.dynamic_entry_cache).not_to be_empty
        expect(client.dynamic_entry_cache.values.first.ancestors).to \
            include Contentful::DynamicEntry
      end
    end

    describe '#register_dynamic_entry' do
      let(:client) { create_client(dynamic_entries: :manual) }

      it 'can be used to register a dynamic entry manually' do
        cat = vcr('content_type') { client.content_type 'cat' }
        CatEntry = Contentful::DynamicEntry.create(cat)
        client.register_dynamic_entry 'cat', CatEntry

        entry = vcr('nyancat') { client.entry('nyancat') }
        expect(entry).to be_a Contentful::DynamicEntry
        expect(entry).to be_a CatEntry
      end
    end
  end

  describe ':api_url' do
    it 'is "cms.cafewell.com" [default]' do
      expect(
        create_client.configuration[:api_url]
      ).to eq 'cms.cafewell.com'
    end

    it 'will be used as base url' do
      expect(
        create_client(api_url: 'cdn2.contentful.com').base_url
      ).to start_with 'http://cdn2.contentful.com'
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
        # define methods based on :fields, etc
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
