# Simple CI/CD Project

This project demonstrates a complete CI/CD pipeline using GitHub Actions to deploy a containerized web application to AWS ECS Fargate. The application consists of a React frontend and a Spring Boot backend API, both containerized using Docker.

## Architecture

The system architecture consists of:

- **Frontend**: React application (TypeScript)
- **Backend**: Spring Boot API (Java)
- **CI/CD Pipeline**: GitHub Actions workflow
- **Deployment Target**: AWS ECS Fargate
- **Container Registry**: Amazon ECR

## Project Structure

```
.
├── .aws/                         # AWS configuration files
│   └── task-definition.json      # ECS task definition
├── .github/
│   └── workflows/
│       └── main.yml              # GitHub Actions workflow
├── api/                          # Spring Boot backend
│   ├── src/                      # Java source code
│   └── Dockerfile                # API container definition
├── web/                          # React frontend
│   ├── src/                      # TypeScript source code
│   └── Dockerfile                # Web container definition
├── main_ecr.tf                   # ECR repository definitions
├── main_ecs.tf                   # ECS cluster and service definitions
├── main_iam.tf                   # IAM roles and policies
├── main_vpc.tf                   # VPC and networking
├── main_sg.tf                    # Security groups
├── providers.tf                  # AWS provider configuration
├── outputs.tf                    # Terraform output values
└── docker-compose.yml            # Local development environment
```

## Key Components

### Frontend (React)

- Built with React and TypeScript
- Communicates with the backend API
- Containerized with nginx for production
- Environment variables for API endpoint configuration

### Backend (Spring Boot)

- Java-based REST API with Spring Boot
- Implements CORS configuration for cross-domain requests
- Simple "Hello World" endpoint for demonstration
- Includes health check endpoint for container orchestration

### CI/CD Pipeline

The CI/CD pipeline is implemented using GitHub Actions and consists of three jobs:

1. **Web Container - Test and Build**
   - Builds the React application
   - Runs tests
   - Builds a Docker image
   - Pushes the image to Amazon ECR

2. **API Container - Test and Build**
   - Builds the Spring Boot application
   - Runs tests
   - Builds a Docker image
   - Pushes the image to Amazon ECR

3. **Deploy**
   - Updates the ECS task definition with new image IDs
   - Deploys the application to AWS ECS Fargate
   - Waits for service stability

### AWS Configuration

The application is deployed to AWS ECS Fargate with the following configuration:

- Two containers in a single task definition (web and api)
- Network mode: awsvpc
- Memory: 1GB
- CPU: 0.25 vCPU
- Container dependencies to ensure the API starts before the web container
- Health checks for the API container
- Task execution role for pulling ECR images

## Development Environment

### Prerequisites

- Docker and Docker Compose
- Java 17
- Node.js 18
- VS Code (optional, but configured for development containers)

### Local Development

1. Clone the repository
2. Start the development environment:

```bash
docker-compose up
```

This will start:
- API server at http://localhost:8080
- Web server at http://localhost:3000

### VS Code Development Containers

The project includes configuration for VS Code Development Containers:

- `api/.devcontainer/devcontainer.json` - Configuration for API development
- `web/.devcontainer/devcontainer.json` - Configuration for Web development

## Deployment

### Required AWS Resources

- ECS Cluster named `simple-cicd-cluster`
- ECS Service named `simple-cicd-service`
- ECR repositories for both containers
- IAM roles for task execution
- VPC with public subnets and security groups

### GitHub Secrets

The following secrets need to be configured in GitHub:

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_ECR_WEB_SERVER_REPOSITORY`
- `AWS_ECR_API_SERVER_REPOSITORY`

### Deployment Process

1. Push changes to the `main` branch
2. GitHub Actions workflow will be triggered
3. Containers are built, tested, and pushed to ECR
4. ECS task definition is updated with new image IDs
5. New deployment is initiated
6. Service stability is verified

## Testing

### API Tests

The API includes JUnit tests that can be run with:

```bash
cd api
./gradlew test
```

### Web Tests

The web application includes React Testing Library tests that can be run with:

```bash
cd web
npm test
```

## Infrastructure as Code

The project includes Terraform configurations to provision the required AWS resources:

1. VPC with public subnets
2. Security groups
3. ECS cluster and service
4. ECR repositories
5. IAM roles and policies

To apply the Terraform configuration:

```bash
terraform init
terraform apply
```

## Container Architecture

The application uses a multi-container architecture:

1. **Web Container**:
   - NGINX serving the React application
   - Configured to proxy API requests to the API container
   - Production-optimized build

2. **API Container**:
   - Spring Boot application
   - Exposes REST endpoints
   - Health check for container orchestration
   - Configured with different environment profiles

## Environment Configuration

- Development environment uses Docker Compose
- Production environment uses AWS ECS Fargate
- API configuration managed through Spring profiles
- Web configuration managed through environment variables
