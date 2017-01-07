require 'spec_helper'

describe Contentful::Sync do
  before :each do
    Contentful::ContentTypeCache.clear!
  end

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
      expect(first_page.next_sync_url).to be_falsey
    end

    it 'will return true if not all pages requested, yet' do
      expect(last_page.next_sync_url).to be_truthy
    end
  end

  describe '#each_item' do
    it 'will directly iterate through all resources' do
      sync = create_client.sync(initial: true)
      vcr('sync_page'){ vcr('sync_page_2'){
        sync.each_item do |item|
          expect(item).to be_a Contentful::BaseResource
        end
      }}
    end
  end

  describe 'Resource parsing' do
    it 'will correctly parse the `file` field of an asset' do
      sync = create_client.sync(initial: true)
      vcr('sync_page') {
        asset = sync.first_page.items.select { |item| item.is_a?(Contentful::Asset) }.first

        expect(asset.file.file_name).to eq 'doge.jpg'
        expect(asset.file.content_type).to eq 'image/jpeg'
        expect(asset.file.details['image']['width']).to eq 5800
        expect(asset.file.details['image']['height']).to eq 4350
        expect(asset.file.details['size']).to eq 522943
        expect(asset.file.url).to eq '//images.contentful.com/cfexampleapi/1x0xpXu4pSGS4OukSyWGUK/cc1239c6385428ef26f4180190532818/doge.jpg'
      }
    end
  end

  describe 'raw_mode' do
    before do
      @sync = create_client(raw_mode: true).sync(initial: true)
    end

    it 'should not fail' do
      vcr('sync_page_short') {
        expect { @sync.first_page }.not_to raise_error
      }
    end

    it 'should return a raw Response' do
      vcr('sync_page_short') {
        expect(@sync.first_page).to be_a Contentful::Response
      }
    end

    it 'should return JSON' do
      expected = {
        "sys" => {"type" => "Array"},
        "items" => [
          {
            "sys" => {
              "space" => {
                "sys" => {
                  "type" => "Link",
                  "linkType" => "Space",
                  "id" => "cfexampleapi"}
              },
              "type" => "Entry",
              "contentType" => {
                "sys" => {
                  "type" => "Link",
                  "linkType" => "ContentType",
                  "id" => "1t9IbcfdCk6m04uISSsaIK"
                }
              },
              "id" => "5ETMRzkl9KM4omyMwKAOki",
              "revision" => 2,
              "createdAt" => "2014-02-21T13:42:57.752Z",
              "updatedAt" => "2014-04-16T12:44:02.691Z"
            },
            "fields" => {
              "name" => {"en-US"=>"London"},
              "center" => {
                "en-US" => {"lat"=>51.508515, "lon"=>-0.12548719999995228}
              }
            }
          }
        ],
        "nextSyncUrl" => "https://cdn.contentful.com/spaces/cfexampleapi/sync?sync_token=w5ZGw6JFwqZmVcKsE8Kow4grw45QdybCr8Okw6AYwqbDksO3ehvDpUPCgcKsKXbCiAwPC8K2w4LDvsOkw6nCjhPDpcOQADElWsOoU8KGR3HCtsOAwqd6wp_Dulp8w6LDsF_CtsK7Kk05wrMvwrLClMOgG2_Dn2sGPg"
      }
      vcr('sync_page_short') {
        expect(@sync.first_page.object).to eql expected
      }
    end
  end
end
