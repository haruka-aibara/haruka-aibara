#!/bin/bash
set -e

echo "Running post-create setup..."

# Source environment for uv
# source $HOME/.cargo/env
source $HOME/.local/bin/env

# Install Python tools with uv
# uv tool install pycodestyle
# uv tool install flake8
# uv tool install pylint
# uv tool install pyre-check
# uv tool install pytest

# Set up git configuration
# echo "Setting up git configuration..."
# Note: You'll need to manually set these after container creation
# git config --global user.name "Your Name"
# git config --global user.email "youremail@domain.com"

# Add git branch display to bash prompt
# echo "Setting up git branch display in prompt..."
# if [ ! -e /etc/bash_completion.d/git-prompt ]; then
#   echo "Git prompt not found, installing..."
#   # If git-prompt is not available, fetch it
#   sudo mkdir -p /etc/bash_completion.d/
#   sudo wget -q -O /etc/bash_completion.d/git-prompt https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh
#   sudo chmod +x /etc/bash_completion.d/git-prompt
# fi

# Add git branch to bash prompt if not already there
# if ! grep -q "__git_ps1" ~/.bashrc; then
#   echo '
# # display git branch name
# if [ -e /etc/bash_completion.d/git-prompt ]; then
#     source /etc/bash_completion.d/git-prompt
#     PS1='\''\\[\\e]0;\\u@\\h: \\w\\a\\]${debian_chroot:+($debian_chroot)}\\[\\033[01;32m\\]\\u@\\h\\[\\033[00m\\]:\\[\\033[01;34m\\]\\w\\[\\033[00m\\] $(__git_ps1 " (%s)") \\$ '\''
# fi' >> ~/.bashrc
# fi

# Set up Terraform with tenv if available
# if command -v snap >/dev/null 2>&1; then
#   echo "Setting up Terraform with tenv..."
#   sudo snap install tenv
#   tenv tf install latest-stable
#   
#   # Add tenv to PATH if not already there
#   if ! grep -q "tenv update-path" ~/.bashrc; then
#     echo '
# # tenv
# export PATH=$(tenv update-path):$PATH' >> ~/.bashrc
#   fi
# fi

# Add custom Mermaid config for Markdown Preview Enhanced
# mkdir -p ~/.mume/
# cat > ~/.mume/custom.css << 'EOF'
# /* Custom Mermaid styling */
# .mermaid svg {
#   max-width: 100%;
# }
# EOF

# Setup Markdown Preview Enhanced HTML Head customization
# mkdir -p ~/.mume/
# cat > ~/.mume/style.less << 'EOF'
# /* The content below will be included at the end of the <head> element. */
# <script type="text/javascript">
#    const configureMermaidIconPacks = () => {
#     window["mermaid"].registerIconPacks([
#       {
#         name: "logos",
#         loader: () =>
#           fetch("https://unpkg.com/@iconify-json/logos/icons.json").then(
#             (res) => res.json()
#           ),
#       },
#     ]);
#   };
# 
#   // ref: https://stackoverflow.com/questions/39993676/code-inside-domcontentloaded-event-not-working
#   if (document.readyState !== 'loading') {
#     configureMermaidIconPacks();
#   } else {
#     document.addEventListener("DOMContentLoaded", () => {
#       configureMermaidIconPacks();
#     });
#   }
# </script>
# EOF

# GitHub CLI auth reminder
# echo "✅ Setup complete!"
# echo "ℹ️ Remember to authenticate GitHub CLI with: gh auth login"
# echo "ℹ️ Remember to set up your git credentials with:"
# echo "   git config --global user.name \"Your Name\""
# echo "   git config --global user.email \"youremail@domain.com\""

# Source .bashrc to apply changes
source ~/.bashrc
