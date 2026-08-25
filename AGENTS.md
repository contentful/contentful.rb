# AGENTS.md

Operating notes for coding agents working in `contentful.rb`, the Ruby client for
the Contentful [Content Delivery API](https://www.contentful.com/developers/docs/references/content-delivery-api/)
and [Content Preview API](https://www.contentful.com/developers/docs/references/content-preview-api/).
The gem is published to RubyGems as [`contentful`](https://rubygems.org/gems/contentful).

Read [ARCHITECTURE.md](ARCHITECTURE.md) for how the library is put together and
[CONTRIBUTING.md](CONTRIBUTING.md) for the human contributor workflow.

## Repository shape

- `lib/contentful.rb` — the only require entry point. It loads `contentful/version`,
  `contentful/support` and `contentful/client`.
- `lib/contentful/client.rb` — `Contentful::Client`, the public surface: configuration
  defaults, one method per CDA endpoint, HTTP execution, rate-limit retry.
- `lib/contentful/` — everything else: `request.rb` / `response.rb` (transport),
  `resource_builder.rb` (JSON to objects), `base_resource.rb` / `fields_resource.rb`
  and the concrete resource classes, `includes.rb` (link resolution index),
  `coercions.rb` + `field.rb` (field type coercion), `sync.rb` / `sync_page.rb`,
  `error.rb`, `content_type_cache.rb`.
- `spec/` — RSpec suite. `spec/support/` holds the shared test client and VCR setup;
  `spec/fixtures/json_responses/` and `spec/fixtures/vcr_cassettes/` hold recorded data.
- `examples/` — runnable illustrations of raw mode, custom classes, error raising and queries.
- `.devcontainer/` — the build environment used both locally and in CI.

## Build, test, lint

Everything runs inside the dev container. This is deliberate — see
[docs/ADRs/2026-08-25-devcontainer-as-the-single-build-environment.md](docs/ADRs/2026-08-25-devcontainer-as-the-single-build-environment.md).

```bash
devcontainer up --workspace-folder .
devcontainer exec --workspace-folder . bash
```

Inside the container:

```bash
bundle exec rake rspec_rubocop   # specs + RuboCop, the same task CI runs
bundle exec rake spec            # RSpec only
bundle exec rake rubocop         # RuboCop only
```

The container's `postCreateCommand` runs `bundle _2.3.26_ install`, and CI invokes
`bundle _2.3.26_ exec rake rspec_rubocop`. Bundler `2.3.26` is pinned in
`.devcontainer/Dockerfile`; if you see Bundler version errors, use the `_2.3.26_`
form rather than changing the pin.

`rake` with no arguments runs `spec`. Gem packaging tasks come from the
`rubygems-tasks` gem (`Gem::Tasks.new` in `Rakefile`) — run `bundle exec rake -T`
to list them. `Guardfile` wires up `guard-rspec`, `guard-rubocop` and `guard-yard`
for a watch loop.

## Things to know before you change code

- **The specs never hit the network.** WebMock plus VCR (`spec/support/vcr.rb`,
  cassettes recorded with `record: :once`) back every request, and
  `spec/support/client.rb` builds clients against Contentful's public example space.
  Do not add a spec that requires real credentials, and do not commit new cassettes
  recorded against a private space.
- **No credentials belong in this repo.** Access tokens are passed in by callers via
  `Contentful::Client.new(space:, access_token:)`. There is no `.env` handling and none
  should be added.
- **RuboCop is enforced in CI**, configured by `.rubocop.yml` which inherits
  `.rubocop_todo.yml`. The todo file is generated output — if you fix offences, prefer
  removing the corresponding entry over adding new exclusions. `.rubocop.yml` already
  excludes `spec/**/*`, `examples/**/*`, `contentful.gemspec`, `Gemfile`, `Rakefile`
  and `Guardfile`.
- **Public methods carry YARD comments** (`@param`, `@return`, `@option`), and internals
  are marked `# @private`. `.yardopts` passes `--no-private`, so anything you mark private
  drops out of the generated docs. Match the surrounding style when adding methods.
- **Resources are marshallable on purpose.** `BaseResource`, `FieldsResource`,
  `Contentful::Array` and `Includes` all implement `marshal_dump` / `marshal_load` so
  entries survive a Rails cache round trip. If you add state to a resource, extend those
  methods too or it will be silently lost.
- **Include resolution is depth-limited** (`max_include_resolution_depth`, default 20) and
  indexed by `Includes#lookup`. Changing either affects response-shape behaviour that
  `spec/auto_includes_spec.rb` and `spec/includes_spec.rb` pin down.
- **Ruby support:** CI runs 3.2, 3.3 and 3.4. `contentful.gemspec` still carries a
  `RUBY_VERSION.start_with?('1.')` branch with older `http`/`json` constraints; leave it
  alone unless you are deliberately dropping 1.x.

## Change conventions

- Add a bullet under `## Unreleased` in `CHANGELOG.md` for anything user-visible.
- Do not bump `Contentful::VERSION` in a feature or fix PR. Releases are a separate,
  manual step — `RELEASE.md` is the checklist, and history shows dedicated
  `Bump to version X.Y.Z` commits.
- Commit subjects in recent history use conventional prefixes (`feat:`, `fix:`, `chore:`,
  `docs:`) and often carry a Jira key, e.g. `feat: support http gem 6.x [DX-1170] (#279)`.
- Dependency bumps are handled by Renovate (`renovate.json` extends
  `local>contentful/renovate-config`); do not hand-roll them.
- `Gemfile.lock` is gitignored. Do not commit it.

## Ownership

`.github/CODEOWNERS` and `catalog-info.yaml` both assign this repo to
`team-developer-experience`. It is registered in Backstage as a tier-4 library, with CI
alerts routed to the `sdk-bots` Slack channel.
