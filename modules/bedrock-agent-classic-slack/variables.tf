variable "slack_team_id" {
  description = "Amazon Q Developer in chat applications（旧 AWS Chatbot）で認可済みの Slack ワークスペース ID。例: T07EA123LEP"
  type        = string
}

variable "slack_channel_id" {
  description = "エージェントと会話する Slack チャンネルの ID。例: C07EZ1ABC23"
  type        = string
}
