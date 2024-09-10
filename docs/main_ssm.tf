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
        - "export PATH=$PATH:/usr/local/bin"
        - "/usr/local/bin/aws s3 cp s3://${aws_s3_bucket.ansible_files.id}/ansible.cfg ."
        - "/usr/local/bin/aws s3 cp s3://${aws_s3_bucket.ansible_files.id}/inventory/aws_ec2.yml inventory/"
        - "/usr/local/bin/aws s3 cp s3://${aws_s3_bucket.ansible_files.id}/playbooks/{{ playbook }} ."
        - "/usr/local/bin/ansible-playbook {{ playbook }}"
DOC
}
