# Taxonomy Endpoints Support (v2.18)

## Status

Accepted

## Context

Contentful introduced Taxonomy as a product feature — a SKOS-style hierarchical concept model with `TaxonomyConcept` and `TaxonomyConceptScheme` resources. These are first-class CDA resources returned by new API endpoints (`/taxonomy/concepts` and `/taxonomy/concept-schemes`). The Ruby SDK needed to support these endpoints and resource types to maintain parity with other Contentful SDKs.

## Decision

Two new resource classes were added (commit `73388a8`, v2.18.0):

- `Contentful::TaxonomyConcept` — maps CDA `TaxonomyConcept` JSON; exposes `pref_label`, `alt_labels`, `definition`, `note`, `broader`, `related`, `concept_schemes`
- `Contentful::TaxonomyConceptScheme` — maps CDA `TaxonomyConceptScheme` JSON; exposes `pref_label`, `definition`, `top_concepts`, `concepts`, `total_concepts`

Both were added to `ResourceBuilder::DEFAULT_RESOURCE_MAPPING` and `BUILDABLES`. Client methods added: `Client#taxonomy_concept(id)`, `Client#taxonomy_concepts(query)`, `Client#taxonomy_concept_scheme(id)`, `Client#taxonomy_concept_schemes(query)`.

Both classes follow the existing `BaseResource` pattern — no new base class was introduced.

**Source:** git commit `73388a8` ("Feature/taxonomy endpoints"), CHANGELOG.md v2.18.0 entry.

## Consequences

- Taxonomy resources are now queryable with the same pagination and filter patterns as entries/assets
- The `_metadata[:concepts]` field on entries links to TaxonomyConcept objects via `Link` (resolved like any other linked resource)
- No breaking changes — additive only
