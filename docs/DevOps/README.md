# DevOps Skill Map

This skill map is based on [roadmap.sh/devops](https://roadmap.sh/devops).

Understanding Level:
- 1: Understand basic concepts
  - Can explain the basic concepts and terminology
  - Can follow tutorials and documentation
  - Example: Can explain what Docker containers are and run basic Docker commands
- 2: Can use in practice
  - Can implement solutions independently
  - Can troubleshoot common issues
  - Example: Can set up a CI/CD pipeline with GitHub Actions for a real project
- 3: Can teach others
  - Can design and implement complex solutions
  - Can mentor others and write technical documentation
  - Example: Can design and implement a complete Kubernetes cluster architecture
- 4: Expert
  - Can innovate and create new solutions
  - Can contribute to the technology's development
  - Example: Can contribute to the core development of tools like Terraform or Kubernetes

Legend:
- Required = Personal Recommendation / Opinion (🟣)
- Alternative = Alternative Option (🟢)
- Optional = Order not strict / learn anytime (⚪️)

## 01_Learn a Programming Language
| Technology/Tool      | Understanding | Recommendation | Reference Links                                 |
|----------------------|---------------|----------------|-------------------------------------------------|
| Python               | 2             | Required 🟣    | https://www.udemy.com/course/python-beginner ★- |
| Go                   |               | Required 🟣    |                                                 |
| Ruby                 |               | Alternative 🟢 |                                                 |
| Rust                 |               | Alternative 🟢 |                                                 |
| JavaScript / Node.js |               | Alternative 🟢 |                                                 |

## 02_Operating Systems
| Technology/Tool       | Understanding | Recommendation | Reference Links |
|-----------------------|---------------|----------------|-----------------|
| Linux (Ubuntu/Debian) | 2             | Required 🟣    |                 |
| RHEL / Derivatives    |               | Required 🟣    |                 |
| FreeBSD               |               | Required 🟣    |                 |
| SUSE Linux            |               | Alternative 🟢 |                 |
| Windows               | 2             | Alternative 🟢 |                 |
| OpenBSD               |               | Alternative 🟢 |                 |
| NetBSD                |               | Alternative 🟢 |                 |

## 03_Terminal Knowledge
| Technology/Tool        | Understanding | Recommendation | Reference Links |
|------------------------|---------------|----------------|-----------------|
| Bash                   |               | Required 🟣    |                 |
| Vim                    |               | Required 🟣    |                 |
| Nano                   |               | Required 🟣    |                 |
| Emacs                  |               | Required 🟣    |                 |
| Process Monitoring     |               | Required 🟣    |                 |
| Performance Monitoring |               | Required 🟣    |                 |
| Networking Tools       |               | Required 🟣    |                 |
| Text Manipulation      |               | Required 🟣    |                 |
| PowerShell             | 2             | Alternative 🟢 |                 |

## 04_Version Control Systems
| Technology/Tool | Understanding | Recommendation | Reference Links |
|-----------------|---------------|----------------|-----------------|
| Git             | 2             | Required 🟣    |                 |

## 05_VCS Hosting
| Technology/Tool | Understanding | Recommendation | Reference Links |
|-----------------|---------------|----------------|-----------------|
| GitHub          | 2             | Required 🟣    |                 |
| GitLab          | 2             | Alternative 🟢 |                 |
| Bitbucket       |               | Alternative 🟢 |                 |

## 06_Containers
| Technology/Tool | Understanding | Recommendation | Reference Links                           |
|-----------------|---------------|----------------|-------------------------------------------|
| Docker          | 1             | Required 🟣    | https://www.udemy.com/course/ok-docker ★5 |
| LXC             |               | Alternative 🟢 |                                           |

## 07_What is and how to setup X?
| Technology/Tool | Understanding | Recommendation | Reference Links |
|-----------------|---------------|----------------|-----------------|
| Forward Proxy   | 1             | Required 🟣    |                 |
| Reverse Proxy   | 1             | Required 🟣    |                 |
| Caching Server  | 1             | Required 🟣    |                 |
| Firewall        | 1             | Required 🟣    |                 |
| Load Balancer   | 1             | Required 🟣    |                 |
| Nginx           | 1             | Required 🟣    |                 |
| Caddy           |               | Alternative 🟢 |                 |
| Tomcat          |               | Alternative 🟢 |                 |
| Apache          |               | Alternative 🟢 |                 |
| IIS             |               | Alternative 🟢 |                 |

## 08_Networking & Protocols
| Technology/Tool        | Understanding | Recommendation | Reference Links |
|------------------------|---------------|----------------|-----------------|
| DNS                    | 1             | Required 🟣    |                 |
| HTTP                   | 1             | Required 🟣    |                 |
| HTTPS                  | 1             | Required 🟣    |                 |
| SSL/TLS                | 1             | Required 🟣    |                 |
| SSH                    | 1             | Required 🟣    |                 |
| FTP/SFTP               | 1             | Alternative 🟢 |                 |
| OSI Model              | 1             | Optional ⚪️    |                 |
| Email Protocols        |               | Optional ⚪️    |                 |
| - White / Grey Listing |               | Optional ⚪️    |                 |
| - SMTP                 | 1             | Optional ⚪️    |                 |
| - IMAP                 | 1             | Optional ⚪️    |                 |
| - POP3S                | 1             | Optional ⚪️    |                 |
| - DMARC                | 1             | Optional ⚪️    |                 |
| - SPF                  | 1             | Optional ⚪️    |                 |
| - Domain Keys          |               | Optional ⚪️    |                 |

## 09_Cloud Providers
| Technology/Tool | Understanding | Recommendation | Reference Links |
|-----------------|---------------|----------------|-----------------|
| AWS             | 3             | Required 🟣    |                 |
| Azure           |              | Required 🟣    |                 |
| Google Cloud    |              | Required 🟣    |                 |
| Digital Ocean   |               | Alternative 🟢 |                 |
| Alibaba Cloud   |               | Alternative 🟢 |                 |
| Hetzner         |               | Alternative 🟢 |                 |
| Contabo         |               | Alternative 🟢 |                 |
| Heroku          |               | Alternative 🟢 |                 |

## 10_Serverless
| Technology/Tool | Understanding | Recommendation | Reference Links |
|-----------------|---------------|----------------|-----------------|
| AWS Lambda      | 2             | Required 🟣    |                 |
| Cloudflare      |               | Required 🟣    |                 |
| Azure Functions |               | Alternative 🟢 |                 |
| Vercel          |               | Alternative 🟢 |                 |
| Netlify         |               | Alternative 🟢 |                 |
| GCP Functions   |               | Alternative 🟢 |                 |

## 11_Provisioning
| Technology/Tool | Understanding | Recommendation | Reference Links                                    |
|-----------------|---------------|----------------|----------------------------------------------------|
| Terraform       | 2             | Required 🟣    | https://www.udemy.com/course/iac-with-terraform ★4 |
| AWS CDK         |               | Alternative 🟢 |                                                    |
| CloudFormation  | 1             | Alternative 🟢 |                                                    |
| Pulumi          |               | Alternative 🟢 |                                                    |

## 12_Configuration Management
| Technology/Tool | Understanding | Recommendation | Reference Links                                                    |
|-----------------|---------------|----------------|--------------------------------------------------------------------|
| Ansible         | 1             | Required 🟣    | https://www.udemy.com/course/aws-ansibleinfrastructure-as-code/ ★5 |
| Chef            |               | Alternative 🟢 |                                                                    |
| Puppet          |               | Alternative 🟢 |                                                                    |

## 13_CI/CD Tools
| Technology/Tool | Understanding | Recommendation | Reference Links                                                   |
|-----------------|---------------|----------------|-------------------------------------------------------------------|
| GitHub Actions  | 2             | Required 🟣    | https://www.udemy.com/course/github-actions-the-complete-guide ★5 |
| Circle CI       |               | Required 🟣    |                                                                   |
| GitLab CI       | 1             | Required 🟣    |                                                                   |
| TeamCity        |               | Alternative 🟢 |                                                                   |
| Jenkins         |               | Alternative 🟢 |                                                                   |
| Travis CI       |               | Alternative 🟢 |                                                                   |
| Drone           |               | Alternative 🟢 |                                                                   |

## 14_Secret Management
| Technology/Tool      | Understanding | Recommendation | Reference Links |
|----------------------|---------------|----------------|-----------------|
| Vault                | 1             | Required 🟣    |                 |
| Sealed Secrets       |               | Alternative 🟢 |                 |
| SOPs                 |               | Alternative 🟢 |                 |
| Cloud Specific Tools |               | Alternative 🟢 |                 |

## 15_Infrastructure Monitoring
| Technology/Tool | Understanding | Recommendation | Reference Links                                      |
|-----------------|---------------|----------------|------------------------------------------------------|
| Prometheus      | 1             | Required 🟣    | https://www.udemy.com/course/awsgrafanaprometheus ★5 |
| Grafana         | 1             | Required 🟣    | https://www.udemy.com/course/awsgrafanaprometheus ★5 |
| Datadog         |               | Required 🟣    |                                                      |
| Zabbix          |               | Alternative 🟢 |                                                      |

## 16_Logs Management
| Technology/Tool | Understanding | Recommendation | Reference Links |
|-----------------|---------------|----------------|-----------------|
| Loki            |               | Required 🟣    |                 |
| Elastic Stack   |               | Required 🟣    |                 |
| Splunk          |               | Alternative 🟢 |                 |
| Papertrail      |               | Alternative 🟢 |                 |
| Graylog         |               | Alternative 🟢 |                 |

## 17_Container Orchestration
| Technology/Tool    | Understanding | Recommendation | Reference Links                                                                    |
|--------------------|---------------|----------------|------------------------------------------------------------------------------------|
| Kubernetes         | 1             | Required 🟣    | https://www.udemy.com/course/kubernetes-docker-container-devops-kanzen-nyumon ★4.5 |
| EKS (AWS)          |               | Alternative 🟢 |                                                                                    |
| GKE (Google Cloud) |               | Alternative 🟢 |                                                                                    |
| AKS (Azure)        |               | Alternative 🟢 |                                                                                    |
| AWS ECS / Fargate  |               | Alternative 🟢 |                                                                                    |
| Docker Swarm       |               | Alternative 🟢 |                                                                                    |

## 18_Application Monitoring
| Technology/Tool | Understanding | Recommendation | Reference Links |
|-----------------|---------------|----------------|-----------------|
| Datadog         |               | Alternative 🟢 |                 |
| Prometheus      |               | Alternative 🟢 |                 |
| Jaeger          |               | Alternative 🟢 |                 |
| New Relic       |               | Alternative 🟢 |                 |
| OpenTelemetry   |               | Alternative 🟢 |                 |

## 19_Artifact Management
| Technology/Tool | Understanding | Recommendation | Reference Links |
|-----------------|---------------|----------------|-----------------|
| Artifactory     |               | Required 🟣    |                 |
| Nexus           |               | Alternative 🟢 |                 |
| Cloud Smith     |               | Alternative 🟢 |                 |

## 20_GitOps
| Technology/Tool | Understanding | Recommendation | Reference Links |
|-----------------|---------------|----------------|-----------------|
| ArgoCD          |               | Required 🟣    |                 |
| FluxCD          |               | Alternative 🟢 |                 |

## 21_Service Mesh
| Technology/Tool | Understanding | Recommendation | Reference Links |
|-----------------|---------------|----------------|-----------------|
| Istio           |               | Required 🟣    |                 |
| Consul          |               | Required 🟣    |                 |
| Linkerd         |               | Alternative 🟢 |                 |
| Envoy           |               | Alternative 🟢 |                 |

## 22_Cloud Design Patterns
| Technology/Tool           | Understanding | Recommendation | Reference Links |
|---------------------------|---------------|----------------|-----------------|
| Availability              |               | Required 🟣    |                 |
| Data Management           |               | Required 🟣    |                 |
| Design and Implementation |               | Required 🟣    |                 |
| Management and Monitoring |               | Required 🟣    |                 |
