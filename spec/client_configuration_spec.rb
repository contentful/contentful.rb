require 'spec_helper'


describe 'Client Configuration Options' do
  describe ':space' do
    it 'is required' do
      expect{
        Contentful::Client.new(access_token: 'b4c0n73n7fu1')
      }.to raise_error(ArgumentError)
    end
  end

  describe ':access_token' do
    it 'is required' do
      expect{
        Contentful::Client.new(space: 'cfexampleapi')
      }.to raise_error(ArgumentError)
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
      expect_vcr('not found'){
        create_client.entry "not found"
      }.to raise_error Contentful::NotFound
    end

    it 'will not raise response errors if set to false' do
      res = nil

      expect_vcr('not found'){
        res = create_client(raise_errors: false).entry "not found"
      }.not_to raise_error
      expect( res ).to be_instance_of Contentful::NotFound
    end
  end

  describe ':dynamic_entries' do
    it 'will create static entries if set to false [default]' do
      entry = nil
      client = create_client

      vcr('nyancat'){
        entry = client.entry('nyancat')
      }
      expect( entry ).not_to be_a Contentful::DynamicEntry
    end

    describe 'true value' do
      it 'will create dynamic entries' do
        entry = nil
        client = create_client(dynamic_entries: true)

        vcr('entry_cache'){
          client.update_dynamic_entry_cache!
        }
        vcr('nyancat'){
          entry = client.entry('nyancat')
        }
        expect( entry ).to be_a Contentful::DynamicEntry
      end

      context ':auto' do
        it 'will call update dynamic_entry_cache on start-up' do
          client = nil

          vcr('entry_cache'){
            client = create_client(dynamic_entries: :auto)
          }
          expect( client.dynamic_entry_cache ).not_to be_empty
          expect( client.dynamic_entry_cache.values.first.ancestors ).to \
              include Contentful::DynamicEntry
        end
      end

      context ':manual' do
        it 'will not call #update_dynamic_entry_cache! on start-up' do
          client = create_client(dynamic_entries: :manual)
          expect( client.dynamic_entry_cache ).to be_empty
        end
      end
    end

    describe '#update_dynamic_entry_cache!' do
      let(:client){ create_client(dynamic_entries: :manual) }

      it 'will fetch all content_types' do
        stub(client).content_types{{}}
        client.update_dynamic_entry_cache!
        expect( client ).to have_received.content_types
      end

      it 'will save content_types in @dynamic_entry_cache' do
        vcr('entry_cache'){
          client.update_dynamic_entry_cache!
        }
        expect( client.dynamic_entry_cache ).not_to be_empty
        expect( client.dynamic_entry_cache.values.first.ancestors ).to \
            include Contentful::DynamicEntry
      end
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

    it 'will used for the http content type request header' do
      expect(
        create_client(api_version: 2).request_headers['Content-Type']
      ).to eq "application/vnd.contentful.delivery.v2+json"
    end
  end

  describe ':authentication_mechanism' do
    describe ':header [default]' do
      it 'will add the :access_token as authorization bearer token request header' do
        expect(
          create_client.request_headers['Authorization']
        ).to eq "Bearer b4c0n73n7fu1"
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
        ).to eq "b4c0n73n7fu1"
      end

      it 'will not add the :access_token as authorization bearer token request header' do
        expect(
          create_client(authentication_mechanism: :query_string).
              request_headers['Authorization']
        ).to be_nil
      end
    end
  end

end
