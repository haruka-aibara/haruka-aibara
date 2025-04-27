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
└── docker-compose.yml            # Local development environment
```

## Key Components

### Frontend (React)

- Built with React and TypeScript
- Communicates with the backend API 
- Containerized with nginx for production

### Backend (Spring Boot)

- Java-based REST API with Spring Boot
- Implements CORS configuration for cross-domain requests
- Simple "Hello World" endpoint for demonstration
- Includes health check endpoint

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

### AWS Configuration

The application is deployed to AWS ECS Fargate with the following configuration:

- Two containers in a single task definition
- Network mode: awsvpc
- Memory: 1GB
- CPU: 0.25 vCPU
- Container dependencies to ensure proper startup sequence
- Health checks for the API container

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
4. ECS task definition is updated
5. New deployment is initiated

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
