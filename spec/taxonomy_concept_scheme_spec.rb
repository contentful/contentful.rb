require 'spec_helper'

describe Contentful::TaxonomyConceptScheme do
  let(:client) { create_client }
  let(:taxonomy_concept_scheme) { vcr('taxonomy_concept_scheme') { client.taxonomy_concept_scheme('4EQT881T6sG9XpzNwb9y9R') } }

  describe 'Client method' do
    it 'can be retrieved via client.taxonomy_concept_scheme' do
      expect(taxonomy_concept_scheme).to be_a Contentful::TaxonomyConceptScheme
      expect(taxonomy_concept_scheme.sys[:id]).to eq '4EQT881T6sG9XpzNwb9y9R'
    end
  end

  describe 'System Properties' do
    it 'has a sys property' do
      expect(taxonomy_concept_scheme.sys).to be_a Hash
    end

    it 'has the correct sys properties' do
      expect(taxonomy_concept_scheme.sys[:id]).to eq '4EQT881T6sG9XpzNwb9y9R'
      expect(taxonomy_concept_scheme.sys[:type]).to eq 'TaxonomyConceptScheme'
      expect(taxonomy_concept_scheme.sys[:created_at]).to be_a DateTime
      expect(taxonomy_concept_scheme.sys[:updated_at]).to be_a DateTime
      expect(taxonomy_concept_scheme.sys[:version]).to eq 2
    end
  end

  describe 'Basic Properties' do
    it 'has a uri property' do
      expect(taxonomy_concept_scheme.uri).to eq 'https://example.com/testscheme'
    end

    it 'has top concepts' do
      expect(taxonomy_concept_scheme.top_concepts).to be_an Array
      expect(taxonomy_concept_scheme.top_concepts.first['sys']['type']).to eq 'Link'
      expect(taxonomy_concept_scheme.top_concepts.first['sys']['linkType']).to eq 'TaxonomyConcept'
      expect(taxonomy_concept_scheme.top_concepts.first['sys']['id']).to eq '5iRG7dAusVFUOh9SrexDqQ'
    end

    it 'has concepts' do
      expect(taxonomy_concept_scheme.concepts).to be_an Array
      expect(taxonomy_concept_scheme.concepts.first['sys']['type']).to eq 'Link'
      expect(taxonomy_concept_scheme.concepts.first['sys']['linkType']).to eq 'TaxonomyConcept'
      expect(taxonomy_concept_scheme.concepts.first['sys']['id']).to eq '5iRG7dAusVFUOh9SrexDqQ'
    end

    it 'has total concepts' do
      expect(taxonomy_concept_scheme.total_concepts).to eq 1
    end
  end

  describe 'Localized Fields' do
    it 'has pref_label' do
      expect(taxonomy_concept_scheme.pref_label).to eq 'TestScheme'
    end

    it 'has definition' do
      expect(taxonomy_concept_scheme.definition).to eq ''
    end

    it 'supports locale-specific access' do
      expect(taxonomy_concept_scheme.pref_label('en-US')).to eq 'TestScheme'
      expect(taxonomy_concept_scheme.pref_label('de-DE')).to be_nil
    end
  end

  describe 'Type checking' do
    it 'is a taxonomy concept scheme' do
      expect(taxonomy_concept_scheme.taxonomy_concept_scheme?).to be true
    end

    it 'is not a taxonomy concept' do
      expect(taxonomy_concept_scheme.taxonomy_concept?).to be false
    end

    it 'is not an entry' do
      expect(taxonomy_concept_scheme.entry?).to be false
    end

    it 'is not an asset' do
      expect(taxonomy_concept_scheme.asset?).to be false
    end
  end

  describe 'Serialization' do
    it 'can be marshaled and unmarshaled' do
      marshaled = Marshal.dump(taxonomy_concept_scheme)
      unmarshaled = Marshal.load(marshaled)
      
      expect(unmarshaled.sys[:id]).to eq taxonomy_concept_scheme.sys[:id]
      expect(unmarshaled.pref_label).to eq taxonomy_concept_scheme.pref_label
      expect(unmarshaled.taxonomy_concept_scheme?).to be true
    end
  end

  describe 'raw mode' do
    let(:raw_client) { create_client(raw_mode: true) }

    it 'returns raw response when raw_mode is enabled' do
      vcr('taxonomy_concept_scheme_raw') do
        result = raw_client.taxonomy_concept_scheme('4EQT881T6sG9XpzNwb9y9R')
        expect(result).to be_a Contentful::Response
        expect(result.object['sys']['id']).to eq '4EQT881T6sG9XpzNwb9y9R'
        expect(result.object['sys']['type']).to eq 'TaxonomyConceptScheme'
      end
    end

    it 'should return JSON with correct structure' do
      expected = {
        "sys" => {
          "id" => "4EQT881T6sG9XpzNwb9y9R",
          "type" => "TaxonomyConceptScheme",
          "createdAt" => "2025-03-21T05:53:46.063Z",
          "updatedAt" => "2025-03-21T05:55:26.969Z",
          "version" => 2
        },
        "uri" => "https://example.com/testscheme",
        "prefLabel" => {
          "en-US" => "TestScheme"
        },
        "definition" => {
          "en-US" => ""
        },
        "topConcepts" => [
          {
            "sys" => {
              "id" => "5iRG7dAusVFUOh9SrexDqQ",
              "type" => "Link",
              "linkType" => "TaxonomyConcept"
            }
          }
        ],
        "concepts" => [
          {
            "sys" => {
              "id" => "5iRG7dAusVFUOh9SrexDqQ",
              "type" => "Link",
              "linkType" => "TaxonomyConcept"
            }
          }
        ],
        "totalConcepts" => 1
      }
      
      vcr('taxonomy_concept_scheme_raw') do
        result = raw_client.taxonomy_concept_scheme('4EQT881T6sG9XpzNwb9y9R')
        expect(result.object).to eql expected
      end
    end
  end

  describe 'Collection endpoint' do
    let(:client) { create_client }

    it 'can fetch all taxonomy concept schemes' do
      vcr('taxonomy_concept_schemes') do
        schemes = client.taxonomy_concept_schemes(limit: 1)
        expect(schemes).to be_a Contentful::Array
        expect(schemes.first).to be_a Contentful::TaxonomyConceptScheme
        expect(schemes.first.sys[:type]).to eq 'TaxonomyConceptScheme'
      end
    end

    it 'supports pagination and query params' do
      vcr('taxonomy_concept_schemes_pagination') do
        schemes = client.taxonomy_concept_schemes(limit: 1, order: 'sys.createdAt')
        expect(schemes.limit).to eq 1
        expect(schemes.items.size).to eq 1
        expect(schemes.first).to be_a Contentful::TaxonomyConceptScheme
        expect(schemes.first.pref_label).not_to be_nil
        expect(schemes.first.sys[:type]).to eq 'TaxonomyConceptScheme'
        expect(schemes.raw['pages']).to be_a(Hash).or be_nil
      end
    end
  end
end 