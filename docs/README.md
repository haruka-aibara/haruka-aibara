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

## Run .sh

```
chmod +x build_and_run.sh
```

then 

```
./build_and_run.sh
```

## After completing these steps..
you should see a simple web page displaying:
"Hello, Docker World!"

like this ->

![image](https://github.com/user-attachments/assets/5a872f9d-9940-439d-a6f6-b7f58b4e4e8b)
