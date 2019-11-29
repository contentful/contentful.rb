require 'spec_helper'

describe Contentful::Entry do
  let(:entry) { vcr('entry') { create_client.entry 'nyancat' } }

  let(:subclass) do
    Class.new(described_class) do
      # An overridden sys method:
      def created_at; 'yesterday'; end

      # An overridden field method:
      def best_friend; 'octocat'; end
    end
  end

  let(:raw) { entry.raw }
  let(:subclassed_entry) { subclass.new(raw, create_client.configuration) }

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

    context 'when subclassed' do
      it 'does not redefine existing methods' do
        expect(subclassed_entry.created_at).to eq 'yesterday'
      end
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

    context 'when subclassed' do
      it 'does not redefine existing methods' do
        expect(subclassed_entry.best_friend).to eq 'octocat'
      end
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
      yield if block_given?
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

    it 'marshals properly when entry_mapping changed' do
      vcr('entry/marshall') {
        class TestEntryMapping; end
        nyancat = create_client(gzip_encoded: false, max_include_resolution_depth: 2, entry_mapping: { 'irrelevant_model' => TestEntryMapping }).entries(include: 2, 'sys.id' => 'nyancat').first
        test_dump(nyancat) { Object.send(:remove_const, :TestEntryMapping) }
      }
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

    it 'filters out unpublished resources after rehydration' do
      vcr('entry/marshal_unpublished') {
        parent = create_client(
          space: 'z3eix6mwjid2',
          access_token: '9047c4394a2130dff8e9dc544a7a3ec299703fdac8e52575eb5a6678be06c468',
          dynamic_entries: :auto
        ).entry('5Etc0jWzIWwMeSu4W0SCi8')

        rehydrated = Marshal.load(Marshal.dump(parent))

        expect(rehydrated.children).to be_empty

        preview_parent = create_client(
          space: 'z3eix6mwjid2',
          access_token: '38153b942011a70b5482fda61c6a3a9d22f5e8a512662dac00fcf7eb344b75f4',
          dynamic_entries: :auto,
          api_url: 'preview.contentful.com'
        ).entry('5Etc0jWzIWwMeSu4W0SCi8')

        preview_rehydrated = Marshal.load(Marshal.dump(preview_parent))

        expect(preview_rehydrated.children).not_to be_empty
        expect(preview_rehydrated.children.first.title).to eq 'Child'
      }
    end
  end

  describe 'incoming links' do
    let(:client) { create_client }

    it 'will fetch entries referencing the entry using a query' do
      vcr('entry/search_link_to_entry') {
        entries = client.entries(links_to_entry: 'nyancat')
        expect(entries).not_to be_empty
        expect(entries.count).to eq 1
        expect(entries.first.id).to eq 'happycat'
      }
    end

    it 'will fetch entries referencing the entry using instance method' do
      vcr('entry/search_link_to_entry') {
        entries = entry.incoming_references client
        expect(entries).not_to be_empty
        expect(entries.count).to eq 1
        expect(entries.first.id).to eq 'happycat'
      }
    end

    it 'will fetch entries referencing the entry using instance method + query' do
      vcr('entry/search_link_to_entry_with_custom_query') {
        entries = entry.incoming_references(client, { content_type: 'cat', select: ['fields.name'] })
        expect(entries).not_to be_empty
        expect(entries.count).to eq 1
        expect(entries.first.id).to eq 'happycat'
        expect(entries.first.fields.keys).to eq([:name])
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

  describe 'reuse objects' do
    it 'should handle recursion as well as not reusing' do
      vcr('entry/include_resolution') {
        entry = create_client(reuse_objects: true).entry('nyancat', include: 2)

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
      }
    end
    it 'should use the same object for the same entry' do
      vcr('entry/include_resolution') {
        entry = create_client(reuse_entries: true).entry('nyancat', include: 2)

        expect(entry.best_friend.name).to eq 'Happy Cat'
        expect(entry.best_friend.best_friend).to be(entry)
      }
    end
    it 'works on nested structures with unique objects' do
      vcr('entry/include_resolution_uniques') {
        entry = create_client(
          space: 'v7cxgyxt0w5x',
          access_token: '96e5d256e9a5349ce30e84356597e409f8f1bb485cb4719285b555e0f78aa27e',
          reuse_entries: true
        ).entry('1nLXjjWvk4MEeWeQCWmymc', include: 10)

        expect(entry.title).to eq '1'
        expect(entry
                 .child.child
                 .child.child
                 .child.child
                 .child.child
                 .child.title).to eq '10'
        expect(entry
                 .child.child
                 .child.child
                 .child.child
                 .child.child
                 .child.child.title).to eq '1'
        expect(entry
                 .child.child.child.child
                 .child.child.child.child
                 .child.child.child.child
                 .child.child.child.child
                 .child.child.child.child.title).to eq '1'
      }
    end
  end

  describe 'include resolution' do
    it 'should not reuse objects by default' do
      vcr('entry/include_resolution') {
        entry = create_client.entry('nyancat', include: 2)

        expect(entry.best_friend.name).to eq 'Happy Cat'
        expect(entry.best_friend.best_friend).not_to be(entry)
      }
    end
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
    it 'works on nested structures with unique objects' do
      vcr('entry/include_resolution_uniques') {
        entry = create_client(
          space: 'v7cxgyxt0w5x',
          access_token: '96e5d256e9a5349ce30e84356597e409f8f1bb485cb4719285b555e0f78aa27e',
        ).entry('1nLXjjWvk4MEeWeQCWmymc', include: 10)

        expect(entry.title).to eq '1'
        expect(entry
                 .child.child
                 .child.child
                 .child.child
                 .child.child
                 .child.title).to eq '10'
        expect(entry
                 .child.child
                 .child.child
                 .child.child
                 .child.child
                 .child.child.title).to eq '1'
        expect(entry
                 .child.child.child.child
                 .child.child.child.child
                 .child.child.child.child
                 .child.child.child.child
                 .child.child.child.child.title).to eq '1'
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

    it 'unresolvable entries get filtered from results' do
      vcr('entries/unresolvable_filter') {
        client = create_client(space: '011npgaszg5o', access_token: '42c9d93410a7319e9a735671fc1e415348f65e94a99fc768b70a7c649859d4fd', dynamic_entries: :auto)
        entry = client.entry('1HR1QvURo4MoSqO0eqmUeO')

        expect(entry.modules.size).to eq 2
      }
    end

    it 'unresolvable entries get filtered from results in deeply nested objects - #177' do
      vcr('entries/unresolvable_filter_deeply_nested') {
        client = create_client(space: 'z471hdso7l1a', access_token: '8a0e09fe71f1cb41e8788ace86a8c8d9d084599fe43a40070f232045014d2585', dynamic_entries: :auto)
        entry = client.entry('1hb8sipClkQ8ggeGaeSQWm', include: 3)
        expect(entry.should_published.first.should_unpublished.size).to eq 0
      }
    end
  end

  describe 'camel case' do
    it 'supports camel case' do
      vcr('entry') {
        entry = create_client(use_camel_case: true).entry 'nyancat'

        expect(entry.bestFriend.name).to eq 'Happy Cat'
        expect(entry.createdAt).to be_a DateTime
      }
    end
  end

  describe 'empty fields' do
    context 'when default configuration' do
      it 'raises an exception by default' do
        vcr('entries/empty_fields') {
          entry = create_client(
            space: 'z4ssexir3p93',
            access_token: 'e157fdaf7b325b71d07a94b7502807d4cfbbb1a34e69b7856838e25b92777bc6',
            dynamic_entries: :auto
          ).entry('2t1x77MgUA4SM2gMiaUcsy')

          expect { entry.title }.to raise_error Contentful::EmptyFieldError
        }
      end

      it 'returns nil if raise_for_empty_fields is false' do
        vcr('entries/empty_fields') {
          entry = create_client(
            space: 'z4ssexir3p93',
            access_token: 'e157fdaf7b325b71d07a94b7502807d4cfbbb1a34e69b7856838e25b92777bc6',
            dynamic_entries: :auto,
            raise_for_empty_fields: false
          ).entry('2t1x77MgUA4SM2gMiaUcsy')

          expect(entry.title).to be_nil
        }
      end

      it 'will properly raise NoMethodError for non-fields' do
        vcr('entries/empty_fields') {
          entry = create_client(
            space: 'z4ssexir3p93',
            access_token: 'e157fdaf7b325b71d07a94b7502807d4cfbbb1a34e69b7856838e25b92777bc6',
            dynamic_entries: :auto
          ).entry('2t1x77MgUA4SM2gMiaUcsy')

          expect { entry.unexisting_field }.to raise_error NoMethodError
        }
      end
    end

    context 'when use_camel_case is true it should still work' do
      it 'raises an exception by default' do
        vcr('entries/empty_fields') {
          entry = create_client(
            space: 'z4ssexir3p93',
            access_token: 'e157fdaf7b325b71d07a94b7502807d4cfbbb1a34e69b7856838e25b92777bc6',
            dynamic_entries: :auto,
            use_camel_case: true
          ).entry('2t1x77MgUA4SM2gMiaUcsy')

          expect { entry.title }.to raise_error Contentful::EmptyFieldError
        }
      end

      it 'returns nil if raise_for_empty_fields is false' do
        vcr('entries/empty_fields') {
          entry = create_client(
            space: 'z4ssexir3p93',
            access_token: 'e157fdaf7b325b71d07a94b7502807d4cfbbb1a34e69b7856838e25b92777bc6',
            dynamic_entries: :auto,
            raise_for_empty_fields: false,
            use_camel_case: true
          ).entry('2t1x77MgUA4SM2gMiaUcsy')

          expect(entry.title).to be_nil
        }
      end

      it 'will properly raise NoMethodError for non-fields' do
        vcr('entries/empty_fields') {
          entry = create_client(
            space: 'z4ssexir3p93',
            access_token: 'e157fdaf7b325b71d07a94b7502807d4cfbbb1a34e69b7856838e25b92777bc6',
            dynamic_entries: :auto,
            use_camel_case: true
          ).entry('2t1x77MgUA4SM2gMiaUcsy')

          expect { entry.unexisting_field }.to raise_error NoMethodError
        }
      end
    end
  end

  describe 'rich text support' do
    it 'properly serializes and resolves includes' do
      vcr('entries/rich_text') {
        entry = create_client(
          space: 'jd7yc4wnatx3',
          access_token: '6256b8ef7d66805ca41f2728271daf27e8fa6055873b802a813941a0fe696248',
          raise_errors: true,
          dynamic_entries: :auto,
          gzip_encoded: false
        ).entry('4BupPSmi4M02m0U48AQCSM')

        expected_entry_occurrances = 2
        embedded_entry_index = 1
        entry.body['content'].each do |content|
          if content['nodeType'] == 'embedded-entry-block'
            expect(content['data']['target']).to be_a Contentful::Entry
            expect(content['data']['target'].body).to eq "Embedded #{embedded_entry_index}"
            expected_entry_occurrances -= 1
            embedded_entry_index += 1
          end
        end

        expect(expected_entry_occurrances).to eq 0
      }
    end

    it 'doesnt hydrate the same entry twice - #194' do
      vcr('entries/rich_text_hydration_issue') {
        entry = nil

        expect {
          entry = create_client(
            space: 'fds721b88p6b',
            access_token: '45ba81cc69423fcd2e3f0a4779de29481bb5c11495bc7e14649a996cf984e98e',
            raise_errors: true,
            dynamic_entries: :auto,
            gzip_encoded: false
          ).entry('1tBAu0wP9qAQEg6qCqMics')
        }.not_to raise_error

        expect(entry.children[0].id).to eq entry.children[1].id
        expect(entry.children[0].body).to eq entry.children[1].body
      }
    end

    it 'respects content in data attribute if its not a Link' do
      vcr('entries/rich_text_nested_fields') {
        entry = create_client(
          space: 'jd7yc4wnatx3',
          access_token: '6256b8ef7d66805ca41f2728271daf27e8fa6055873b802a813941a0fe696248',
          raise_errors: true,
          dynamic_entries: :auto,
          gzip_encoded: false
        ).entry('6NGLswCREsGA28kGouScyY')

        expect(entry.body['content'][0]).to eq({
            'data' => {},
            'content' => [
                {'marks' => [], 'value' => 'A link to ', 'nodeType' => 'text', 'nodeClass' => 'text'},
                {
                    'data' => {'uri' => 'https://google.com'},
                    'content' => [{'marks' => [], 'value' => 'google', 'nodeType' => 'text', 'nodeClass' => 'text'}],
                    'nodeType' => 'hyperlink',
                    'nodeClass' => 'inline'
                },
                {'marks' => [], 'value' => '', 'nodeType' => 'text', 'nodeClass' => 'text'}
            ],
            'nodeType' => 'paragraph',
            'nodeClass' => 'block'
        })
      }
    end

    it 'supports includes in nested fields' do
      vcr('entries/rich_text_nested_fields') {
        entry = create_client(
          space: 'jd7yc4wnatx3',
          access_token: '6256b8ef7d66805ca41f2728271daf27e8fa6055873b802a813941a0fe696248',
          raise_errors: true,
          dynamic_entries: :auto,
          gzip_encoded: false
        ).entry('6NGLswCREsGA28kGouScyY')

        expect(entry.body['content'][3]['nodeType']).to eq('unordered-list')
        expect(entry.body['content'][3]['content'][2]['content'][0]['data']['target'].is_a?(Contentful::Entry)).to be_truthy

        expect(entry.body['content'][4]['nodeType']).to eq('ordered-list')
        expect(entry.body['content'][4]['content'][2]['content'][0]['data']['target'].is_a?(Contentful::Entry)).to be_truthy
      }
    end

    it 'returns a link when resource is valid but unreachable' do
      vcr('entries/rich_text_unresolved_relationships') {
        parent = create_client(
          space: 'jd7yc4wnatx3',
          access_token: '6256b8ef7d66805ca41f2728271daf27e8fa6055873b802a813941a0fe696248',
          raise_errors: true,
          dynamic_entries: :auto,
          gzip_encoded: false
        ).entry('4fvSwl5Ob6UEWKg6MQicuC')

        entry = parent.rich_text_child
        expect(entry.body['content'][19]['data']['target'].is_a?(Contentful::Link)).to be_truthy
      }
    end
  end
end
