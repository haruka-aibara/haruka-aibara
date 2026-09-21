locals {
  # Resource naming. default_tags (Owner/Environment/Project/Repository) moved
  # to the root module's provider "aws" block, since a child module cannot
  # scope default_tags to only its own resources.
  project_name = "bedrock-slack-ai-chatbot"
}
