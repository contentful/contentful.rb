# Architecture

`contentful.rb` is a read-only HTTP client for Contentful's Content Delivery and Content
Preview APIs. It has one job: take a query, fetch JSON from the CDA, and hand back Ruby
objects with links resolved and field values coerced to native types. There is no write
path, no local persistence and no background work.

## Layers

```
Contentful::Client            configuration, one method per endpoint, retry policy
        |
Contentful::Request           builds the relative URL, normalizes the query hash
        |
Client.get_http               the `http` gem: headers, proxy, timeouts, instrumentation
        |
Contentful::Response          gunzip, JSON parse, HTTP status to :ok / :error / :no_content
        |
Contentful::ResourceBuilder   picks a class per `sys.type`, walks includes, builds objects
        |
Contentful::BaseResource ...   Entry, Asset, ContentType, Space, Locale, Array, Link, ...
```

`lib/contentful.rb` requires only `contentful/version`, `contentful/support` and
`contentful/client`; everything else is pulled in transitively via `require_relative`.

### Client

`Contentful::Client` (`lib/contentful/client.rb`) holds `DEFAULT_CONFIGURATION` — the
complete set of knobs, from `api_url` and `environment` through
`max_include_resolution_depth` and `http_instrumenter`. `initialize` merges user options
over the defaults, then runs `normalize_configuration!` and `validate_configuration!`,
which fail fast with `ArgumentError` on a missing space, token, api_url or default locale.

Each endpoint is a thin wrapper that constructs a `Request`: `space`, `content_type(s)`,
`entry`/`entries`, `asset(s)`, `locales`, `taxonomy_concept(s)`,
`taxonomy_concept_scheme(s)`, and `sync`. All but `space` go through `environment_url`, so
requests are scoped to `/spaces/:space/environments/:environment/...`. `entry(id)` is
implemented as an `entries` query filtered by `sys.id` returning the first item, not as a
single-resource fetch.

Two client behaviours are worth knowing:

- **`normalize_select!`** rewrites a `:select` query so the full `sys` block is always
  requested. The SDK needs `sys.type` to build resources at all, and the comment in the
  source notes this was made consistent across Contentful's SDKs.
- **Rate limiting** is handled in `Client#get`: a `Contentful::RateLimitExceeded` is
  retried up to `max_rate_limit_retries` times as long as the reset window is under
  `max_rate_limit_wait`, sleeping `reset_time * rand(1.0..1.2)` to jitter the retry.

The `X-Contentful-User-Agent` header is assembled from five parts — sdk, app, integration,
platform, os — by `contentful_user_agent` and friends, which is why the client exposes
`application_name`/`integration_name` configuration.

### Response

`Contentful::Response` (`lib/contentful/response.rb`) classifies the raw HTTP response
before any resource building happens. It gunzips when `Content-Encoding: gzip` is set
(the client requests gzip by default), parses with `MultiJson`, and maps status codes to
an error object via `Contentful::Error[status_code]`. `lib/contentful/error.rb` defines the
class per code — `BadRequest` (400), `Unauthorized` (401), `AccessDenied` (403),
`NotFound` (404), `RateLimitExceeded` (429), `ServerError` (500), `BadGateway` (502),
`ServiceUnavailable` (503) — each with its own `default_error_message` and `handle_details`
so the raised message reflects the API's error payload, including the request ID.

Whether an error is raised or returned is governed by `raise_errors`. `raw_mode` short-circuits
resource building entirely and returns the `Response`.

### Resource building

`ResourceBuilder` (`lib/contentful/resource_builder.rb`) is the dispatcher. It branches on
whether the payload is an `Array` and, for arrays, whether it is a sync page
(`nextSyncUrl` / `nextPageUrl` present) so it can return a `SyncPage` instead of a
`Contentful::Array`. `DEFAULT_RESOURCE_MAPPING` maps each `sys.type` to a class and
`BUILDABLES` gates what it will accept; unknown types raise `UnparsableResource`.

Both mappings are overridable per client. `resource_mapping` accepts a class or a callable
for wholesale replacement; `entry_mapping` maps a content type ID to a custom `Entry`
subclass. `examples/custom_classes.rb` shows the shape.

`BaseResource` (`lib/contentful/base_resource.rb`) hydrates `sys` and `metadata`,
snake-casing keys through `Support.snakify` (skippable with `use_camel_case`), turning
`space`/`contentType`/`environment` into `Link`s and timestamps into `DateTime`s, then
defines a singleton reader per key. `FieldsResource` adds the same treatment for `fields`,
with the locale dimension either nested (`locale: '*'` responses) or flat.

### Link resolution and includes

`Includes` (`lib/contentful/includes.rb`) is the performance-sensitive piece. Rather than
scanning the `items` + `includes` arrays for every link, it builds a
`"#{type}:#{id}" => raw_hash` lookup once and resolves links through it. It overrides `==`,
`+` and `dup` to keep the lookup coherent while avoiding needless duplication when a set is
merged with itself.

