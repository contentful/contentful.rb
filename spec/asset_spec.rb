require 'spec_helper'

describe Contentful::Asset do
  let(:asset){ vcr('asset'){ create_client.asset('nyancat') } }

  describe 'SystemProperties' do
    it 'has a #sys getter returning a hash with symbol keys' do
      expect( asset.sys ).to be_a Hash
      expect( asset.sys.keys.sample ).to be_a Symbol
    end

    it 'has #id' do
      expect( asset.id ).to eq "nyancat"
    end

    it 'has #type' do
      expect( asset.type ).to eq "Asset"
    end

    it 'has #space' do
      expect( asset.space ).to be_a Contentful::Link
    end

    it 'has #created_at' do
      expect( asset.created_at ).to be_a DateTime
    end

    it 'has #updated_at' do
      expect( asset.updated_at ).to be_a DateTime
    end

    it 'has #revision' do
      expect( asset.revision ).to eq 1
    end
  end

  describe 'Fields' do
    it 'has #title' do
      expect( asset.title ).to eq "Nyan Cat"
    end

    it 'has #description' do
      pending 'has none'
    end

    it 'has #file' do
      expect( asset.file ).to be_a Contentful::File
    end
  end
end
