require 'spec_helper'

describe Contentful::Link do
  let(:entry){ vcr('entry'){ create_client.entry('nyancat') } }
  let(:link){ entry.space }
  let(:content_type_link){ entry.content_type }

  describe 'SystemProperties' do
    it 'has a #sys getter returning a hash with symbol keys' do
      expect( link.sys ).to be_a Hash
      expect( link.sys.keys.sample ).to be_a Symbol
    end

    it 'has #id' do
      expect( link.id ).to eq "cfexampleapi"
    end

    it 'has #type' do
      expect( link.type ).to eq "Link"
    end

    it 'has #link_type' do
      expect( link.link_type ).to eq "Space"
    end
  end

  describe '#resolve' do
    it 'queries the api for the resource' do
      vcr('space'){
        expect( link.resolve ).to be_a Contentful::Space
      }
    end

    it 'queries the api for the resource (different link object)' do
      vcr('content_type'){
        expect( content_type_link.resolve ).to be_a Contentful::ContentType
      }
    end
  end
end
