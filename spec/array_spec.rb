require 'spec_helper'

class CustomClass < Contentful::Entry; end

describe Contentful::Array do
  let(:client) { create_client }
  let(:array) { vcr('array') { client.content_types } }

  describe 'SystemProperties' do
    it 'has a #sys getter returning a hash with symbol keys' do
      expect(array.sys).to be_a Hash
      expect(array.sys.keys.sample).to be_a Symbol
    end

    it 'has #type' do
      expect(array.type).to eq 'Array'
    end
  end

  describe 'Properties' do
    it 'has #total' do
      expect(array.total).to eq 4
    end

    it 'has #skip' do
      expect(array.skip).to eq 0
    end

    it 'has #limit' do
      expect(array.limit).to eq 100
    end

    it 'has #items which contain resources' do
      expect(array.items).to be_a Array
      expect(array.items.sample).to be_a Contentful::BaseResource
    end
  end

  describe '#each' do
    it 'is an Enumerator' do
      expect(array.each).to be_a Enumerator
    end

    it 'iterates over items' do
      expect(array.each.to_a).to eq array.items
    end

    it 'includes Enumerable' do
      expect(array.map { |r| r.type }).to eq array.items.map { |r| r.type }
    end
  end

  describe '#next_page' do
    it 'requests more of the same content from the server, using its limit and skip values' do
      array_page_1 = vcr('array_page_1') { create_client.content_types(skip: 3, limit: 2) }
      array_page_2 = vcr('array_page_2') { array_page_1.next_page(client) }

      expect(array_page_2).to be_a Contentful::Array
      expect(array_page_2.limit).to eq 2
      expect(array_page_2.skip).to eq 5
    end

    it 'will return false if #request not available' do
      expect(Contentful::Array.new({}).reload).to be_falsey
    end

    it 'respects query parameters' do
      array_page_1 = vcr('query_array_1') { client.entries(content_type: 'cat', limit: 1) }
      array_page_2 = vcr('query_array_2') { array_page_1.next_page(client) }

      expect(array_page_1).to be_a Contentful::Array
      expect(array_page_2).to be_a Contentful::Array

      expect(array_page_1.query).to include(content_type: 'cat')
      expect(array_page_2.query).to include(content_type: 'cat')

      expect(array_page_1.size).to eq 1
      expect(array_page_2.size).to eq 1

      expect(array_page_1[0].content_type.id).to eq 'cat'
      expect(array_page_2[0].content_type.id).to eq 'cat'

      expect(array_page_1[0].id).not_to eq array_page_2[0].id
    end
  end

  describe 'marshalling' do
    it 'marshals/unmarshals properly - #132' do
      re_array = Marshal.load(Marshal.dump(array))

      expect(re_array.endpoint).to eq array.endpoint
      expect(re_array.total).to eq array.total
      expect(re_array.limit).to eq array.limit
      expect(re_array.skip).to eq array.skip
      expect(re_array.items).to eq array.items
    end

    it 'marshals nested includes propertly - #138' do
      vcr('array/nested_resources') {
        client = create_client(
          space: 'j8tb59fszch7',
          access_token: '5f711401f965951eb724ac72ac905e13d892294ba209268f13a9b32e896c8694',
          dynamic_entries: :auto,
          max_include_resolution_depth: 5
        )
        entries = client.entries(content_type: 'child')
        rehydrated = Marshal.load(Marshal.dump(entries))

        expect(entries.inspect).to eq rehydrated.inspect

        expect(entries.first.image1.url).to eq rehydrated.first.image1.url
        expect(entries.last.image1.url).to eq rehydrated.last.image1.url

        expect(entries.first.image2.url).to eq rehydrated.first.image2.url
        expect(entries.last.image2.url).to eq rehydrated.last.image2.url
      }
    end

    it 'marshals custom resources properly - #138' do
      vcr('array/marshal_custom_classes') {
        client = create_client(
          space: 'j8tb59fszch7',
          access_token: '5f711401f965951eb724ac72ac905e13d892294ba209268f13a9b32e896c8694',
          dynamic_entries: :auto,
          max_include_resolution_depth: 5,
          entry_mapping: {
            'parent' => CustomClass
          }
        )

        entries = client.entries(content_type: 'parent')

        expect(entries.first.inspect).to eq "<CustomClass[parent] id='5aV3O0l5jU0cwQ2OkyYsyU'>"

        dehydrated = Marshal.load(Marshal.dump(entries))

        expect(dehydrated.first.inspect).to eq "<CustomClass[parent] id='5aV3O0l5jU0cwQ2OkyYsyU'>"
      }
    end

    it 'filters out unpublished resources after rehydration' do
      vcr('array/marshal_unpublished') {
        parent = create_client(
          space: 'z3eix6mwjid2',
          access_token: '9047c4394a2130dff8e9dc544a7a3ec299703fdac8e52575eb5a6678be06c468',
          dynamic_entries: :auto
        ).entries('sys.id': '5Etc0jWzIWwMeSu4W0SCi8')

        rehydrated = Marshal.load(Marshal.dump(parent))

        expect(rehydrated.first.children).to be_empty

        preview_parent = create_client(
          space: 'z3eix6mwjid2',
          access_token: '38153b942011a70b5482fda61c6a3a9d22f5e8a512662dac00fcf7eb344b75f4',
          dynamic_entries: :auto,
          api_url: 'preview.contentful.com'
        ).entries('sys.id': '5Etc0jWzIWwMeSu4W0SCi8')

        preview_rehydrated = Marshal.load(Marshal.dump(preview_parent))

        expect(preview_rehydrated.first.children).not_to be_empty
        expect(preview_rehydrated.first.children.first.title).to eq 'Child'
      }
    end
  end
end
