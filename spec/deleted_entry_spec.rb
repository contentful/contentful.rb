require 'spec_helper'

describe 'DeletedEntry' do
  let(:deleted_entry)do
    vcr('sync_deleted_entry')do
      create_client.sync(initial: true, type: 'DeletedEntry').first_page.items[0]
    end
  end

  describe 'SystemProperties' do
    it 'has a #sys getter returning a hash with symbol keys' do
      expect(deleted_entry.sys).to be_a Hash
      expect(deleted_entry.sys.keys.sample).to be_a Symbol
    end

    it 'has #id' do
      expect(deleted_entry.id).to eq 'CVebBDcQsSsu6yKKIayy'
    end

    it 'has #type' do
      expect(deleted_entry.type).to eq 'DeletedEntry'
    end

    it 'has #deleted_at' do
      expect(deleted_entry.created_at).to be_a DateTime
    end
  end
end
