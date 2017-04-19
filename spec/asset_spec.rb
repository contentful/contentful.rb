require 'spec_helper'

describe Contentful::Asset do
  let(:asset) { vcr('asset') { create_client.asset('nyancat') } }

  describe 'SystemProperties' do
    it 'has a #sys getter returning a hash with symbol keys' do
      expect(asset.sys).to be_a Hash
      expect(asset.sys.keys.sample).to be_a Symbol
    end

    it 'has #id' do
      expect(asset.id).to eq 'nyancat'
    end

    it 'has #type' do
      expect(asset.type).to eq 'Asset'
    end

    it 'has #space' do
      expect(asset.space).to be_a Contentful::Link
    end

    it 'has #created_at' do
      expect(asset.created_at).to be_a DateTime
    end

    it 'has #updated_at' do
      expect(asset.updated_at).to be_a DateTime
    end

    it 'has #revision' do
      expect(asset.revision).to eq 1
    end
  end

  describe 'Fields' do
    it 'has #title' do
      expect(asset.title).to eq 'Nyan Cat'
    end

    it 'could have #description' do
      expect(asset).to respond_to :description
    end

    it 'has #file' do
      expect(asset.file).to be_a Contentful::File
    end
  end

  describe '#image_url' do
    it 'returns #url of #file without parameter' do
      expect(asset.image_url).to eq asset.file.url
    end

    it 'adds image options if given' do
      url = asset.image_url(width: 100, format: 'jpg', quality: 50, focus: 'top_right', fit: 'thumb', fl: 'progressive')
      expect(url).to include asset.file.url
      expect(url).to include '?w=100&fm=jpg&q=50&f=top_right&fit=thumb&fl=progressive'
    end
  end

  describe '#url' do
    it 'returns #url of #file without parameter' do
      expect(asset.url).to eq asset.file.url
    end

    it 'adds image options if given' do
      url = asset.url(width: 100, format: 'jpg', quality: 50, focus: 'top_right', fit: 'thumb', fl: 'progressive')
      expect(url).to include asset.file.url
      expect(url).to include '?w=100&fm=jpg&q=50&f=top_right&fit=thumb&fl=progressive'
    end
  end

  it 'can be marshalled' do
    marshalled = Marshal.dump(asset)
    unmarshalled = Marshal.load(marshalled)

    expect(unmarshalled.title).to eq 'Nyan Cat'
    expect(unmarshalled.file).to be_a Contentful::File
  end

  describe 'select operator' do
    let(:client) { create_client }

    context 'with sys sent' do
      it 'properly creates an entry' do
        vcr('asset/select_only_sys') {
          asset = client.assets(select: ['sys']).first
          expect(asset.fields).to be_empty
          expect(asset.sys).not_to be_empty
        }
      end

      it 'can contain only one field' do
        vcr('asset/select_one_field') {
          asset = client.assets(select: ['sys', 'fields.file']).first
          expect(asset.fields.keys).to eq([:file])
        }
      end
    end

    context 'without sys sent' do
      it 'will enforce sys anyway' do
        vcr('asset/select_no_sys') {
          asset = client.assets(select: ['fields'], 'sys.id' => 'nyancat').first

          expect(asset.id).to eq 'nyancat'
          expect(asset.sys).not_to be_empty
        }
      end

      it 'works with empty array as well, as sys is enforced' do
        vcr('asset/select_empty_array') {
          asset = client.assets(select: [], 'sys.id' => 'nyancat').first

          expect(asset.id).to eq 'nyancat'
          expect(asset.sys).not_to be_empty
        }
      end
    end
  end

  describe 'issues' do
    it 'serializes files correctly for every locale - #129' do
      vcr('assets/issues_129') {
        client = create_client(
          space: 'bht13amj0fva',
          access_token: 'bb703a05e107148bed6ee246a9f6b3678c63fed7335632eb68fe1b689c801534'
        )

        asset = client.assets('sys.id' => '14bZJKTr6AoaGyeg4kYiWq', locale: '*').first

        expect(asset.file).to be_a ::Contentful::File
        expect(asset.file.file_name).to eq 'Flag_of_the_United_States.svg'

        expect(asset.fields[:file]).to be_a ::Contentful::File
        expect(asset.fields[:file].file_name).to eq 'Flag_of_the_United_States.svg'

        expect(asset.fields('es')[:file]).to be_a ::Contentful::File
        expect(asset.fields('es')[:file].file_name).to eq 'Flag_of_Spain.svg'
      }
    end

    it 'properly serializes files for non-default locales on localized requests - jekyll-contentful-data-import #46' do
      vcr('assets/issues_jekyll_46') {
        client = create_client(
          space: 'bht13amj0fva',
          access_token: 'bb703a05e107148bed6ee246a9f6b3678c63fed7335632eb68fe1b689c801534',
        )

        asset = client.assets('sys.id' => '14bZJKTr6AoaGyeg4kYiWq', locale: 'es').first

        expect(asset.file).to be_a ::Contentful::File
        expect(asset.file.file_name).to eq 'Flag_of_Spain.svg'
      }
    end
  end
end
