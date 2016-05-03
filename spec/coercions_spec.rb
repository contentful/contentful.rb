require 'spec_helper'

describe 'Coercion Examples' do
  let(:entry) { vcr('entry') { create_client.entry 'nyancat' } }

  it 'converts contentful to ruby DateTime objects' do
    expect(entry.created_at).to be_a DateTime
    expect(entry.created_at.day).to eq 27
  end

  describe 'custom coercion' do
    class TestCar
      include Contentful::Resource

      property :parts, ->(v) { Array(v) unless v }
    end

    it 'can use proc' do
      car = TestCar.new("parts" => nil)
      expect(car.parts).to be_empty
    end
  end
end
