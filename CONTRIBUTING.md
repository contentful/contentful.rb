# Contributing

Thanks for helping improve `contentful.rb`.

## Development with Dev Containers

This repository includes a `.devcontainer` configuration for a reproducible local setup. GitHub Actions uses the same devcontainer configuration for CI.

### Visual Studio Code

Open the repository in Visual Studio Code, install the Dev Containers extension if needed, then run `Dev Containers: Reopen in Container`. Wait for the container build and post-create setup to finish.

### Terminal or other editors

Install Docker and the Dev Container CLI (`npm install -g @devcontainers/cli`). From the repository root, run:

```bash
devcontainer up --workspace-folder .
devcontainer exec --workspace-folder . bash
```

### Verify the environment

```bash
bundle exec rake rspec_rubocop
```

## Other Useful Commands

```bash
bundle exec rake spec
bundle exec rake rubocop
```

## Pull Requests

1. Fork the repository and create a branch for your change.
2. Run the relevant checks from the dev container.
3. Open a pull request with a short summary of the change and any follow-up context.
