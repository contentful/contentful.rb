require 'spec_helper'

describe Contentful::Locale do
  let(:locale) { vcr('locale') { create_client.space.locales.first } }

  describe 'Properties' do
    it 'has a #properties getter returning a hash with symbol keys' do
      expect(locale.properties).to be_a Hash
      expect(locale.properties.keys.sample).to be_a Symbol
    end

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
end
