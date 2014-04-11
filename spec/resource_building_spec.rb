require 'spec_helper'


describe 'Resource Building Examples' do
  it 'can deal with arrays' do
    response = Contentful::Response.new raw_fixture('link_array')
    resource = Contentful::ResourceBuilder.new(create_client, response).run

    expect( resource.fields[:links] ).to be_a Array
    expect( resource.fields[:links].first ).to be_a Contentful::Link
  end
end