`Entry#coerce` decides, per field, whether the value is a link, an array of links, or a
plain value. Links are resolved via `Entry#build_nested_resource`, which recurses through a
fresh `ResourceBuilder` at `depth + 1` and falls back to returning a bare `Link` once
`max_include_resolution_depth` (default 20) is reached. The API itself caps includes at 10;
the higher default exists so that back-references into upper levels still resolve.
Entries listed in the response's `errors` array are treated as unresolvable by
`Support.unresolvable?` and dropped.

### Field coercion

Coercion needs the content type schema, which arrives separately from entries. `ContentTypeCache`
(`lib/contentful/content_type_cache.rb`) is a process-wide `space_id -> content_type_id`
store, filled either eagerly by `dynamic_entries: :auto` (which calls
`update_dynamic_entry_cache!` at client construction) or manually via
`register_dynamic_entry`. When a content type is cached, `Field#coerce`
(`lib/contentful/field.rb`) looks the field's type up in `KNOWN_TYPES` and applies the
matching class from `lib/contentful/coercions.rb`: `String`, `Text`, `Symbol`, `Integer`,
`Number`, `Boolean`, `Date`, `Location`, `Object`, `Array`, `Link` and `RichText`.

`RichTextCoercion` is the non-trivial one — it walks the document tree, resolves embedded
entry and asset targets through the same `Includes` lookup, and deletes nodes whose targets
are unresolvable. `LinkCoercion` is intentionally a no-op because link resolution is
depth-aware and therefore owned by `Entry`.

Because coercion is cache-dependent, the same field can come back as a raw `Hash` or as a
coerced object depending on whether the content type was cached — this is expected, not a bug.
`Entry#method_missing` closes a related gap: a field defined on the content type but absent
from the response raises `EmptyFieldError` unless `raise_for_empty_fields` is disabled.

### Collections and sync

`ArrayLike` (`lib/contentful/array_like.rb`) is a mixin providing `Enumerable`, `each`,
`size`, `[]`, `last` and `to_ary` for anything with an `items` property; `Contentful::Array`,
`SyncPage` and `Includes` all include it. `Contentful::Array#next_page` re-issues the
original query with an incremented `skip` by mapping `sys.type` back to the client method.

`Sync` (`lib/contentful/sync.rb`) drives the `/sync` endpoint. It holds `next_sync_url`,
issues one request per page through `each_page`, and back-links each `SyncPage` to itself so
`SyncPage#next_page` can continue the chain. Sync payloads always come back fully localized,
so `ResourceBuilder#localized?` forces localized hydration for them.

### Marshalling

`BaseResource`, `FieldsResource`, `Contentful::Array` and `Includes` implement
`marshal_dump` / `marshal_load` so resources can be stored in a cache such as Rails'.
Two details matter: the logger is dropped from the dumped configuration because file handles
are not marshallable, and `entry_mapping` is dumped as class name strings and re-resolved
through `Object.const_get` on load.

## Directory map

| Path | Contents |
| --- | --- |
| `lib/contentful.rb` | Require entry point |
| `lib/contentful/` | The library — client, transport, resources, coercions |
| `spec/` | RSpec suite, one file per resource or behaviour |
| `spec/support/` | Shared test client, JSON fixture helpers, VCR configuration |
| `spec/fixtures/` | `json_responses/` stubs and `vcr_cassettes/` recordings |
| `examples/` | Runnable scripts: raw mode, custom classes, queries, error raising |
| `.devcontainer/` | Dockerfile and devcontainer.json — the build environment |
| `.github/workflows/ci.yml` | The only CI pipeline |

## Build and release

The dev container is the build environment for both contributors and CI; see
[docs/ADRs/2026-08-25-devcontainer-as-the-single-build-environment.md](docs/ADRs/2026-08-25-devcontainer-as-the-single-build-environment.md).
`.github/workflows/ci.yml` runs `rake rspec_rubocop` across Ruby 3.2, 3.3 and 3.4 by
starting the container per matrix entry with the `RUBY_VERSION` build arg.

Releases are manual. `RELEASE.md` is the checklist, the version lives in
`lib/contentful/version.rb`, `CHANGELOG.md` carries the user-facing notes, and packaging
tasks come from `rubygems-tasks` via `Gem::Tasks.new` in the `Rakefile`.

## Dependencies

Runtime dependencies are deliberately minimal: `http` (constrained to `> 0.8, < 7.0`) and
`multi_json` (`~> 1.15`). `contentful.gemspec` keeps a separate branch for Ruby 1.x with
tighter `http` and `json` pins. Development dependencies cover RSpec, `rr`, VCR, WebMock,
SimpleCov, RuboCop and the Guard plugins. Renovate manages upgrades via `renovate.json`.
