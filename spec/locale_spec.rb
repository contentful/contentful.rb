require 'spec_helper'

describe Contentful::Locale do
  let(:locale) { vcr('locale') { create_client.space.locales.first } }

  describe 'Properties' do
    it 'has #code' do
      expect(locale.code).to eq 'en-US'
    end

    it 'has #name' do
      expect(locale.name).to eq 'English'
    end

    it 'has #default' do
      expect(locale.default).to eq true
    end
  end

  describe 'locales endpoint' do
    it 'locales can be fetched from environments' do
      vcr('locale_from_environment') {
        client = create_client(
          space: 'facgnwwgj5fe',
          access_token: '<ACCESS_TOKEN>',
          environment: 'testing'
        )

        locales = client.locales

        expect(locales).to be_a ::Contentful::Array
        expect(locales.first).to be_a ::Contentful::Locale
        expect(locales.first.code).to eq 'en-US'
      }
    end
  end
end
