# The global cross-region profile Bedrock publishes for the model. Looked up rather than
# written into copy_from as a string so that a wrong ID fails the plan, not the apply.
data "aws_bedrock_inference_profile" "claude_opus_5_5_global" {
  inference_profile_id = "global.anthropic.claude-opus-5-5"
}

locals {
  # The foundation model the global profile routes to, for the IAM policy.
  claude_opus_5_5_model_id = regex("foundation-model/(.+)$", data.aws_bedrock_inference_profile.claude_opus_5_5_global.models[0].model_arn)[0]
}

resource "aws_bedrock_inference_profile" "claude_opus_5_5" {
  name        = "Claude Opus 5.5"
  description = "Claude Opus 5.5"

  model_source {
    copy_from = data.aws_bedrock_inference_profile.claude_opus_5_5_global.inference_profile_arn
  }
}
