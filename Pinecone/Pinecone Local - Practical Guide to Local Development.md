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

**Make sure Docker is installed and running on your machine.**

---



