require 'spec_helper'

describe Contentful::Resource do
  it 'must be included to get functionality' do
    c = Class.new
    c.send :include, Contentful::Resource
    expect(c).to respond_to :property_coercions
  end

  describe 'creation' do
    it 'must be initialized with a (hash) object' do
      expect do
        Contentful::ContentType.new json_fixture('nyancat')
      end.not_to raise_error
    end

    it 'can deal with invalid objects' do
      expect do
        Contentful::ContentType.new
      end.not_to raise_error
    end
  end

  describe 'custom resource' do
    class TestCat
      include Contentful::Resource

      property :name
      property :likes
      property :color
      property :bestFriend
      property :birthday
      property :lives
      property :image
    end

    it 'can create a custom resource' do
      cat = TestCat.new("name" => "foobar")
      expect(cat).to respond_to(:name)
      expect(cat.name).to eq "foobar"
    end

    it 'can create a custom resource from API' do
      vcr('entry') {
        cat = TestCat.new create_client(raw_mode: true).entry('nyancat').object["fields"]
        expect(cat.name).to eq "Nyan Cat"
      }
    end
  end

  describe '#request' do
    it 'will return a request object, if it has been initialized with one' do
      request  = Contentful::Request.new(nil, 'content_types')
      resource = Contentful::ContentType.new({}, request)
      expect(resource.request).to eq request
    end
  end

  describe '#reload' do
    let(:client) { create_client }
    let(:entry) { vcr('entry') { client.entry 'nyancat' } }

    it 'triggers the request connected to the resource (again)' do
      stub(entry.request).get
      entry.reload
      expect(entry.request).to have_received.get
    end

    it 'the reloaded resource is different from the original one' do
      reloaded_entry = vcr('reloaded_entry') { entry.reload }
      expect(reloaded_entry).to be_a Contentful::Entry
      expect(reloaded_entry).not_to be entry
    end

    it 'will return false if #request not available' do
      expect(Contentful::ContentType.new({}).reload).to be_falsey
    end
  end
end
