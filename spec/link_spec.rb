require 'spec_helper'

describe Contentful::Link do
  let(:link){ vcr('link'){ create_client.content_type('cat').space } }

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
end
