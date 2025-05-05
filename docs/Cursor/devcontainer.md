# Development Environment Construction 

***

## Install WSL2

### Reference Articles

 - [WSL を使用して Windows に Linux をインストールする方法](https://learn.microsoft.com/ja-jp/windows/wsl/install)
 - [WSL 開発環境を設定する](https://learn.microsoft.com/ja-jp/windows/wsl/setup/environment#set-up-your-linux-username-and-password)


```bash
wsl --install
```

```bash
wsl --install -d Ubuntu
```

```bash
sudo apt update && sudo apt upgrade
```

***

## Install Cursor

https://www.cursor.com/ja

### Install Cursor Extension

- Dev Container exteions

## Install Docker (in WSL2 Ubuntu)

### Reference Articles

 - https://qiita.com/haveAbook/items/0d0ae20a19214f65e7cd
 - https://docs.docker.com/engine/install/ubuntu/


### Uninstall old versions

```bash
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done
```


### Install using the apt repository

```bash
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
```

### Install the latest version of docker packages

```bash
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

### Test Docker
```bash
sudo docker run hello-world
```

then remove unnecessary resources

```bash
sudo docker container prune
sudo docker image rm hello-world
```

### Add user to docker Groups
```bash
sudo usermod -aG docker $USER
```

***

### WSL2 Setup Prerequisites

Before using this DevContainer template, ensure:

1. WSL2 is installed and configured with Ubuntu
2. Your AWS credentials are set up in your WSL2 Ubuntu home directory:
   ```
   ~/.aws/credentials
   ~/.aws/config
   ```
3. Your Git configuration is set up in your WSL2 Ubuntu home directory:
   ```
   ~/.gitconfig
   ```

These files will be mounted into the container (read-only) to enable authentication with AWS services and maintain consistent Git commit identity.

### Clone repository in container volume

change user settings

"dev.containers.executeInWSL": true

Clone respository in container volume

use this container image

`ghcr.io/haruka-aibara/devcontainer-templates/haruka-aibara-dev-env:latest`
