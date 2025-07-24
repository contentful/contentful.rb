require_relative 'base_resource'

module Contentful
  # Resource class for TaxonomyConceptScheme.
  # @see _ https://www.contentful.com/developers/docs/references/content-delivery-api/#/reference/taxonomy/concept-scheme
  class TaxonomyConceptScheme < BaseResource
    attr_reader :uri, :top_concepts, :concepts, :total_concepts

    def initialize(item, *)
      super

      @uri = item.fetch('uri', nil)
      @top_concepts = item.fetch('topConcepts', [])
      @concepts = item.fetch('concepts', [])
      @total_concepts = item.fetch('totalConcepts', 0)
    end

    # Returns true for resources that are taxonomy concept schemes
    def taxonomy_concept_scheme?
      true
    end

    # Returns false for resources that are not taxonomy concepts
    def taxonomy_concept?
      false
    end

    # Returns false for resources that are not entries
    def entry?
      false
    end

    # Returns false for resources that are not assets
    def asset?
      false
    end

    # Access localized fields
    def pref_label(locale = nil)
      locale ||= default_locale
      pref_label = raw.fetch('prefLabel', {})
      pref_label.is_a?(Hash) ? pref_label.fetch(locale.to_s, nil) : pref_label
    end

    def definition(locale = nil)
      locale ||= default_locale
      definition = raw.fetch('definition', {})
      definition.is_a?(Hash) ? definition.fetch(locale.to_s, '') : definition
    end
  end
end
