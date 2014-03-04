require 'spec_helper'

describe Contentful::Array do
  let(:array){ vcr('array'){ create_client.content_types } }

  describe 'Properties' do
    it 'has a #properties getter returning a hash with symbol keys' do
        expect( array.properties ).to be_a Hash
        expect( array.properties.keys.sample ).to be_a Symbol
      end

    describe 'SystemProperties' do
      it 'has a #sys getter returning a hash with symbol keys' do
        expect( array.sys ).to be_a Hash
        expect( array.sys.keys.sample ).to be_a Symbol
      end

      it 'has #type' do
        expect( array.type ).to eq "Array"
      end
    end

    it 'has #total' do
      expect( array.total ).to eq 4
    end

    it 'has #skip' do
      expect( array.skip ).to eq 0
    end

    it 'has #limit' do
      expect( array.limit ).to eq 100
    end

    it 'has #items which contain resources' do
      expect( array.items ).to be_a Array
      expect( array.items.sample ).to be_a Contentful::Resource
    end

    describe '#each' do
      it 'is an Enumerator' do
        expect( array.each ).to be_a Enumerator
      end

      it 'iterates over items' do
        expect( array.each.to_a ).to eq array.items
      end

      it 'includes Enumerable' do
        expect( array.map{ |r| r.type } ).to eq array.items.map{ |r| r.type }
      end
    end
  end
end