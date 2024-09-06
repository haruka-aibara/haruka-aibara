# Docker Hello World

This is a simple Docker project that demonstrates how to containerize a Python Flask application.

## Build the Docker image

```
docker build -t docker-hello-world .
```

## Run the container

```
docker run -p 8080:8080 docker-hello-world
```

Visit `http://localhost:8080` in your browser to see the "Hello, Docker World!" message.
