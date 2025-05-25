# DevOps Skill Map

This skill map is based on [roadmap.sh/devops](https://roadmap.sh/devops).

Understanding Level:
- 0: Unaware
  - Not aware of the technology/tool's existence
  - No knowledge about the technical domain
  - Example: Not aware of Docker or containerization technology
- 1: Basic Recognition
  - Only recognizes the name, no detailed understanding
  - Cannot explain functionality or operating principles
  - Example: Recognizes the name Docker but doesn't understand container technology details or operating principles
- 2: Basic Understanding
  - Understands the purpose and basic concepts of the technology/tool
  - Can explain basic terminology and concepts
  - Example: Understands Docker's purpose and basic container technology concepts and can explain them
- 3: Theoretical Knowledge
  - Has systematic learning knowledge but limited practical experience
  - Understands basic operation procedures and concepts
  - Example: Understands Docker's basic operation procedures and concepts but has limited practical experience
- 4: Practical Knowledge
  - Has some practical experience and can solve basic problems
  - Can utilize in basic work situations
  - Example: Can set up basic Docker environments and solve problems
- 5: Professional Usage
  - Can utilize effectively in professional work
  - Can solve complex problems and optimize
  - Example: Can set up, operate, and optimize Docker environments in production
- 6: Expert Proficiency
  - Can design advanced architectures
  - Can contribute to technical guidance and community
  - Example: Can contribute to Docker development or develop advanced Docker plugins

Legend:
- Required = Personal Recommendation / Opinion (🟣)
- Alternative = Alternative Option (🟢)
- Optional = Order not strict / learn anytime (⚪️)

## 01_Learn a Programming Language
| Technology/Tool      | Understanding | Recommendation | Reference Links                                 |
|----------------------|---------------|----------------|-------------------------------------------------|
| Python               | 4             | Required 🟣    | https://www.udemy.com/course/python-beginner ★- |
| Go                   | 1             | Required 🟣    |                                                 |
| Ruby                 | 1             | Alternative 🟢 |                                                 |
| Rust                 | 1             | Alternative 🟢 |                                                 |
| JavaScript / Node.js | 1             | Alternative 🟢 |                                                 |

## 02_Operating Systems
| Technology/Tool       | Understanding | Recommendation | Reference Links |
|-----------------------|---------------|----------------|-----------------|
| Linux (Ubuntu/Debian) | 2             | Required 🟣    |                 |
| RHEL / Derivatives    | 1             | Required 🟣    |                 |
| FreeBSD               | 0             | Required 🟣    |                 |
| SUSE Linux            | 1             | Alternative 🟢 |                 |
| Windows               | 4             | Alternative 🟢 |                 |
| OpenBSD               | 0             | Alternative 🟢 |                 |
| NetBSD                | 0             | Alternative 🟢 |                 |

## 03_Terminal Knowledge
| Technology/Tool        | Understanding | Recommendation | Reference Links |
|------------------------|---------------|----------------|-----------------|
| Bash                   | 2             | Required 🟣    |                 |
| Vim                    | 2             | Required 🟣    |                 |
| Nano                   | 2             | Required 🟣    |                 |
| Emacs                  | 2             | Required 🟣    |                 |
| Process Monitoring     | 1             | Required 🟣    |                 |
| Performance Monitoring | 1             | Required 🟣    |                 |
| Networking Tools       | 1             | Required 🟣    |                 |
| Text Manipulation      | 1             | Required 🟣    |                 |
| PowerShell             | 4             | Alternative 🟢 |                 |

## 04_Version Control Systems
| Technology/Tool | Understanding | Recommendation | Reference Links |
|-----------------|---------------|----------------|-----------------|
| Git             | 4             | Required 🟣    |                 |

## 05_VCS Hosting
| Technology/Tool | Understanding | Recommendation | Reference Links |
|-----------------|---------------|----------------|-----------------|
| GitHub          | 4             | Required 🟣    |                 |
| GitLab          | 3             | Alternative 🟢 |                 |
| Bitbucket       | 1             | Alternative 🟢 |                 |

## 06_Containers
| Technology/Tool | Understanding | Recommendation | Reference Links                           |
|-----------------|---------------|----------------|-------------------------------------------|
| Docker          | 3             | Required 🟣    | https://www.udemy.com/course/ok-docker ★5 |
| LXC             | 0             | Alternative 🟢 |                                           |

## 07_What is and how to setup X?
| Technology/Tool | Understanding | Recommendation | Reference Links |
|-----------------|---------------|----------------|-----------------|
| Forward Proxy   | 2             | Required 🟣    |                 |
| Reverse Proxy   | 2             | Required 🟣    |                 |
| Caching Server  | 2             | Required 🟣    |                 |
| Firewall        | 2             | Required 🟣    |                 |
| Load Balancer   | 2             | Required 🟣    |                 |
| Nginx           | 2             | Required 🟣    |                 |
| Caddy           | 0             | Alternative 🟢 |                 |
| Tomcat          | 1             | Alternative 🟢 |                 |
| Apache          | 1             | Alternative 🟢 |                 |
| IIS             | 0             | Alternative 🟢 |                 |

## 08_Networking & Protocols
| Technology/Tool        | Understanding | Recommendation | Reference Links |
|------------------------|---------------|----------------|-----------------|
| DNS                    | 2             | Required 🟣    |                 |
| HTTP                   | 2             | Required 🟣    |                 |
| HTTPS                  | 2             | Required 🟣    |                 |
| SSL/TLS                | 2             | Required 🟣    |                 |
| SSH                    | 2             | Required 🟣    |                 |
| FTP/SFTP               | 2             | Alternative 🟢 |                 |
| OSI Model              | 2             | Optional ⚪️    |                 |
| Email Protocols        |               |                |                 |
| - White / Grey Listing | 0             | Optional ⚪️    |                 |
| - SMTP                 | 2             | Optional ⚪️    |                 |
| - IMAP                 | 2             | Optional ⚪️    |                 |
| - POP3S                | 2             | Optional ⚪️    |                 |
| - DMARC                | 2             | Optional ⚪️    |                 |
| - SPF                  | 2             | Optional ⚪️    |                 |
| - Domain Keys          | 0             | Optional ⚪️    |                 |

## 09_Cloud Providers
| Technology/Tool | Understanding | Recommendation | Reference Links |
|-----------------|---------------|----------------|-----------------|
| AWS             | 5             | Required 🟣    |                 |
| Azure           | 1             | Required 🟣    |                 |
| Google Cloud    | 1             | Required 🟣    |                 |
| Digital Ocean   | 0             | Alternative 🟢 |                 |
| Alibaba Cloud   | 1             | Alternative 🟢 |                 |
| Hetzner         | 0             | Alternative 🟢 |                 |
| Contabo         | 0             | Alternative 🟢 |                 |
| Heroku          | 0             | Alternative 🟢 |                 |

## 10_Serverless
| Technology/Tool | Understanding | Recommendation | Reference Links |
|-----------------|---------------|----------------|-----------------|
| AWS Lambda      | 4             | Required 🟣    |                 |
| Cloudflare      | 1             | Required 🟣    |                 |
| Azure Functions | 1             | Alternative 🟢 |                 |
| Vercel          | 0             | Alternative 🟢 |                 |
| Netlify         | 0             | Alternative 🟢 |                 |
| GCP Functions   | 1             | Alternative 🟢 |                 |

## 11_Provisioning
| Technology/Tool | Understanding | Recommendation | Reference Links                                    |
|-----------------|---------------|----------------|----------------------------------------------------|
| Terraform       | 4             | Required 🟣    | https://www.udemy.com/course/iac-with-terraform ★4 |
| AWS CDK         | 2             | Alternative 🟢 |                                                    |
| CloudFormation  | 2             | Alternative 🟢 |                                                    |
| Pulumi          | 1             | Alternative 🟢 |                                                    |

## 12_Configuration Management
| Technology/Tool | Understanding | Recommendation | Reference Links                                                    |
|-----------------|---------------|----------------|--------------------------------------------------------------------|
| Ansible         | 3             | Required 🟣    | https://www.udemy.com/course/aws-ansibleinfrastructure-as-code/ ★5 |
| Chef            | 1             | Alternative 🟢 |                                                                    |
| Puppet          | 1             | Alternative 🟢 |                                                                    |

## 13_CI/CD Tools
| Technology/Tool | Understanding | Recommendation | Reference Links                                                   |
|-----------------|---------------|----------------|-------------------------------------------------------------------|
| GitHub Actions  | 3             | Required 🟣    | https://www.udemy.com/course/github-actions-the-complete-guide ★5 |
| Circle CI       | 0             | Required 🟣    |                                                                   |
| GitLab CI       | 2             | Required 🟣    |                                                                   |
| TeamCity        | 0             | Alternative 🟢 |                                                                   |
| Jenkins         | 1             | Alternative 🟢 |                                                                   |
| Travis CI       | 0             | Alternative 🟢 |                                                                   |
| Drone           | 0             | Alternative 🟢 |                                                                   |

## 14_Secret Management
| Technology/Tool      | Understanding | Recommendation | Reference Links |
|----------------------|---------------|----------------|-----------------|
| Vault                | 2             | Required 🟣    |                 |
| Sealed Secrets       | 0             | Alternative 🟢 |                 |
| SOPs                 | 0             | Alternative 🟢 |                 |
| Cloud Specific Tools | 0             | Alternative 🟢 |                 |

## 15_Infrastructure Monitoring
| Technology/Tool | Understanding | Recommendation | Reference Links                                      |
|-----------------|---------------|----------------|------------------------------------------------------|
| Prometheus      | 3             | Required 🟣    | https://www.udemy.com/course/awsgrafanaprometheus ★5 |
| Grafana         | 3             | Required 🟣    | https://www.udemy.com/course/awsgrafanaprometheus ★5 |
| Datadog         | 1             | Required 🟣    |                                                      |
| Zabbix          | 1             | Alternative 🟢 |                                                      |

## 16_Logs Management
| Technology/Tool | Understanding | Recommendation | Reference Links |
|-----------------|---------------|----------------|-----------------|
| Loki            | 1             | Required 🟣    |                 |
| Elastic Stack   | 0             | Required 🟣    |                 |
| Splunk          | 1             | Alternative 🟢 |                 |
| Papertrail      | 0             | Alternative 🟢 |                 |
| Graylog         | 0             | Alternative 🟢 |                 |

## 17_Container Orchestration
| Technology/Tool    | Understanding | Recommendation | Reference Links                                                                    |
|--------------------|---------------|----------------|------------------------------------------------------------------------------------|
| Kubernetes         | 3             | Required 🟣    | https://www.udemy.com/course/kubernetes-docker-container-devops-kanzen-nyumon ★4.5 |
| EKS (AWS)          | 2             | Alternative 🟢 |                                                                                    |
| GKE (Google Cloud) | 1             | Alternative 🟢 |                                                                                    |
| AKS (Azure)        | 1             | Alternative 🟢 |                                                                                    |
| AWS ECS / Fargate  | 2             | Alternative 🟢 |                                                                                    |
| Docker Swarm       | 1             | Alternative 🟢 |                                                                                    |

## 18_Application Monitoring
| Technology/Tool | Understanding | Recommendation | Reference Links                                      |
|-----------------|---------------|----------------|------------------------------------------------------|
| Datadog         | 1             | Alternative 🟢 |                                                      |
| Prometheus      | 2             | Alternative 🟢 | https://www.udemy.com/course/awsgrafanaprometheus ★5 |
| Jaeger          | 0             | Alternative 🟢 |                                                      |
| New Relic       | 0             | Alternative 🟢 |                                                      |
| OpenTelemetry   | 0             | Alternative 🟢 |                                                      |

## 19_Artifact Management
| Technology/Tool | Understanding | Recommendation | Reference Links |
|-----------------|---------------|----------------|-----------------|
| Artifactory     | 1             | Required 🟣    |                 |
| Nexus           | 0             | Alternative 🟢 |                 |
| Cloud Smith     | 0             | Alternative 🟢 |                 |

## 20_GitOps
| Technology/Tool | Understanding | Recommendation | Reference Links |
|-----------------|---------------|----------------|-----------------|
| ArgoCD          | 1             | Required 🟣    |                 |
| FluxCD          | 0             | Alternative 🟢 |                 |

## 21_Service Mesh
| Technology/Tool | Understanding | Recommendation | Reference Links |
|-----------------|---------------|----------------|-----------------|
| Istio           | 1             | Required 🟣    |                 |
| Consul          | 1             | Required 🟣    |                 |
| Linkerd         | 0             | Alternative 🟢 |                 |
| Envoy           | 1             | Alternative 🟢 |                 |

## 22_Cloud Design Patterns
| Technology/Tool           | Understanding | Recommendation | Reference Links |
|---------------------------|---------------|----------------|-----------------|
| Availability              |               | Required 🟣    |                 |
| Data Management           |               | Required 🟣    |                 |
| Design and Implementation |               | Required 🟣    |                 |
| Management and Monitoring |               | Required 🟣    |                 |
