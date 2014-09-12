require 'spec_helper'

describe 'Auto-include resources' do
  let(:entries) { vcr('entries') { create_client.entries } } # entries come with asset includes

  it 'replaces Contentful::Links which are actually included with the resource' do
    asset = entries.items[1].fields[:image]

    expect(asset).not_to be_a Contentful::Link
    expect(asset).to be_a Contentful::Asset
  end
end
