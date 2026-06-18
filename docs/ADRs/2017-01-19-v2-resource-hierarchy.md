# v2.0 Resource Hierarchy Refactor

## Status

Accepted

## Context

The v1.x library embedded a reference to `Client` and `Request` directly into every resource object. This created tight coupling between resources and the HTTP layer, made marshalling (Ruby's object serialization) error-prone (loggers with file handles can't be marshalled), and resulted in a tangle of `CustomResource`, `Resource`, and `DynamicEntry` base classes that was hard to extend cleanly.

The 2.x release was planned to clean up the public API surface and establish a stable resource hierarchy. The RFC (later removed, see commit `66bbc01`) guided this work.

## Decision

All resource classes were reorganized into a two-level hierarchy:

- `BaseResource` — all Contentful objects with `sys` metadata; handles marshalling, equality, sys hydration
- `FieldsResource < BaseResource` — objects with a `fields` hash (Entry, Asset); handles field hydration, localization, coercion dispatch
- `Entry < FieldsResource` — content entries; adds link resolution and content type coercion
- `Asset < FieldsResource` — binary files

**Breaking changes accepted:**
- `Contentful::CustomResource` removed — custom classes now inherit from `Contentful::Entry`
- `Contentful::Resource` removed — all classes now inherit from `Contentful::BaseResource`
- `Contentful::DynamicEntry` removed — replaced by `Contentful::Entry` with `dynamic_entries: :auto`
- `sys` and `fields` hash keys changed from camelCase to snake_case
- `Contentful::Link#resolve` and `Contentful::Array#next_page` now require a `Client` argument
- `Contentful::ContentTypeCache::clear` exposed for manual cache management

`max_include_resolution_depth` (default: 20) was added to cap circular include resolution that was previously unbounded and could cause stack overflows.

**Source:** git commit `5a36daf` ("2.0.0 SDK"), CHANGELOG.md v2.0.0 entry.

## Consequences

- Cleaner extension points: custom resource and entry classes work predictably
- Marshalling works reliably (logger excluded from marshal dump)
- Public API changed — required a migration guide in the README
- Circular reference behavior is now explicit and tunable via `max_include_resolution_depth`
- `#inspect` output format changed — any string-based assertions in consumer tests needed updating
