## Project: DPE (Document Processing Engine)

This notebook demonstrates how to use Pinecone Local, an in-memory emulator of Pinecone available via Docker, 
to develop vector search and document processing applications directly on your server, without the need for a cloud connection or associated costs.

---

Summary

Why use Pinecone Local?

1. Prerequisites and Environment Setup
2. Connecting to Pinecone Local
3. Index Management
4. Data Modeling - The Document
5. Data Ingestion (Upsert)
6. Semantic Search (Dense Vectors)
7. Lexical Search with BM25 (Full-Text Search)
8. Hybrid Search
9. Metadata Filtering
10. Result Reranking
11. Multitenancy with Namespaces
12. Data Management (Update, Deletion, Search by ID)
13. Best Practices and Optimizations
14. Limitations of Pinecone Local
15. Final Considerations

---

## Why use Pinecone Local?

Pinecone Local is a Pinecone Database emulator available as a Docker image. It allows you to:

* Develop applications locally without connecting to your Pinecone account
* Run integration tests without incurring usage or storage costs
* Use any supported SDK to make API requests
* Work without an internet connection

It's the ideal tool for prototyping, development, and local testing before migrating to production.

---

## Prerequisites and Environment Setup

### 1. Install Docker

#### Update the system

    sudo dnf update -y

#### Remove packages that conflict with Docker (Podman, buildah, runc)

    sudo dnf remove -y podman buildah runc

#### Disable the container-tools module to avoid future conflicts

    sudo dnf module disable container-tools -y

#### Add the official Docker CE repository (compatible with Oracle Linux 10 as it is derived from RHEL/CentOS)

    sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

#### Install the Docker Engine and the Docker Compose plugin

    sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

#### Start the Docker service and configure it to start automatically with the System

    sudo systemctl enable --now docker

#### Check if Docker is running

    sudo systemctl status docker

Expected output: active (running).

#### 👤 (Optional) Add your user to the docker group

To use Docker without needing sudo, run:

    sudo usermod -aG docker $USER
    newgrp docker

#### Test the installation with a hello-world container

    sudo docker run hello-world

#### Install docker-compose

    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# Apply execution permission

    sudo chmod +x /usr/local/bin/docker-compose

# Test

    docker-compose --version

**Make sure Docker is installed and running on your machine.**

---

### 2. Configure Pinecone Local with Docker Compose

Create a **docker-compose.yaml** file to start the emulator in "database emulator" mode (recommended for more complete development):
        
    version: '3.8'

    services:
      pinecone-local:
        image: ghcr.io/pinecone-io/pinecone-local:latest
        container_name: pinecone-local
        environment:
          PORT: 5081
          PINECONE_HOST: localhost
        ports:
          - "5081-6000:5081-6000"
        platform: linux/amd64

---

### 3. Start Pinecone Local

    docker-compose up -d

```
WARN[0000] /root/DPE/docker-compose.yaml: the attribute `version` is obsolete, it will be ignored, please remove it to avoid potential confusion 
[+] up 4/4
 ✔ Image ghcr.io/pinecone-io/pinecone-local:latest Pulled                                                                                                                                                                                2.6s
 ✔ Network dpe_default                             Created                                                                                                                                                                               0.0s
 ✔ Container pinecone-local                        Started                                                                                                                                                                              10.8s
```

**check if container is running** 

    docker ps

```
CONTAINER ID   IMAGE                                       COMMAND      CREATED              STATUS              PORTS                                                             NAMES
2e64757814ba   ghcr.io/pinecone-io/pinecone-local:latest   "/control"   About a minute ago   Up About a minute   0.0.0.0:5081-6000->5081-6000/tcp, [::]:5081-6000->5081-6000/tcp   pinecone-local
```
