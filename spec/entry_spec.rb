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
      expect(entry.fields[:best_friend]).to be_a Contentful::Entry
    end
  end

  describe 'multiple locales' do
    it 'can handle multiple locales' do
      vcr('entry_locales') {
        nyancat = create_client.entries(locale: "*", 'sys.id' => 'nyancat').items.first
        expect(nyancat.fields('en-US')[:name]).to eq "Nyan Cat"
        expect(nyancat.fields('tlh')[:name]).to eq "Nyan vIghro'"


        expect(nyancat.fields(:'en-US')[:name]).to eq "Nyan Cat"
        expect(nyancat.fields(:tlh)[:name]).to eq "Nyan vIghro'"
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
          nyancat = create_client.entries(locale: "*", 'sys.id' => 'nyancat').items.first
          expect(nyancat.fields_with_locales[:name].size).to eq(2)
          expect(nyancat.fields_with_locales[:name][:'en-US']).to eq("Nyan Cat")
          expect(nyancat.fields_with_locales[:name][:tlh]).to eq("Nyan vIghro'")
        }
      end

      it 'can have references in multiple locales and they are properly solved' do
        vcr('multi_locale_reference') {
          client = create_client(
            space: '1sjfpsn7l90g',
            access_token: 'e451a3cdfced9000220be41ed9c899866e8d52aa430eaf7c35b09df8fc6326f9',
            dynamic_entries: :auto
          )

          entry = client.entries(locale: '*').first

          expect(entry.image).to be_a ::Contentful::Asset
          expect(entry.fields('zh')[:image]).to be_a ::Contentful::Asset
          expect(entry.fields('es')[:image]).to be_a ::Contentful::Asset

          expect(entry.image.id).not_to eq entry.fields('zh')[:image].id
        }
      end

      it 'can have references with arrays in multiple locales and have them properly solved' do
        vcr('multi_locale_array_reference') {
          client = create_client(
            space: 'cma9f9g4dxvs',
            access_token: '3e4560614990c9ac47343b9eea762bdaaebd845766f619660d7230787fd545e1',
            dynamic_entries: :auto
          )

          entry = client.entries(content_type: 'test', locale: '*').first

          expect(entry.files).to be_a ::Array
          expect(entry.references).to be_a ::Array
          expect(entry.files.first).to be_a ::Contentful::Asset
          expect(entry.references.first.entry?).to be_truthy

          expect(entry.fields('zh')[:files]).to be_a ::Array
          expect(entry.fields('zh')[:references]).to be_a ::Array
          expect(entry.fields('zh')[:files].first).to be_a ::Contentful::Asset
          expect(entry.fields('zh')[:references].first.entry?).to be_truthy

          expect(entry.files.first.id).not_to eq entry.fields('zh')[:files].first.id
        }
      end
    end
  end

  it '#raw' do
    vcr('entry/raw') {
      nyancat = create_client.entry('nyancat')
      expect(nyancat.raw).to eq(create_client(raw_mode: true).entry('nyancat').object['items'].first)
    }
  end

  describe 'can be marshalled' do
    def test_dump(nyancat)
      dump = Marshal.dump(nyancat)
      new_cat = Marshal.load(dump)

      # Attributes
      expect(new_cat).to be_a Contentful::Entry
      expect(new_cat.name).to eq "Nyan Cat"
      expect(new_cat.lives).to eq 1337

      # Single linked objects
      expect(new_cat.best_friend).to be_a Contentful::Entry
      expect(new_cat.best_friend.name).to eq "Happy Cat"

      # Array of linked objects
      expect(new_cat.cat_pack.count).to eq 2
      expect(new_cat.cat_pack[0].name).to eq "Happy Cat"
      expect(new_cat.cat_pack[1].name).to eq "Worried Cat"

      # Nested Links
      expect(new_cat.best_friend.best_friend).to be_a Contentful::Entry
      expect(new_cat.best_friend.best_friend.name).to eq "Nyan Cat"

      # Asset
      expect(new_cat.image.file.url).to eq "//images.contentful.com/cfexampleapi/4gp6taAwW4CmSgumq2ekUm/9da0cd1936871b8d72343e895a00d611/Nyan_cat_250px_frame.png"
    end

    it 'marshals properly' do
      vcr('entry/marshall') {
        nyancat = create_client(gzip_encoded: false, max_include_resolution_depth: 2).entries(include: 2, 'sys.id' => 'nyancat').first
        test_dump(nyancat)
      }
    end

    it 'can remarshall an unmarshalled object' do
      vcr('entry/marshall') {
        nyancat = create_client(max_include_resolution_depth: 2).entries(include: 2, 'sys.id' => 'nyancat').first

        # The double load/dump is on purpose
        test_dump(Marshal.load(Marshal.dump(nyancat)))
      }
    end

    it 'can properly marshal multiple level nested resources - #138' do
      vcr('entry/marshal_138') {
        parent = create_client(
          space: 'j8tb59fszch7',
          access_token: '5f711401f965951eb724ac72ac905e13d892294ba209268f13a9b32e896c8694',
          dynamic_entries: :auto,
          max_include_resolution_depth: 5
        ).entry('5aV3O0l5jU0cwQ2OkyYsyU')

        rehydrated = Marshal.load(Marshal.dump(parent))

        expect(rehydrated.childs.first.image1.url).to eq '//images.contentful.com/j8tb59fszch7/7FjliblAmAoGMwU62MeQ6k/62509df90ef4bed38c0701bb9aa8c74c/Funny-Cat-Pictures-with-Captions-25.jpg'
        expect(rehydrated.childs.first.image2.url).to eq '//images.contentful.com/j8tb59fszch7/1pbGuWZ27O6GMO0OGemgcA/a4185036a3640ad4491f38d8926003ab/Funny-Cat-Pictures-with-Captions-1.jpg'
        expect(rehydrated.childs.last.image1.url).to eq '//images.contentful.com/j8tb59fszch7/4SXVTr0KEUyWiMMCOaUeUU/c9fa2246d5529a9c8e1ec6f5387dc4f6/e0194eca1c8135636ce0e014341548c3.jpg'
        expect(rehydrated.childs.last.image2.url).to eq '//images.contentful.com/j8tb59fszch7/1NU1YcNQJGIA22gAKmKqWo/56fa672bb17a7b7ae2773d08e101d059/57ee64921c25faa649fc79288197c313.jpg'
      }
    end
  end

  describe 'select operator' do
    let(:client) { create_client }

    context 'with sys sent' do
      it 'properly creates an entry' do
        vcr('entry/select_only_sys') {
          entry = client.entries(select: ['sys'], 'sys.id' => 'nyancat').first
          expect(entry.fields).to be_empty
          expect(entry.entry?).to be_truthy
        }
      end

      describe 'can contain only one field' do
        context 'with content_type sent' do
          it 'will properly create the entry with one field' do
            vcr('entry/select_one_field_proper') {
              entry = client.entries(content_type: 'cat', select: ['sys', 'fields.name'], 'sys.id' => 'nyancat').first
              expect(entry.fields).not_to be_empty
              expect(entry.entry?).to be_truthy
              expect(entry.fields[:name]).to eq 'Nyan Cat'
              expect(entry.fields).to eq({name: 'Nyan Cat'})
            }
          end
        end

        context 'without content_type sent' do
          it 'will raise an error' do
            vcr('entry/select_one_field') {
              expect { client.entries(select: ['sys', 'fields.name'], 'sys.id' => 'nyancat') }.to raise_error Contentful::BadRequest
            }
          end
        end
      end
    end

    context 'without sys sent' do
      it 'will enforce sys anyway' do
        vcr('entry/select_no_sys') {
          entry = client.entries(select: ['fields'], 'sys.id' => 'nyancat').first

          expect(entry.id).to eq 'nyancat'
          expect(entry.sys).not_to be_empty
        }
      end

      it 'works with empty array as well, as sys is enforced' do
        vcr('entry/select_empty_array') {
          entry = client.entries(select: [], 'sys.id' => 'nyancat').first

          expect(entry.id).to eq 'nyancat'
          expect(entry.sys).not_to be_empty
        }
      end
    end
  end

  describe 'include resolution' do
    it 'defaults to 20 depth' do
      vcr('entry/include_resolution') {
        entry = create_client.entry('nyancat', include: 2)

        expect(entry.best_friend.name).to eq 'Happy Cat'
        expect(entry
               .best_friend.best_friend
               .best_friend.best_friend
               .best_friend.best_friend
               .best_friend.best_friend
               .best_friend.best_friend
               .best_friend.best_friend
               .best_friend.best_friend
               .best_friend.best_friend
               .best_friend.best_friend
               .best_friend.best_friend.name).to eq 'Nyan Cat'

        expect(entry
               .best_friend.best_friend
               .best_friend.best_friend
               .best_friend.best_friend
               .best_friend.best_friend
               .best_friend.best_friend
               .best_friend.best_friend
               .best_friend.best_friend
               .best_friend.best_friend
               .best_friend.best_friend
               .best_friend.best_friend
               .best_friend).to be_a ::Contentful::Link
      }
    end

    it 'can be configured arbitrarily' do
      vcr('entry/include_resolution') {
        entry = create_client(max_include_resolution_depth: 3).entry('nyancat', include: 2)

        expect(entry.best_friend.name).to eq 'Happy Cat'
        expect(entry
               .best_friend.best_friend
               .best_friend.name).to eq 'Happy Cat'
        expect(entry
               .best_friend.best_friend
               .best_friend.best_friend).to be_a ::Contentful::Link
      }
    end
  end

  describe 'issues' do
    it 'Symbol/Text field with null values should be serialized as nil - #117' do
      vcr('entries/issue_117') {
        client = create_client(space: '8jbbayggj9gj', access_token: '4ce0108f04e55c76476ba84ab0e6149734db73d67cd1b429323ef67f00977e07')
        entry = client.entries.first

        expect(entry.nil).to be_nil
        expect(entry.nil).not_to eq ''
      }
    end

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
        expect(@entry.locales).to eq ['en-US']
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

    it 'Number (Integer and Decimal) values get properly serialized - #125' do
      vcr('entries/issue_125') {
        client = create_client(space: 'zui87wsu8q80', access_token: '64ff902c58cd14ea063d3ded810d1111a0266537e9aba283bad3319b1762c302', dynamic_entries: :auto)
        entry = client.entries.first

        expect(entry.integer).to eq 123
        expect(entry.decimal).to eq 12.3
      }
    end
  end
end
