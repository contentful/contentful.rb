require 'spec_helper'

describe Contentful::File do
  let(:file) { vcr('asset') { create_client.asset('nyancat').file } }

  describe 'Properties' do
    it 'has #file_name' do
      expect(file.file_name).to eq 'Nyan_cat_250px_frame.png'
    end

    it 'has #content_type' do
      expect(file.content_type).to eq 'image/png'
    end

    it 'has #url' do
      expect(file.url).to eq '//images.contentful.com/cfexampleapi/4gp6taAwW4CmSgumq2ekUm/9da0cd1936871b8d72343e895a00d611/Nyan_cat_250px_frame.png'
    end

    it 'has #details' do
      expect(file.details).to be_instance_of Hash
    end
  end
end
