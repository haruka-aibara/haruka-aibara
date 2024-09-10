resource "aws_ssm_document" "ansible_playbook" {
  name            = "${var.project_name}AnsiblePlaybookExecution"
  document_type   = "Command"
  document_format = "YAML"

  content = <<DOC
schemaVersion: '2.2'
description: Execute Ansible playbook using SSM
parameters:
  playbook:
    type: String
    description: "(Required) Name of the Ansible playbook to run"
    default: ${var.ansible_playbook_name}
mainSteps:
  - action: aws:runShellScript
    name: runAnsiblePlaybook
    inputs:
      runCommand:
        - "cd /tmp"
        - "aws s3 cp s3://${var.s3_bucket_name}/ansible.cfg ."
        - "aws s3 cp s3://${var.s3_bucket_name}/inventory ."
        - "aws s3 cp s3://${var.s3_bucket_name}/playbooks/{{ playbook }} ."
        - "ansible-playbook {{ playbook }}"
DOC
}
