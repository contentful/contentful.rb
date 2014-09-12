require 'spec_helper'

describe 'Resource Building Examples' do
  it 'can deal with arrays' do
    response = Contentful::Response.new raw_fixture('link_array')
    resource = Contentful::ResourceBuilder.new(create_client, response).run

    expect(resource.fields[:links]).to be_a Array
    expect(resource.fields[:links].first).to be_a Contentful::Link
  end

  it 'replaces links with included versions if present' do
    response = Contentful::Response.new raw_fixture('includes')
    resource = Contentful::ResourceBuilder.new(create_client, response).run.first

    expect(resource.fields[:links]).to be_a Array
    expect(resource.fields[:links].first).to be_a Contentful::Entry
  end

  it 'can also reference itself' do
    response = Contentful::Response.new raw_fixture('self_link')
    resource = Contentful::ResourceBuilder.new(create_client, response).run.first

    other_resource = resource.fields[:e]
    expect(other_resource).to be_a Contentful::Entry
    expect(other_resource.fields[:e]).to be resource
  end
end
