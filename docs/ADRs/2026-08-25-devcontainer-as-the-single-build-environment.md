# Dev container as the single build environment

- **Date:** 2026-08-25
- **Status:** Accepted (in effect since commit `f746310`, 2026-03-31)

> This record was written on 2026-08-25 from the commit history and the current
> configuration files. It documents an existing decision rather than a new one. The
> rationale below is reconstructed from what the change did and from the wording the
> change added to `README.md` and `CONTRIBUTING.md`; no design discussion from the time is
> quoted here.

## Context

Until March 2026 this repository tested on CircleCI. `.circleci/config.yml` defined a
`test_and_lint` job that ran `gem install bundler:2.3.26`, `bundle install` and
`bundle exec rake rspec_rubocop` on `cimg/ruby` images across a Ruby version matrix
(see commit `fa44628`, "update ruby version matrix"). A separate
`.github/workflows/codeql.yml` had been added in commit `3c8632a` for code scanning.

Contributors, meanwhile, had no described local setup. There was no `CONTRIBUTING.md`, so
the local environment — Ruby version, Bundler version, whether `bundle install` had been
run with the same Bundler CI used — was whatever each contributor happened to have. The
Bundler pin existing only inside the CI config meant a green CI run and a local run were
not necessarily the same run.

## Decision

Commit `f746310` ("chore: add devcontainer contributor workflow [DX-822]", PR #274) made a
dev container the one build environment and used it for CI as well. Concretely, that commit:

- added `.devcontainer/Dockerfile`, based on
  `mcr.microsoft.com/devcontainers/ruby:1-${RUBY_VERSION}-bookworm` with
  `gem install bundler:2.3.26`, and `.devcontainer/devcontainer.json`, which sets a writable
  `BUNDLE_PATH` under the `vscode` user's home and runs `bundle _2.3.26_ install` as its
  `postCreateCommand`;
- added `.github/workflows/ci.yml`, which installs `@devcontainers/cli@0`, then runs
  `devcontainer up` followed by
  `devcontainer exec ... "bundle _2.3.26_ exec rake rspec_rubocop"` for each of Ruby 3.2,
  3.3 and 3.4 — passed into the image through the `RUBY_VERSION` build arg;
- deleted `.circleci/config.yml` and `.github/workflows/codeql.yml`;
- added `CONTRIBUTING.md` documenting both the VS Code path
  (`Dev Containers: Reopen in Container`) and the CLI path
  (`devcontainer up` / `devcontainer exec`), and pointed `README.md`'s CI badge at the new
  workflow.

The consequence is a single definition of the test environment: CI runs the same container
image, with the same Bundler, executing the same Rake task a contributor runs locally.

## Consequences

- **The dev container is the supported way to build and test.** `CONTRIBUTING.md` describes
  no host-Ruby path, and CI does not exercise one. Changes to Ruby versions, system packages
  or the Bundler pin belong in `.devcontainer/`, not in the workflow file.
- **The Bundler pin is load-bearing.** `2.3.26` appears in `.devcontainer/Dockerfile`, in
  `devcontainer.json`'s `postCreateCommand` and in `ci.yml`'s exec command. Changing it means
  changing all three. Note that `CONTRIBUTING.md` and `README.md` document plain
  `bundle exec rake rspec_rubocop`, which works inside the container because that Bundler is
  the installed one; CI uses the explicit `bundle _2.3.26_ exec` form.
- **CI is slower to start.** Every matrix entry installs the devcontainer CLI and builds the
  image before it can run a spec, where the previous CircleCI job started from a prebuilt
  Ruby image.
- **`.circleci/local-config.yml` is now orphaned.** It survived the deletion of
  `config.yml` (it was added in `fa44628`), so CircleCI has no pipeline configuration but the
  directory still exists. Its contents have also drifted: it pins `cimg/ruby:3.4` and
  `bundler:1.10.6`, which matches neither the current matrix nor the container's Bundler.
  Anyone reading it as current guidance would be misled.
- **CodeQL scanning is no longer configured *in this repository*.** The workflow was removed in
  the same commit. Scanning itself did not stop: `Analyze (ruby)` and `Analyze (actions)`
  checks still run on pull requests, so code scanning is now supplied outside this repo's
  `.github/workflows/` — GitHub's default setup or an organization-level configuration.
  Nothing in this repository records which, so treat the workflow's removal as a move rather
  than a removal of coverage, and verify in repository settings before assuming either.

## Evidence

- `f746310` — `chore: add devcontainer contributor workflow [DX-822] (#274)`, the commit that
  made the change.
- `fa44628` — `update ruby version matrix (#268)`, which added `.circleci/local-config.yml`.
- `3c8632a` — `Add CodeQL workflow for GitHub Actions (#271)`, which added the workflow later
  removed.
- Current files: `.devcontainer/Dockerfile`, `.devcontainer/devcontainer.json`,
  `.github/workflows/ci.yml`, `.circleci/local-config.yml`, `CONTRIBUTING.md`.
