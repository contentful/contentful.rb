# `http` gem as HTTP Client

## Status

Accepted

## Context

The library needs to make HTTPS requests to the Contentful CDA. Ruby's built-in `net/http` is verbose and lacks built-in gzip decoding, proxy support, and timeout configuration. Several HTTP gem options exist in the Ruby ecosystem: `faraday`, `httparty`, `rest-client`, `http`.

## Decision

The `http` gem (by httprb) was chosen and has been maintained as the HTTP client since the library's early versions. The dependency range is `> 0.8, < 6.0` to allow compatibility across major versions while excluding breaking changes.

Key reasons (inferred from usage patterns and CHANGELOG):
- Native gzip response encoding support (used via `gzip_encoded: true` default)
- Clean proxy support (`via` method maps directly to `proxy_host/port/username/password`)
- HTTP feature instrumentation interface (`HTTP::Features::Instrumentation::Instrumenter`) — used in v2.19 to add the `http_instrumenter` option
- Lightweight — no middleware stack overhead vs. Faraday

`multi_json` is used as a JSON parsing adapter on top of whatever JSON library the consumer has installed, avoiding forcing a specific JSON gem.

**Source:** git history (multiple `http.rb` version bumps: `beb15d7`, `c0fb1ab`, `70d257d`, `92342be`), `contentful.gemspec` runtime dependencies.

## Consequences

- The `http` gem's API is a hard dependency — major version bumps in `http` require gemspec updates and potentially API call changes in `lib/contentful/client.rb`
- `multi_json` enables flexibility for apps that use `oj` or `yajl` for performance — but adds an indirection layer
- No request middleware stack (unlike Faraday) — custom behavior requires subclassing or the `http_instrumenter` hook
