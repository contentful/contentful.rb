require 'spec_helper'

describe Contentful::Space do
  let(:space) { vcr('space') { create_client.space } }

  describe 'SystemProperties' do
    it 'has a #sys getter returning a hash with symbol keys' do
      expect(space.sys).to be_a Hash
      expect(space.sys.keys.sample).to be_a Symbol
    end

    it 'has #id' do
      expect(space.id).to eq 'cfexampleapi'
    end

    it 'has #type' do
      expect(space.type).to eq 'Space'
    end
  end

  describe 'Properties' do
    it 'has #name' do
      expect(space.name).to eq 'Contentful Example API'
    end

    it 'has #locales' do
      expect(space.locales).to be_a Array
      expect(space.locales.first).to be_a Contentful::Locale
    end
  end
end
