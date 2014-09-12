require 'spec_helper'

describe Contentful::Response do
  let(:successful_response) { Contentful::Response.new raw_fixture('nyancat'), Contentful::Request.new(nil, '/entries', nil, 'nyancat') }
  let(:error_response) { Contentful::Response.new raw_fixture('not_found') }
  let(:unparsable_response) { Contentful::Response.new raw_fixture('unparsable') }

  describe '#raw' do
    it 'returns the raw response it has been initalized with' do
      expect(successful_response.raw.to_s).to eql raw_fixture('nyancat').to_s
    end
  end

  describe '#object' do
    it "returns the repsonse's parsed json" do
      expect(successful_response.object).to eq json_fixture('nyancat')
    end
  end

  describe '#request' do
    it 'returns the request the response has been initalized with' do
      expect(successful_response.request).to be_a Contentful::Request
    end
  end

  describe '#status' do
    it 'returns :ok for normal responses' do
      expect(successful_response.status).to eq :ok
    end

    it 'returns :contentful_error for error responses' do
      expect(error_response.status).to eq :contentful_error
    end

    it 'returns :unparsable_json for unparsable json responses' do
      expect(unparsable_response.status).to eq :unparsable_json
    end

    it 'returns :no_content for responses without content' do
      raw_response = ''
      stub(raw_response).status { 204 }
      no_content_response = Contentful::Response.new raw_response
      expect(no_content_response.status).to eq :no_content
    end
  end

  describe '#error_message' do
    it 'returns contentful error message for contentful errors' do
      expect(error_response.error_message).to eq 'The resource could not be found.'
    end

    it 'returns json parser error message for json parse errors' do
      expect(unparsable_response.error_message).to include 'unexpected token'
    end

    it 'returns a ServiceUnavailable error on a 503' do
      error_response = Contentful::Response.new raw_fixture('not_found', 503)
      expect(error_response.status).to eql :service_unavailable
    end
  end
end
