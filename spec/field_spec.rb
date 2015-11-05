require 'spec_helper'

describe Contentful::Field do
  let(:field) { vcr('field') { create_client.content_type('cat').fields.first } }
  let(:linkField) { vcr('linkField') {
    create_client.content_type('cat').fields.select { |f| f.id == 'image' }.first
  } }

  describe 'Properties' do
    it 'has a #properties getter returning a hash with symbol keys' do
      expect(field.properties).to be_a Hash
      expect(field.properties.keys.sample).to be_a Symbol
    end

    it 'has #id' do
      expect(field.id).to eq 'name'
    end

    it 'has #name' do
      expect(field.name).to eq 'Name'
    end

    it 'has #type' do
      expect(field.type).to eq 'Text'
    end

    it 'could have #items' do
      expect(field).to respond_to :items
    end

    it 'has #required' do
      expect(field.required).to be_truthy
    end

    it 'has #localized' do
      expect(field.required).to be_truthy
    end
  end

  describe 'Link field properties' do
    it 'has #type' do
      expect(linkField.type).to eq 'Link'
    end

    it 'has #linkType' do
      expect(linkField.link_type).to eq 'Asset'
    end
  end
end
