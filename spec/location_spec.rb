require 'spec_helper'

describe Contentful::Location do
  let(:location)do
    vcr('location')do
      Contentful::Client.new(
        space: 'lzjz8hygvfgu',
        access_token: '0c6ef483524b5e46b3bafda1bf355f38f5f40b4830f7599f790a410860c7c271',
        dynamic_entries: :auto,
      ).entry('3f6fq5ylFCi4kIYAQKsAYG').location
    end
  end

  describe 'Properties' do
    it 'has #lat' do
      expect(location.lat).to be_a Float
      expect(location.lat.to_i).to eq 36
    end

    it 'has #lon' do
      expect(location.lon).to be_a Float
      expect(location.lon.to_i).to eq(-94)
    end
  end
end
