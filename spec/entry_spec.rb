require 'spec_helper'

describe Contentful::Entry do
  let(:entry) { vcr('entry') { create_client.entry 'nyancat' } }

  describe 'SystemProperties' do
    it 'has a #sys getter returning a hash with symbol keys' do
      expect(entry.sys).to be_a Hash
      expect(entry.sys.keys.sample).to be_a Symbol
    end

    it 'has #id' do
      expect(entry.id).to eq 'nyancat'
    end

    it 'has #type' do
      expect(entry.type).to eq 'Entry'
    end

    it 'has #space' do
      expect(entry.space).to be_a Contentful::Link
    end

    it 'has #content_type' do
      expect(entry.content_type).to be_a Contentful::Link
    end

    it 'has #created_at' do
      expect(entry.created_at).to be_a DateTime
    end

    it 'has #updated_at' do
      expect(entry.updated_at).to be_a DateTime
    end

    it 'has #revision' do
      expect(entry.revision).to eq 5
    end
  end

  describe 'Fields' do
    it 'has a #fields getter returning a hash with symbol keys' do
      expect(entry.sys).to be_a Hash
      expect(entry.sys.keys.sample).to be_a Symbol
    end

    it "contains the entry's fields" do
      expect(entry.fields[:color]).to eq 'rainbow'
      expect(entry.fields[:bestFriend]).to be_a Contentful::Link
    end
  end

  describe 'multiple locales' do
    it 'can handle multiple locales' do
      vcr('entry_locales') {
        cat = create_client.entries(locale: "*").items.first
        expect(cat.fields('en-US')[:name]).to eq "Nyan Cat"
        expect(cat.fields('es')[:name]).to eq "Gato Nyan"


        expect(cat.fields(:'en-US')[:name]).to eq "Nyan Cat"
        expect(cat.fields(:es)[:name]).to eq "Gato Nyan"
      }
    end

    describe '#fields_with_locales' do
      it 'can handle entries with just 1 locale' do
        vcr('entry') {
          nyancat = create_client.entry('nyancat')
          expect(nyancat.fields_with_locales[:name].size).to eq(1)
          expect(nyancat.fields_with_locales[:name][:'en-US']).to eq("Nyan Cat")
        }
      end

      it 'can handle entries with multiple locales' do
        vcr('entry_locales') {
          nyancat = create_client.entries(locale: "*").items.first
          expect(nyancat.fields_with_locales[:name].size).to eq(2)
          expect(nyancat.fields_with_locales[:name][:'en-US']).to eq("Nyan Cat")
          expect(nyancat.fields_with_locales[:name][:es]).to eq("Gato Nyan")
        }
      end
    end
  end
end
