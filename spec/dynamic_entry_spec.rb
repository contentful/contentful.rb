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

  describe 'issues' do
    describe 'JSON Fields should not be treated as locale data - #96' do
      before do
        vcr('entry/json_objects_client') {
          @client = create_client(
            space: 'h425t6gef30p',
            access_token: '278f7aa72f2eb90c0e002d60f85bf2144c925acd2d37dd990d3ca274f25076cf',
            dynamic_entries: :auto
          )

        }
        vcr('entry/json_objects') {
          @entry = @client.entries.first
        }
      end

      it 'only has default locale' do
        expect(@entry.instance_variable_get(:@fields).keys).to eq ['en-US']
      end

      it 'can obtain all values properly' do
        expect(@entry.name).to eq('Test')
        expect(@entry.object_test).to eq({
          null: nil,
          text: 'some text',
          array: [1, 2, 3],
          number: 123,
          boolean: true,
          object: {
            null: nil,
            text: 'bar',
            array: [1, 2, 3],
            number: 123,
            boolean: false,
            object: {foo: 'bar'}
          }
        })
      end
    end
  end
end
