require 'spec_helper'

describe Contentful::TaxonomyConcept do
  let(:client) { create_client }
  let(:taxonomy_concept) { vcr('taxonomy_concept') { client.taxonomy_concept('5iRG7dAusVFUOh9SrexDqQ') } }

  describe 'Client method' do
    it 'can be retrieved via client.taxonomy_concept' do
      expect(taxonomy_concept).to be_a Contentful::TaxonomyConcept
      expect(taxonomy_concept.sys[:id]).to eq '5iRG7dAusVFUOh9SrexDqQ'
    end
  end

  describe 'System Properties' do
    it 'has a sys property' do
      expect(taxonomy_concept.sys).to be_a Hash
    end

    it 'has the correct sys properties' do
      expect(taxonomy_concept.sys[:id]).to eq '5iRG7dAusVFUOh9SrexDqQ'
      expect(taxonomy_concept.sys[:type]).to eq 'TaxonomyConcept'
      expect(taxonomy_concept.sys[:created_at]).to be_a DateTime
      expect(taxonomy_concept.sys[:updated_at]).to be_a DateTime
      expect(taxonomy_concept.sys[:version]).to eq 2
    end
  end

  describe 'Basic Properties' do
    it 'has a uri property' do
      expect(taxonomy_concept.uri).to eq 'https://example/testconcept'
    end

    it 'has notations' do
      expect(taxonomy_concept.notations).to eq ['SLR001']
    end
  end

  describe 'Localized Fields' do
    it 'has pref_label' do
      expect(taxonomy_concept.pref_label).to eq 'TestConcept'
    end

    it 'has alt_labels' do
      expect(taxonomy_concept.alt_labels).to eq ['Couches']
    end

    it 'has hidden_labels' do
      expect(taxonomy_concept.hidden_labels).to eq ['Sopha']
    end

    it 'has note' do
      expect(taxonomy_concept.note).to eq 'Excepteur sint occaecat cupidatat non proident'
    end

    it 'has change_note' do
      expect(taxonomy_concept.change_note).to be_nil
    end

    it 'has definition' do
      expect(taxonomy_concept.definition).to be_nil
    end

    it 'has editorial_note' do
      expect(taxonomy_concept.editorial_note).to eq 'labore et dolore magna aliqua'
    end

    it 'has example' do
      expect(taxonomy_concept.example).to eq 'Lorem ipsum dolor sit amet'
    end

    it 'has history_note' do
      expect(taxonomy_concept.history_note).to eq 'sed do eiusmod tempor incididunt'
    end

    it 'has scope_note' do
      expect(taxonomy_concept.scope_note).to eq 'consectetur adipiscing elit'
    end

    it 'supports locale-specific access' do
      expect(taxonomy_concept.pref_label('en-US')).to eq 'TestConcept'
      expect(taxonomy_concept.pref_label('de-DE')).to be_nil
    end
  end

  describe 'Relationships' do
    it 'has broader concepts' do
      expect(taxonomy_concept.broader).to be_an Array
      expect(taxonomy_concept.broader).to be_empty
    end

    it 'has related concepts' do
      expect(taxonomy_concept.related).to be_an Array
      expect(taxonomy_concept.related).to be_empty
    end

    it 'has concept schemes' do
      expect(taxonomy_concept.concept_schemes).to be_an Array
      expect(taxonomy_concept.concept_schemes.first['sys']['type']).to eq 'Link'
      expect(taxonomy_concept.concept_schemes.first['sys']['linkType']).to eq 'TaxonomyConceptScheme'
      expect(taxonomy_concept.concept_schemes.first['sys']['id']).to eq '4EQT881T6sG9XpzNwb9y9R'
    end
  end

  describe 'Type checking' do
    it 'is a taxonomy concept' do
      expect(taxonomy_concept.taxonomy_concept?).to be true
    end

    it 'is not an entry' do
      expect(taxonomy_concept.entry?).to be false
    end

    it 'is not an asset' do
      expect(taxonomy_concept.asset?).to be false
    end
  end

  describe 'Serialization' do
    it 'can be marshaled and unmarshaled' do
      marshaled = Marshal.dump(taxonomy_concept)
      unmarshaled = Marshal.load(marshaled)
      
      expect(unmarshaled.sys[:id]).to eq taxonomy_concept.sys[:id]
      expect(unmarshaled.pref_label).to eq taxonomy_concept.pref_label
      expect(unmarshaled.taxonomy_concept?).to be true
    end
  end

  describe 'raw mode' do
    let(:raw_client) { create_client(raw_mode: true) }

    it 'returns raw response when raw_mode is enabled' do
      vcr('taxonomy_concept_raw') do
        result = raw_client.taxonomy_concept('5iRG7dAusVFUOh9SrexDqQ')
        expect(result).to be_a Contentful::Response
        expect(result.object['sys']['id']).to eq '5iRG7dAusVFUOh9SrexDqQ'
        expect(result.object['sys']['type']).to eq 'TaxonomyConcept'
      end
    end

    it 'should return JSON with correct structure' do
      expected = {
        "sys" => {
          "id" => "5iRG7dAusVFUOh9SrexDqQ",
          "type" => "TaxonomyConcept",
          "createdAt" => "2025-03-21T05:54:15.434Z",
          "updatedAt" => "2025-06-23T06:05:25.107Z",
          "version" => 4
        },
        "uri" => "https://example/testconcept",
        "notations" => ["SLR001"],
        "conceptSchemes" => [
          {
            "sys" => {
              "id" => "4EQT881T6sG9XpzNwb9y9R",
              "type" => "Link",
              "linkType" => "TaxonomyConceptScheme"
            }
          }
        ],
        "broader" => [],
        "related" => [],
        "prefLabel" => {
          "en-US" => "TestConcept"
        },
        "altLabels" => {
          "en-US" => ["Couches"]
        },
        "hiddenLabels" => {
          "en-US" => ["Sopha"]
        },
        "note" => {
          "en-US" => "Excepteur sint occaecat cupidatat non proident"
        },
        "changeNote" => nil,
        "definition" => nil,
        "editorialNote" => {"en-US" => ""},
        "example" => {
          "en-US" => "Lorem ipsum dolor sit amet"
        },
        "historyNote" => {"en-US" => ""},
        "scopeNote" => {
          "en-US" => "consectetur adipiscing elit"
        }
      }
      
      vcr('taxonomy_concept_raw') do
        result = raw_client.taxonomy_concept('5iRG7dAusVFUOh9SrexDqQ')
        expect(result.object).to eql expected
      end
    end
  end
end