require 'spec_helper'

describe Contentful::Sync do
  let(:first_page) do
    vcr('sync_page')do
      create_client.sync(initial: true).first_page
    end
  end

  let(:last_page) do
    vcr('sync_page')do
      vcr('sync_page_2')do
        create_client.sync(initial: true).first_page.next_page
      end
    end
  end

  describe '#initialize' do
    it 'takes an options hash on initialization' do
      expect do
        vcr('sync_deletion') { create_client.sync(initial: true, type: 'Deletion').first_page }
      end.not_to raise_exception
    end

    it 'takes a next_sync_url on initialization' do
      expect do
        vcr('sync_page_2') { create_client.sync('https://cdn.contentful.com/spaces/cfexampleapi/sync?sync_token=w5ZGw6JFwqZmVcKsE8Kow4grw45QdybCr8Okw6AYwqbDksO3ehvDpUPCgcKsKXbCiAwPC8K2w4LDvsOkw6nCjhPDpcOQADElWsOoU8KGR3HCtsOAwqd6wp_Dulp8w6LDsF_CtsK7Kk05wrMvwrLClMOgG2_Dn2sGPg').first_page }
      end.not_to raise_exception
    end
  end

  describe '#first_page' do
    it 'returns only the first page of a new sync' do
      vcr('sync_page')do
        expect(create_client.sync(initial: true).first_page).to be_a Contentful::SyncPage
      end
    end
  end

  describe '#each_page' do
    it 'iterates through sync pages' do
      sync = create_client.sync(initial: true)
      vcr('sync_page'){ vcr('sync_page_2'){
        count = 0
        sync.each_page do |page|
          expect(page).to be_a Contentful::SyncPage
          count += 1
        end
        expect(count).to eq 2
      }}
    end
  end

  describe '#next_sync_url' do
    it 'is empty if there are still more pages to request in the current sync' do
      expect(first_page.next_sync_url).to be_nil
    end

    it 'returns the url to continue the sync next time' do
      expect(last_page.next_sync_url).to be_a String
    end
  end

  describe '#completed?' do
    it 'will return true if no more pages to request in the current sync' do
      expect(first_page.next_sync_url).to be_false
    end

    it 'will return true if not all pages requested, yet' do
      expect(last_page.next_sync_url).to be_true
    end
  end

  describe '#each_item' do
    it 'will directly iterate through all resources' do
      sync = create_client.sync(initial: true)
      vcr('sync_page'){ vcr('sync_page_2'){
        sync.each_item do |item|
          expect(item).to be_a Contentful::Resource
        end
      }}
    end
  end
end
