require 'spec_helper'

describe Contentful::SyncPage do
  let(:page_with_more) { vcr('sync_page') { create_client.sync(initial: true).first_page } }
  let(:page) { vcr('sync_page_2') { create_client.sync.get('https://cdn.contentful.com/spaces/cfexampleapi/sync?sync_token=w5ZGw6JFwqZmVcKsE8Kow4grw45QdybCr8Okw6AYwqbDksO3ehvDpUPCgcKsKXbCiAwPC8K2w4LDvsOkw6nCjhPDpcOQADElWsOoU8KGR3HCtsOAwqd6wp_Dulp8w6LDsF_CtsK7Kk05wrMvwrLClMOgG2_Dn2sGPg') } }

  describe 'SystemProperties' do
    it 'has a #sys getter returning a hash with symbol keys' do
      expect(page.sys).to be_a Hash
      expect(page.sys.keys.sample).to be_a Symbol
    end

    it 'has #type' do
      expect(page.type).to eq 'Array'
    end
  end

  describe 'Properties' do
    it 'has #items which contain resources' do
      expect(page_with_more.items).to be_a Array
      expect(page_with_more.items.sample).to be_a Contentful::BaseResource
    end
  end

  describe 'Fields' do
    it 'properly deals with nested locale fields' do
      expect(page_with_more.items.first.fields[:name]).to eq 'London'
    end
  end

  describe '#each' do
    it 'is an Enumerator' do
      expect(page.each).to be_a Enumerator
    end

    it 'iterates over items' do
      expect(page.each.to_a).to eq page.items
    end

    it 'includes Enumerable' do
      expect(page.map { |r| r.type }).to eq page.items.map { |r| r.type }
    end
  end

  describe '#next_sync_url' do
    it 'will return the next_sync_url if there is one' do
      expect(page.next_sync_url).to be_a String
    end

    it 'will return nil if note last page, yet' do
      expect(page_with_more.next_sync_url).to be_nil
    end
  end

  describe '#next_page_url' do
    it 'will return the next_page_url if there is one' do
      expect(page_with_more.next_page_url).to be_a String
    end

    it 'will return nil if on last page' do
      expect(page.next_page_url).to be_nil
    end
  end

  describe '#next_page' do
    it 'requests the next page' do
      next_page = vcr('sync_page_2')do
        page_with_more.next_page
      end
      expect(next_page).to be_a Contentful::SyncPage
    end

    it 'will return nil if last page' do
      expect(page.next_page_url).to be_nil
    end
  end

  describe '#next_page?' do
    it 'will return true if there is a next page' do
      expect(page_with_more.next_page?).to be_truthy
    end

    it 'will return false if last page' do
      expect(page.next_page?).to be_falsey
    end
  end

  describe '#last_page?' do
    it 'will return true if no more pages available' do
      expect(page.last_page?).to be_truthy
    end

    it 'will return false if more pages available' do
      expect(page_with_more.last_page?).to be_falsey
    end
  end

  describe '#sync' do
    it 'returns the sync that created the page' do
      expect(page.sync).to be_a Contentful::Sync
    end
  end
end
