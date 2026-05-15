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

---

### 4. Install the Pinecone Python SDK

    pip install "pinecone[grpc]" sentence-transformers

The SDK with gRPC extras offers better performance for data operations

#### Connecting to Pinecone Local

    #!/usr/bin/env python3
    """
    Script de conexão com Pinecone Local (emulador local)
    Autor: Ajustado para resolver AttributeError: '_api_version'
    """

    from pinecone.grpc import PineconeGRPC as Pinecone
    from pinecone import ServerlessSpec
    import numpy as np
    from sentence_transformers import SentenceTransformer
    import json
    import time
    
    # Initializes the client pointing to Pinecone Local
    # The API key can be any string - Pinecone Local ignores authentication
    pc = Pinecone(
        api_key="pclocal",
        host="http://localhost:5081"
    )

    print("✅ Pinecone Local Client initialized successfully!")

    # Optional: Attempts to obtain the API version, if available, without causing an error.
    try:
        # Checks if the attribute exists (it doesn't exist on the local client).
        if hasattr(pc, '_api_version'):
            print(f"API Version: {pc._api_version}")
        else:
            print("ℹ️  API version attribute not available in local mode")
    except Exception as e:
        print(f"⚠️ Could not retrieve API version: {e}")

    # Quick test: list existing indexes (if any)
    try:
        indexes = pc.list_indexes()
        print(f"📌 Existing indexes: {indexes}")
    except Exception as e:
        print(f"⚠️ Could not list indexes: {e}")
        print("   (Make sure Pinecone Local server is running on http://localhost:5081)")

    # You can continue with the rest of your code here...
    # Example: creating an index, inserting vectors, etc.

#### Run a local connection test 

    python3 Pinecone_Local_connection.py 

```
✅ Pinecone Local Client initialized successfully!
ℹ️  API version attribute not available in local mode
📌 Existing indexes: IndexList([])
```

*Note: When you initialize Pinecone Local without specifying indexes in the Docker configuration, it acts as a full database emulator, allowing for the dynamic creation and management of indexes via API.*

#### Index Management

*Creating an Index for Dense Vectors (Semantic Search)*

    #!/usr/bin/env python3
    from pinecone.grpc import PineconeGRPC as Pinecone
    from pinecone import ServerlessSpec
    import time

    # 🔁 Configure the host with the same port that you mapped in the container.
    pc = Pinecone(
        api_key="pclocal",
        host="http://localhost:5081"        # Adjust the door to fit your container.
    )

    INDEX_DENSE = "dpe-dense-index"

    # Check if the index already exists.
    if not pc.has_index(INDEX_DENSE):
        pc.create_index(
            name=INDEX_DENSE,
            vector_type="dense",              # ← Essential for dense indexes
            dimension=384,                    # Dimensions of the all-MiniLM-L6-v2 model
            metric="cosine",
            spec=ServerlessSpec(cloud="aws", region="us-east-1")
        )
        print(f"✅ Índice denso '{INDEX_DENSE}' successfully created!")
    else:
        print(f"ℹ️ Índice denso '{INDEX_DENSE}' already exists.")

    # Please wait a few seconds for the index creation to complete.
    time.sleep(2)

    # List the indexes to confirm.
    print("📌 Existing indices:", pc.list_indexes())

    python3 Pinecone_Local_Create_Index.py

```
✅ Dense index 'dpe-dense-index' created successfully!
📌 Existing indexes: IndexList([<name='dpe-dense-index', dim=384, ready=True>])
```

#### List the indexes

    from pinecone.grpc import PineconeGRPC as Pinecone; 

    pc = Pinecone(api_key='pclocal', host='http://localhost:5081'); 
    print(pc.list_indexes())

*Execute list index*

    python3 Pinecone_Local_List_Index.py    

```
IndexList([<name='dpe-dense-index', dim=384, ready=True>])
```

*The list_indexes() method returns all the indexes in the project, and describe_index() provides specific details for each one.*

#### Creating an Index with Document Schema (for Full-Text Search)

*For full-text search with BM25, we need to create an index with a document schema that defines the ranking fields:*




