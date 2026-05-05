# use_camel_case Client Option

## Status

Accepted

## Context

The v2.0 release standardized all field accessors and hash keys to `snake_case` (matching Ruby conventions). However, teams building isomorphic applications — sharing content model logic between a Ruby backend and a JavaScript frontend — found the mismatch between Ruby's `snake_case` and JavaScript's `camelCase` field names inconvenient and error-prone.

A follow-up request was filed to allow `camelCase` accessor style for these use cases.

## Decision

A `use_camel_case: true` client configuration option was added (v2.2.0, commit `5592c5b`). When enabled:

- All field accessor methods use `camelCase` (e.g., `entry.myField` instead of `entry.my_field`)
- All `sys` and `fields` hash keys are `camelCase` symbols
- The `support.rb` `snakify` utility accepts the `use_camel_case` flag and short-circuits accordingly

The default remains `false` (snake_case) — this is strictly opt-in.

**Source:** git commit `5592c5b` ("Add use_camel_case option"), CHANGELOG.md v2.2.0 entry.

## Consequences

- Isomorphic apps get consistent key naming across Ruby and JS
- Internal library code must pass `use_camel_case` through `@configuration` everywhere `Support.snakify` is called — adding it in the wrong place is a source of bugs (see follow-up fix in commit `740262a`)
- Default behavior is unchanged; existing consumers are unaffected
