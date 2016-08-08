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

  it '#raw' do
    vcr('entry/raw') {
      nyancat = create_client.entry('nyancat')
      expect(nyancat.raw).to eq(create_client(raw_mode: true).entry('nyancat').object)
    }
  end

  describe 'custom resources' do
    class Kategorie < Contentful::Entry
      include ::Contentful::Resource::CustomResource

      property :title
      property :slug
      property :image
      property :top
      property :subcategories
      property :featuredArticles
      property :catIntroHead
      property :catIntroduction
      property :seoText
      property :metaKeywords
      property :metaDescription
      property :metaRobots
    end

    it 'maps fields properly' do
      vcr('entry/custom_resource') {
        entry = create_client(
          space: 'g2b4ltw00meh',
          dynamic_entries: :auto,
          entry_mapping: {
            'kategorie' => Kategorie
          }
        ).entries.first

        expect(entry).to be_a Kategorie
        expect(entry.title).to eq "Some Title"
        expect(entry.slug).to eq "/asda.html"
        expect(entry.featured_articles.first.is_a?(Contentful::Entry)).to be_truthy
        expect(entry.top).to be_truthy
      }
    end

    describe 'can be marshalled' do
      class Cat < Contentful::Entry
        include ::Contentful::Resource::CustomResource

        property :name
        property :lives
        property :bestFriend, Cat
        property :catPack
      end

      def test_dump(nyancat)
        dump = Marshal.dump(nyancat)
        new_cat = Marshal.load(dump)

        # Attributes
        expect(new_cat).to be_a Cat
        expect(new_cat.name).to eq "Nyan Cat"
        expect(new_cat.lives).to eq 1337

        # Single linked objects
        expect(new_cat.best_friend).to be_a Cat
        expect(new_cat.best_friend.name).to eq "Happy Cat"

        # Array of linked objects
        expect(new_cat.cat_pack.count).to eq 2
        expect(new_cat.cat_pack[0].name).to eq "Happy Cat"
        expect(new_cat.cat_pack[1].name).to eq "Worried Cat"

        # Nested Links
        expect(new_cat.best_friend.best_friend).to be_a Cat
        expect(new_cat.best_friend.best_friend.name).to eq "Worried Cat"

        # Nested array of linked objects
        expect(new_cat.best_friend.cat_pack.count).to eq 2
        expect(new_cat.best_friend.cat_pack[0].name).to eq "Nyan Cat"
        expect(new_cat.best_friend.cat_pack[1].name).to eq "Worried Cat"

        # Array of linked objects in a nested array of linked objects
        expect(new_cat.cat_pack.first.name).to eq "Happy Cat"
        expect(new_cat.cat_pack.first.cat_pack[0].name).to eq "Nyan Cat"
        expect(new_cat.cat_pack.first.cat_pack[1].name).to eq "Worried Cat"
      end

      it 'using entry_mapping' do
        vcr('entry/marshall') {
          nyancat = create_client(entry_mapping: {'cat' => Cat}).entries(include: 2, 'sys.id' => 'nyancat').first
          test_dump(nyancat)
        }
      end

      it 'using resource_mapping' do
        vcr('entry/marshall') {
          nyancat = create_client(resource_mapping: {
            'Entry' => ->(_json_object) do
              return Cat if _json_object.fetch('sys', {}).fetch('contentType', {}).fetch('sys', {}).fetch('id', nil) == 'cat'
              Contentful::Entry
            end
          }).entries(include: 2, 'sys.id' => 'nyancat').first
          test_dump(nyancat)
        }
      end

      it 'newly created custom resources have property mappings' do
        entry = Cat.new

        expect(entry).to respond_to :name
        expect(entry).to respond_to :lives
        expect(entry).to respond_to :best_friend
        expect(entry).to respond_to :cat_pack
      end
    end
  end
end
