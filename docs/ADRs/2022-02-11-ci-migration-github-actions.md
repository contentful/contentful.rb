# CI Migration: Travis CI → CircleCI → GitHub Actions (Devcontainer)

## Status

Accepted

## Context

The project originally used Travis CI (`.travis.yml`). Travis CI began limiting free OSS usage in late 2020–2021, making it unreliable for community-maintained projects. The team migrated to CircleCI in early 2022, then further standardized on GitHub Actions in 2022 as part of broader Contentful OSS CI consolidation.

In 2024–2026, the DX team adopted the devcontainer-based CI pattern to ensure contributor environments and CI environments are identical, eliminating "works on my machine" failures.

## Decision

1. **2022 (commit `d770c6f`):** Added `.circleci/config.yml`; removed `.travis.yml`
2. **2022 (commit `5420414`):** Cleaned up the Travis remnant
3. **2023–2024 (commit `437a7c8`):** Migrated from CircleCI to GitHub Actions (`.github/workflows/ci.yml`); added Ruby 3.1, 3.2, 3.3 to the matrix; dropped 2.6 and 2.7
4. **2026 (commit `f746310`, DX-822):** Refactored CI to run entirely inside the devcontainer — `devcontainer up` + `devcontainer exec` pattern — so CI environment exactly matches local dev. Ruby version matrix is now driven by the `RUBY_VERSION` build arg (3.2, 3.3, 3.4).

**Source:** git commits `d770c6f`, `5420414`, `437a7c8`, `f746310`.

## Consequences

- CI and local dev are environment-identical (same Dockerfile, same Bundler version `2.3.26`)
- New contributors can reproduce any CI failure locally via `devcontainer exec`
- The Ruby version matrix is maintained in `.github/workflows/ci.yml` `matrix.ruby-version`; updating supported Ruby versions requires changing only that file and the devcontainer `ARG RUBY_VERSION` default
- CodeQL security scanning added as a separate workflow (`3c8632a`)
