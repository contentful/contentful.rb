require 'spec_helper'

describe Contentful::Client do
  describe '#get' do
    let(:client) { create_client() }
    let(:proxy_client) { create_client(proxy_host: '183.207.232.194',
                                       proxy_port: 8080,
                                       secure: false) }
    let(:timeout_client) { create_client(timeout_connect: 1, timeout_read: 2, timeout_write: 3) }
    let(:request) { Contentful::Request.new(nil, client.environment_url('/content_types'), nil, 'cat') }

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
      expect(request).to receive(:query).thrice.and_call_original
      vcr('content_type') { client.get(request) }
    end

    it 'calls #get_http' do
      expect(client.class).to receive(:get_http).with(client.base_url + request.url, request.query, client.request_headers, client.proxy_params, client.timeout_params) { raw_fixture('content_type') }
      client.get(request)
    end

    it 'calls #get_http via proxy' do
      expect(proxy_client.class).to receive(:get_http).with(proxy_client.base_url + request.url, request.query, proxy_client.request_headers, proxy_client.proxy_params, client.timeout_params) { raw_fixture('content_type') }
      proxy_client.get(request)
      expect(proxy_client.proxy_params[:host]).to eq '183.207.232.194'
      expect(proxy_client.proxy_params[:port]).to eq 8080
    end

    describe 'timeout params' do
      context 'with timeouts configured' do
        it 'calls #get_http with timeouts' do
          expect(timeout_client.class).to receive(:get_http).with(timeout_client.base_url + request.url, request.query, timeout_client.request_headers, timeout_client.proxy_params, timeout_client.timeout_params) { raw_fixture('content_type') }
          timeout_client.get(request)
          expect(timeout_client.timeout_params[:connect]).to eq 1
          expect(timeout_client.timeout_params[:read]).to eq 2
          expect(timeout_client.timeout_params[:write]).to eq 3
        end
      end

      context 'without timeouts' do
        it 'calls #get_http with timeouts' do
          expect(client.class).to receive(:get_http).with(client.base_url + request.url, request.query, client.request_headers, client.proxy_params, client.timeout_params) { raw_fixture('content_type') }
          client.get(request)
          expect(client.timeout_params).to eq({})
        end
      end
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

  describe '#taxonomy_concept' do
    let(:client) { create_client }

    it 'creates a request with the correct endpoint' do
      expect(Contentful::Request).to receive(:new).with(
        client,
        client.environment_url('/taxonomy/concepts'),
        {},
        'test-concept-id'
      ).and_return(double('request', get: double('response')))

      client.taxonomy_concept('test-concept-id')
    end

    it 'passes query parameters correctly' do
      query = { locale: 'en-US' }
      expect(Contentful::Request).to receive(:new).with(
        client,
        client.environment_url('/taxonomy/concepts'),
        query,
        'test-concept-id'
      ).and_return(double('request', get: double('response')))

      client.taxonomy_concept('test-concept-id', query)
    end

    it 'returns a TaxonomyConcept object' do
      vcr('taxonomy_concept') do
        result = client.taxonomy_concept('3DMf5gdax6J22AfcJ6fvsC')
        expect(result).to be_a Contentful::TaxonomyConcept
        expect(result.sys[:id]).to eq '3DMf5gdax6J22AfcJ6fvsC'
      end
    end

    it 'returns raw response when raw_mode is enabled' do
      raw_client = create_client(raw_mode: true)
      vcr('taxonomy_concept') do
        result = raw_client.taxonomy_concept('3DMf5gdax6J22AfcJ6fvsC')
        expect(result).to be_a Contentful::Response
        expect(result.object['sys']['id']).to eq '3DMf5gdax6J22AfcJ6fvsC'
      end
    end
  end
end
