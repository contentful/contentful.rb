require 'spec_helper'

describe 'Resource Building Examples' do
  it 'can deal with arrays' do
    request = Contentful::Request.new(nil, 'entries')
    response = Contentful::Response.new(raw_fixture('link_array'), request)
    resource = Contentful::ResourceBuilder.new(response.object).run

    expect(resource.fields[:links]).to be_a Array
    expect(resource.fields[:links].first).to be_a Contentful::Link
  end

  it 'replaces links with included versions if present' do
    request = Contentful::Request.new(nil, 'entries')
    response = Contentful::Response.new(raw_fixture('includes'), request)
    resource = Contentful::ResourceBuilder.new(response.object).run.first

    expect(resource.fields[:links]).to be_a Array
    expect(resource.fields[:links].first).to be_a Contentful::Entry
  end

  it 'can also reference itself' do
    request = Contentful::Request.new(nil, 'entries')
    response = Contentful::Response.new(raw_fixture('self_link'), request)
    resource = Contentful::ResourceBuilder.new(response.object).run.first

    other_resource = resource.fields[:e]
    expect(other_resource).to be_a Contentful::Entry
    expect(other_resource.fields[:e]).to eq resource
  end
end
