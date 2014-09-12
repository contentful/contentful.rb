require 'spec_helper'

describe Contentful::DynamicEntry do
  let(:content_type) { vcr('content_type') { create_client.content_type 'cat' } }

  it 'create as a class' do
    expect(Contentful::DynamicEntry.create(content_type)).to be_instance_of Class
  end

  it 'also works with raw json object input as argument' do
    expect(Contentful::DynamicEntry.create(json_fixture('content_type'))).to be_instance_of Class
  end

  it 'should create Contentful::DynamicEntry instances' do
    expect(Contentful::DynamicEntry.create(content_type).new(json_fixture('nyancat'))).to \
        be_a Contentful::DynamicEntry
  end

  describe 'Example Entry Class' do
    before do
      NyanCatEntry = Contentful::DynamicEntry.create(content_type)
    end

    it 'defines getters for entry fields' do
      nyancat = NyanCatEntry.new json_fixture('nyancat')
      expect(nyancat.color).to eq 'rainbow'
    end

    it 'automatically coerces types' do
      nyancat = NyanCatEntry.new json_fixture('nyancat')
      expect(nyancat.birthday).to be_a DateTime
    end
  end
end
