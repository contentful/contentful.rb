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
end
