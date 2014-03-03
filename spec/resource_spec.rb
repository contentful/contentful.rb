require 'spec_helper'

describe Contentful::Resource do

  it 'must be included to get functionality' do
    c = Class.new
    c.send :include, Contentful::Resource
    expect( c ).to respond_to :property_coercions
  end

  describe 'Creation' do
    it 'must be initialized with a (hash) object' do
      expect{
        Contentful::ContentType.new json_fixture('nyancat')
      }.not_to raise_error
    end

    it 'can deal with invalid objects' do
      expect{
        Contentful::ContentType.new({})
      }.not_to raise_error
    end

    pending 'more'
  end

  describe 'Properties' do
    pending
  end
end