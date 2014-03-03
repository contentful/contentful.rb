require 'spec_helper'

describe Contentful::Field do
  let(:field){ vcr('field'){ create_client.content_type('cat').fields.first } }

  describe 'Properties' do
    it 'has a #properties getter returning a hash with symbol keys' do
      expect( field.properties ).to be_a Hash
      expect( field.properties.keys.sample ).to be_a Symbol
    end

    it 'has #id' do
      expect( field.id ).to eq "name"
    end

    it 'has #name' do
      expect( field.name ).to eq "Name"
    end

    it 'has #type' do
      expect( field.type ).to eq "Text"
    end

    it 'has #items' do
      pending
    end

    it 'has #required' do
      pending
    end

    it 'has #localized' do
      pending
    end
  end
end
