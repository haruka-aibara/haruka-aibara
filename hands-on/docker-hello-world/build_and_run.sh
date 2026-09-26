#!/bin/bash

# Stop execution if any command fails
set -e

# Remove old image if it exists
sudo docker rmi docker-hello-world || true

# Build the new image
sudo docker build -t docker-hello-world .

# Run the container
sudo docker run -p 8080:8080 docker-hello-world
