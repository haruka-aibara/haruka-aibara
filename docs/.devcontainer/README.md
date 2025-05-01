# Development Container for GitHub Codespaces

This directory contains the configuration for the development container used with GitHub Codespaces.

## What's Included

- Base Ubuntu image
- Common tools (unzip, jq, zip, gzip, tar, htop, tree)
- Git with branch display in prompt
- GitHub CLI
- Python 3.11 with essential tools (pip, pipx, uv)
  - Linters: ruff, flake8, pylint, pyre-check
  - Testing: pytest
- Node.js and npm
- Docker in Docker
- AWS CLI
- Terraform with tenv
- Ansible and ansible-lint
- VS Code extensions for all of the above

## VS Code Settings

The container comes with various VS Code settings preconfigured:
- Python linting and formatting with Ruff
- Markdown with image paste support and Mermaid diagrams
- Terraform auto-formatting
- Final newline insertion
- And more as specified in the `devcontainer.json` file

## Post-Creation Setup

After the container is created, you need to:

1. Authenticate GitHub CLI:
   ```bash
   gh auth login
   ```

2. Set up your Git credentials:
   ```bash
   git config --global user.name "Your Name"
   git config --global user.email "youremail@domain.com"
   ```

3. For AWS CLI, you'll need to configure credentials:
   ```bash
   aws configure
   ```

## Customization

You can customize this development container by:
- Modifying `devcontainer.json` to add/remove features and extensions
- Editing the `Dockerfile` to install additional packages
- Updating `post-create.sh` for additional setup steps

## Troubleshooting

If you encounter issues:
1. Check the VS Code logs (View > Output > Dev Containers)
2. Examine the terminal output during container creation
3. Try rebuilding the container (Ctrl+Shift+P > "Rebuild Container")