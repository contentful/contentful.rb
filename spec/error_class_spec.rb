require 'spec_helper'

describe Contentful::Error do
  let(:r) { Contentful::Response.new raw_fixture('not_found', 404) }

  describe '#response' do
    it 'returns the response the error has been initialized with' do
      expect(Contentful::Error.new(r).response).to be r
    end
  end

  describe '#message' do
    it 'returns the message found in the response json' do
      expect(Contentful::Error.new(r).message).not_to be_nil
      expect(Contentful::Error.new(r).message).to \
          eq json_fixture('not_found')['message']
    end
  end

  describe Contentful::UnparsableJson do
    describe '#message' do
      it 'returns the json parser\'s message' do
        uj = Contentful::Response.new raw_fixture('unparsable')
        expect(Contentful::UnparsableJson.new(uj).message).to \
            include 'unexpected token'
      end
    end
  end

  describe '.[]' do

    it 'returns BadRequest error class for 400' do
      expect(Contentful::Error[400]).to eq Contentful::BadRequest
    end

    it 'returns Unauthorized error class for 401' do
      expect(Contentful::Error[401]).to eq Contentful::Unauthorized
    end

    it 'returns AccessDenied error class for 403' do
      expect(Contentful::Error[403]).to eq Contentful::AccessDenied
    end

    it 'returns NotFound error class for 404' do
      expect(Contentful::Error[404]).to eq Contentful::NotFound
    end

    it 'returns ServerError error class for 500' do
      expect(Contentful::Error[500]).to eq Contentful::ServerError
    end

    it 'returns ServiceUnavailable error class for 503' do
      expect(Contentful::Error[503]).to eq Contentful::ServiceUnavailable
    end

    it 'returns generic error class for any other value' do
      expect(Contentful::Error[nil]).to eq Contentful::Error
      expect(Contentful::Error[200]).to eq Contentful::Error
    end
  end

end
