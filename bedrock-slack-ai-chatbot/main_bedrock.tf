resource "aws_bedrock_inference_profile" "claude_opus_4_6" {
  name        = "Claude Opus 4.6"
  description = "Claude Opus 4.6"

  model_source {
    copy_from = "arn:aws:bedrock:ap-northeast-1:172580074565:inference-profile/global.anthropic.claude-opus-4-6-v1"
  }

  # model_source is write-only on this resource -- AWS never returns it on
  # read, so importing the existing profile leaves it null in state. Without
  # this, the very next plan sees model_source going from null to a value and
  # proposes a destroy+recreate of the live profile the bot depends on.
  # TODO(state-merge follow-up): remove once the import has landed and is
  # confirmed stable; needed again if copy_from ever has to change for real.
  lifecycle {
    ignore_changes = [model_source]
  }
}
