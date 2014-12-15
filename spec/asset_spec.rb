require 'spec_helper'

describe Contentful::Asset do
  let(:asset) { vcr('asset') { create_client.asset('nyancat') } }

  describe 'SystemProperties' do
    it 'has a #sys getter returning a hash with symbol keys' do
      expect(asset.sys).to be_a Hash
      expect(asset.sys.keys.sample).to be_a Symbol
    end

    it 'has #id' do
      expect(asset.id).to eq 'nyancat'
    end

    it 'has #type' do
      expect(asset.type).to eq 'Asset'
    end

    it 'has #space' do
      expect(asset.space).to be_a Contentful::Link
    end

    it 'has #created_at' do
      expect(asset.created_at).to be_a DateTime
    end

    it 'has #updated_at' do
      expect(asset.updated_at).to be_a DateTime
    end

    it 'has #revision' do
      expect(asset.revision).to eq 1
    end
  end

  describe 'Fields' do
    it 'has #title' do
      expect(asset.title).to eq 'Nyan Cat'
    end

    it 'could have #description' do
      expect(asset).to respond_to :description
    end

    it 'has #file' do
      expect(asset.file).to be_a Contentful::File
    end
  end

  describe '#image_url' do
    it 'returns #url of #file without parameter' do
      expect(asset.image_url).to eq asset.file.url
    end

    it 'adds image options if given' do
      url = asset.image_url(width: 100, format: 'jpg', quality: 50, focus: 'top_right', fit: 'thumb')
      expect(url).to include asset.file.url
      expect(url).to include '?w=100&fm=jpg&q=50&f=top_right&fit=thumb'
    end
  end
end
