require_relative 'base_resource'

module Contentful
  # Resource class for TaxonomyConcept.
  # @see _ https://www.contentful.com/developers/docs/references/content-delivery-api/#/reference/taxonomy/concept
  class TaxonomyConcept < BaseResource
    attr_reader :uri, :notations, :broader, :related, :concept_schemes

    def initialize(item, *)
      super

      @uri = item.fetch('uri', nil)
      @notations = item.fetch('notations', [])
      @broader = item.fetch('broader', [])
      @related = item.fetch('related', [])
      @concept_schemes = item.fetch('conceptSchemes', [])
    end

    # Returns true for resources that are taxonomy concepts
    def taxonomy_concept?
      true
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

    def alt_labels(locale = nil)
      locale ||= default_locale
      alt_labels = raw.fetch('altLabels', {})
      alt_labels.is_a?(Hash) ? alt_labels.fetch(locale.to_s, []) : alt_labels
    end

    def hidden_labels(locale = nil)
      locale ||= default_locale
      hidden_labels = raw.fetch('hiddenLabels', {})
      hidden_labels.is_a?(Hash) ? hidden_labels.fetch(locale.to_s, []) : hidden_labels
    end

    def note(locale = nil)
      locale ||= default_locale
      note = raw.fetch('note', {})
      note.is_a?(Hash) ? note.fetch(locale.to_s, '') : note
    end

    def change_note(locale = nil)
      locale ||= default_locale
      change_note = raw.fetch('changeNote', {})
      change_note.is_a?(Hash) ? change_note.fetch(locale.to_s, '') : change_note
    end

    def definition(locale = nil)
      locale ||= default_locale
      definition = raw.fetch('definition', {})
      definition.is_a?(Hash) ? definition.fetch(locale.to_s, '') : definition
    end

    def editorial_note(locale = nil)
      locale ||= default_locale
      editorial_note = raw.fetch('editorialNote', {})
      editorial_note.is_a?(Hash) ? editorial_note.fetch(locale.to_s, '') : editorial_note
    end

    def example(locale = nil)
      locale ||= default_locale
      example = raw.fetch('example', {})
      example.is_a?(Hash) ? example.fetch(locale.to_s, '') : example
    end

    def history_note(locale = nil)
      locale ||= default_locale
      history_note = raw.fetch('historyNote', {})
      history_note.is_a?(Hash) ? history_note.fetch(locale.to_s, '') : history_note
    end

    def scope_note(locale = nil)
      locale ||= default_locale
      scope_note = raw.fetch('scopeNote', {})
      scope_note.is_a?(Hash) ? scope_note.fetch(locale.to_s, '') : scope_note
    end
  end
end
