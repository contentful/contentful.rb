require 'spec_helper'

describe Contentful::Includes do

  let(:example_json) { json_fixture('includes') }
  # This is the expected transformation of the JSON above
  let(:example_array) { [{"sys"=>{"space"=>{"sys"=>{"type"=>"Link", "linkType"=>"Space", "id"=>"6yahkaf5ehkk"}}, "type"=>"Entry", "contentType"=>{"sys"=>{"type"=>"Link", "linkType"=>"ContentType", "id"=>"tSFLnCNqvuyoMA6SKkQ2W"}}, "id"=>"2fCmT4nxtO6eI6usgoEkQG", "revision"=>1, "createdAt"=>"2014-04-11T10:59:40.249Z", "updatedAt"=>"2014-04-11T10:59:40.249Z", "locale"=>"en-US"}, "fields"=>{"foo"=>"dog", "links"=>[{"sys"=>{"type"=>"Link", "linkType"=>"Entry", "id"=>"5ulKc1zdg4ES0oAKuCe8yA"}}, {"sys"=>{"type"=>"Link", "linkType"=>"Entry", "id"=>"49fzjGhfBCAu6iOqIeg8yQ"}}]}}, {"sys"=>{"space"=>{"sys"=>{"type"=>"Link", "linkType"=>"Space", "id"=>"6yahkaf5ehkk"}}, "type"=>"Entry", "contentType"=>{"sys"=>{"type"=>"Link", "linkType"=>"ContentType", "id"=>"tSFLnCNqvuyoMA6SKkQ2W"}}, "id"=>"49fzjGhfBCAu6iOqIeg8yQ", "revision"=>1, "createdAt"=>"2014-04-11T10:58:58.286Z", "updatedAt"=>"2014-04-11T10:58:58.286Z", "locale"=>"en-US"}, "fields"=>{"foo"=>"nyancat"}}, {"sys"=>{"space"=>{"sys"=>{"type"=>"Link", "linkType"=>"Space", "id"=>"6yahkaf5ehkk"}}, "type"=>"Entry", "contentType"=>{"sys"=>{"type"=>"Link", "linkType"=>"ContentType", "id"=>"tSFLnCNqvuyoMA6SKkQ2W"}}, "id"=>"5ulKc1zdg4ES0oAKuCe8yA", "revision"=>1, "createdAt"=>"2014-04-11T10:59:17.658Z", "updatedAt"=>"2014-04-11T10:59:17.658Z", "locale"=>"en-US"}, "fields"=>{"foo"=>"happycat"}}] }
  
  # Another array to test adding two includes together
  let(:example_array_2) { [{"sys"=>{"space"=>{"sys"=>{"type"=>"Link", "linkType"=>"Space", "id"=>"6yahkaf5ehkk"}}, "type"=>"Entry", "contentType"=>{"sys"=>{"type"=>"Link", "linkType"=>"ContentType", "id"=>"tSFLnCNqvuyoMA6SKkQ2W"}}, "id"=>"1mhHLEpJSZxJR6erF2YWmD", "revision"=>1, "createdAt"=>"2014-04-11T10:58:58.286Z", "updatedAt"=>"2014-04-11T10:58:58.286Z", "locale"=>"en-US"}, "fields"=>{"foo"=>"cheezburger"}}] }
  
  subject { described_class.from_response(example_json) }
  
  describe '.new' do
    context 'with no args' do
      subject { described_class.new }
      
      it { is_expected.to be_a Contentful::Includes }
      
      it 'has empty items and lookup' do
        expect(subject.items).to eq([])
        expect(subject.lookup).to eq({})
      end
      
      it 'behaves like an array' do
        expect(subject.length).to eq(0)
        expect(subject.to_a).to eq([])
      end
    end
    context 'with array of includes' do
      subject { described_class.new(example_array) }
      
      it { is_expected.to be_a Contentful::Includes }
      
      it 'populates items and lookup' do
        expect(subject.items).to eq(example_array)
        expect(subject.lookup.length).to eq(3)
      end
      
      it 'behaves like an array' do
        expect(subject.length).to eq(3)
        expect(subject.to_a).to eq(example_array)
        expect(subject[2]['sys']['id']).to eq('5ulKc1zdg4ES0oAKuCe8yA')
      end
    end
  end
  
  describe '.from_response' do
    subject { described_class.from_response(example_json) }

    it 'finds the includes in the response and converts them' do
      expect(subject.items).to eq(example_array)
    end
    it 'populates the lookup' do
      expect(subject.lookup.length).to eq(3)
    end
  end
  
  describe '#find_link' do
    let(:link) { {"sys" => {"id" => "49fzjGhfBCAu6iOqIeg8yQ", "linkType" => "Entry"}} }
    it 'looks up the linked entry' do
      expect(subject.find_link(link)).to eq(example_array[1])
    end
  end
  
  describe '#+' do
    let(:other) { described_class.new(example_array_2) }
    it 'adds the arrays and lookups together' do
      sum = subject + other
      expect(sum.object_id).not_to eq(subject.object_id)
      expect(sum.length).to eq(4)
      expect(sum.lookup).to have_key("Entry:2fCmT4nxtO6eI6usgoEkQG")
      expect(sum.lookup).to have_key("Entry:49fzjGhfBCAu6iOqIeg8yQ")
    end
    context 'other is the same as subject' do
      let(:other) { described_class.from_response(example_json) }
      it 'just returns the subject unchanged' do
        sum = subject + other
        expect(sum.object_id).to eq(subject.object_id)
      end
    end
  end
  
  describe '#dup' do
    let(:other) { described_class.new(example_array_2) }
    it 'duplicates the array but also the lookup' do
      orig = subject # assign subject to a variable so we can call += on it
      copy = orig.dup
      orig += other
      expect(orig.length).to eq(4)
      expect(copy.length).to eq(3)
      expect(orig.lookup.length).to eq(4)
      expect(copy.lookup.length).to eq(3)
    end
  end
  
  describe 'marshalling' do
    it 'marshals and unmarshals correctly' do
      data = Marshal.dump(subject)
      obj = Marshal.load(data)
      expect(obj).to be_a Contentful::Includes
      expect(obj.length).to eq(3)
      expect(obj.lookup.length).to eq(3)
    end
  end
  
end
