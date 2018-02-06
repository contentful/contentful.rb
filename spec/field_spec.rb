require 'spec_helper'

describe Contentful::Field do
  let(:field) { vcr('field') { create_client.content_type('cat').fields.first } }
  let(:linkField) { vcr('linkField') {
    create_client.content_type('cat').fields.select { |f| f.id == 'image' }.first
  } }
  let(:arrayField) { vcr('arrayField') {
    Contentful::Client.new(
        space: 'wl1z0pal05vy',
        access_token: '9b76e1bbc29eb513611a66b9fc5fb7acd8d95e83b0f7d6bacfe7ec926c819806'
    ).content_type('2PqfXUJwE8qSYKuM0U6w8M').fields.select { |f| f.id == 'categories' }.first
  } }

  describe 'Properties' do
    it 'has #id' do
      expect(field.id).to eq 'name'
    end

    it 'has #name' do
      expect(field.name).to eq 'Name'
    end

    it 'has #type' do
      expect(field.type).to eq 'Text'
    end

    it 'could have #items' do
      expect(field).to respond_to :items
    end

    it 'has #required' do
      expect(field.required).to be_truthy
    end

    it 'has #localized' do
      expect(field.required).to be_truthy
    end
  end

  describe 'Link field properties' do
    it 'has #type' do
      expect(linkField.type).to eq 'Link'
    end

    it 'has #linkType' do
      expect(linkField.link_type).to eq 'Asset'
    end
  end

  describe 'Array field properties' do
    it 'has #type' do
      expect(arrayField.type).to eq 'Array'
    end

    it 'has #items' do
      expect(arrayField.items.type).to eq 'Link'
      expect(arrayField.items.link_type).to eq 'Entry'
    end
  end

  describe 'issues' do
    describe 'json field' do
      it 'can coerce properly when top level is not object' do
        coercion = Contentful::ObjectCoercion.new([{foo: 123}])
        expect(coercion.coerce).to eq [{foo: 123}]

        coercion = Contentful::ObjectCoercion.new('foobar')
        expect(coercion.coerce).to eq 'foobar'

        coercion = Contentful::ObjectCoercion.new(true)
        expect(coercion.coerce).to eq true

        coercion = Contentful::ObjectCoercion.new(123)
        expect(coercion.coerce).to eq 123

        coercion = Contentful::ObjectCoercion.new({foo: 123})
        expect(coercion.coerce).to eq(foo: 123)
      end
    end

    describe 'datetime field' do
      it 'can coerce properly when value is nil' do
        coercion = Contentful::DateCoercion.new(nil)
        expect(coercion.coerce).to eq(nil)
      end
    end
  end
end
