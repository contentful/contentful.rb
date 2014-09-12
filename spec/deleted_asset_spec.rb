require 'spec_helper'

describe 'DeletedAsset' do
  let(:deleted_asset)do
    vcr('sync_deleted_asset')do
      create_client.sync(initial: true, type: 'DeletedAsset').first_page.items[0]
    end
  end

  describe 'SystemProperties' do
    it 'has a #sys getter returning a hash with symbol keys' do
      expect(deleted_asset.sys).to be_a Hash
      expect(deleted_asset.sys.keys.sample).to be_a Symbol
    end

    it 'has #id' do
      expect(deleted_asset.id).to eq '5c6VY0gWg0gwaIeYkUUiqG'
    end

    it 'has #type' do
      expect(deleted_asset.type).to eq 'DeletedAsset'
    end

    it 'has #deleted_at' do
      expect(deleted_asset.created_at).to be_a DateTime
    end
  end
end
