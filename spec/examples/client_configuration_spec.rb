require 'spec_helper'
require 'contentful'


describe 'Client Configuration Options' do
  describe ':raise_errors' do
    it 'will raise response errors if set to true [default]' do
      expect_vcr('not found'){
        create_client.entry! "not found"
      }.to raise_error Contentful::NotFound
    end

    it 'will not raise response errors if set to false' do
      res = nil
      expect_vcr('not found'){
        res = create_client(raise_errors: false).entry! "not found"
      }.not_to raise_error
      expect( res ).to be_instance_of Contentful::NotFound
    end
  end

end