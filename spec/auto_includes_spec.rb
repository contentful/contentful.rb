require 'spec_helper'

describe 'Auto-include resources' do
  # TODO replace Request with normal client call
  let(:nyancat){ vcr('nyancat_include'){ Contentful::Request.new(create_client, '/entries/nyancat', {include: 1}).get } }

  it 'replaces Contentful::Links which are actually included with the resource' do
    expect( nyancat.fields[:image] ).not_to be_a Contentful::Link
    expect( nyancat.fields[:image] ).to be_a Contentful::Asset
  end
end