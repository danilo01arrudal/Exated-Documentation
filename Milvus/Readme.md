### 📖 Metodologia e Convenções

Para aproveitar ao máximo este guia, é importante entender sua estrutura:
*   **Navegação**: Ao final de cada módulo, um link de "Próximo Módulo" permite que você continue seu estudo de forma linear.
*   **Componentes**: Cada módulo é dividido em **tópicos**, cada um seguido por **tarefas práticas**.
*   **Convenções nos Exemplos de Código**:
    *   Linhas de código que você deve executar no terminal são prefixadas com `$`.
    *   Linhas de código que são a saída esperada de um comando são prefixadas com `>`.
    *   Blocos de código Python (`import ...`) devem ser executados em um interpretador Python ou em um arquivo `.py`.
    *   Comentários `# Explicação` são usados para descrever trechos de código.
    *   Além disso, para o seu ambiente **on-premise**, lembre-se de substituir endereços IP, portas, senhas e caminhos de exemplo pelos valores da sua própria infraestrutura.

### 🗂️ Estrutura do Curso

Este curso está dividido em 9 módulos principais:

1.  **Módulo 1: Fundamentos e Arquitetura do Milvus** - Introdução à arquitetura, componentes e conceitos fundamentais.
2.  **Módulo 2: Planejamento e Instalação On-Premise** - Instalação Standalone e Cluster em Kubernetes com Milvus Operator.
3.  **Módulo 3: Administração e Configuração do Sistema** - Configuração de dependências, autenticação e RBAC.
4.  **Módulo 4: Modelagem de Dados (Schema Design)** - Design de schema com campos vetoriais e escalares.
5.  **Módulo 5: Índices e Otimização de Desempenho** - Tipos de índices, parâmetros e estratégias de otimização.
6.  **Módulo 6: Operações CRUD com PyMilvus** - Inserção, busca, consulta e deleção de dados.
7.  **Módulo 7: Operações Avançadas e Manutenção** - Partições, consistência, backup e restauração.
8.  **Módulo 8: Monitoramento e Observabilidade** - Métricas com Prometheus e dashboards com Grafana.
9.  **Módulo 9: Projeto Final - Sistema RAG** - Projeto prático de um sistema de busca com RAG.

---

### 📚 Módulo 1: Fundamentos e Arquitetura do Milvus

#### 🎯 Objetivos
*   Compreender o propósito e as principais funcionalidades do Milvus.
*   Identificar os componentes da arquitetura de quatro camadas do Milvus e suas funções.
*   Diferenciar os modos de operação Standalone e Cluster.

#### 🔍 Tópicos e Tarefas Práticas

**1.1 O que é Milvus?**
Milvus é um banco de dados vetorial open-source, cloud-native, projetado para buscas de similaridade em conjuntos massivos de dados não estruturados, como texto, imagens e áudio. Ele constrói e gerencia índices vetoriais para consultas eficientes, sendo uma peça fundamental em aplicações de Inteligência Artificial (IA).

*   **Tarefa Prática 1.1**: Acesse a documentação oficial em https://milvus.io/docs para se familiarizar com os guias de instalação, "quick start", "bootcamp" e as últimas atualizações, como as da versão 3.0.x.

**1.2 Arquitetura de Quatro Camadas**
O Milvus adota uma arquitetura de quatro camadas que separa o plano de dados (processamento) do plano de controle (orquestração), garantindo alta escalabilidade e resiliência.

*   **Camada de Acesso**: Front-end stateless (Proxy) responsável por validar requisições, rotear e agregar resultados antes de retorná-los ao cliente. É o ponto de entrada único para as aplicações.
*   **Camada de Coordenadores (Coordinators)**: O "cérebro" do sistema, gerencia os nós de trabalho, a topologia do cluster e assegura a consistência.
    *   **Root Coordinator (Root Coord)**: Gerencia metadados de alto nível (DDL/DCL).
    *   **Query Coordinator (Query Coord)**: Gerencia os nós de consulta e balanceamento de carga.
    *   **Data Coordinator (Data Coord)**: Gerencia nós de dados, compactação e criação de índices.
*   **Camada de Trabalho (Workers)**: Os nós stateless que executam as tarefas.
    *   **Query Node**: Executa consultas em dados históricos (já persistidos).
    *   **Data Node**: Processa dados em crescimento (streaming) e executa operações de escrita em lote.
    *   **Index Node**: Constrói índices.
*   **Camada de Armazenamento (Storage)**: Responsável pela persistência dos dados.
    *   **Meta Store**: Armazena metadados (schemas, checkpoints) em etcd.
    *   **Log Broker**: Gerencia logs de Write-Ahead Logging (WAL).
    *   **Object Storage**: Armazena logs, índices e resultados intermediários (MinIO ou S3).

*   **Tarefa Prática 1.2**: Compare e contraste as funções dos componentes **QueryCoord, QueryNode, DataNode e IndexNode** em um cluster Milvus. Identifique qual deles é responsável por executar a consulta `client.search(...)` e qual executa a operação de construção de índice `client.create_index(...)`.

**1.3 Modos de Operação: Standalone vs. Cluster**
O Milvus pode ser executado em dois modos principais para atender a diferentes níveis de escala e requisitos de produção.

| Modo | Descrição | Casos de Uso | Características de Alta Disponibilidade |
| :--- | :--- | :--- | :--- |
| **Standalone** | Um único binário que executa todos os componentes (Proxy, Coord, Worker) e depende de serviços externos (etcd, MinIO). | Desenvolvimento, testes e cargas de trabalho pequenas. | Serviços externos podem ser configurados em HA, mas o nó Milvus é um ponto único de falha (SPOF). |
| **Cluster** | Componentes são implantados como microsserviços separados, geralmente em Kubernetes, permitindo escalabilidade horizontal e alta disponibilidade. | Produção, ambientes com alta demanda e escalabilidade. | Tolerante a falhas; perda de um nó não afeta a disponibilidade geral. |

*   **Tarefa Prática 1.3**: Analise seu cenário e responda: Se você está construindo um MVP de um sistema de recomendação para 10 mil usuários, o modo **Standalone** seria uma escolha viável? Justifique.

---
### 🔧 Módulo 2: Planejamento e Instalação On-Premise

#### 🎯 Objetivos
*   Instalar o Milvus no modo Standalone utilizando Docker Compose.
*   Instalar o Milvus no modo Cluster em Kubernetes utilizando o Milvus Operator.
*   Conectar e gerenciar o Milvus usando o cliente Python.

#### 🔍 Tópicos e Tarefas Práticas

**2.1 Planejamento de Infraestrutura On-Premise**
Antes de instalar o Milvus, faça o levantamento dos recursos.

| Modo | CPU (Mínimo/Recomendado) | Memória (Mínimo/Recomendado) | Armazenamento | Dependências |
| :--- | :--- | :--- | :--- | :--- |
| **Standalone** | 2/4 vCPUs | 4/8 GB | Local | Docker, Docker Compose |
| **Cluster (K8s)** | 4/8+ vCPUs | 8/16+ GB | NFS, Ceph ou similar | Kubernetes (v1.20+), Helm, kubectl, Milvus Operator |

**2.2 Instalação Standalone com Docker Compose**
A instalação Standalone é ideal para testes e desenvolvimento.
1.  **Pré-requisitos**: Docker e Docker Compose instalados.
2.  **Tarefa Prática 2.2**: Siga os passos abaixo para iniciar sua primeira instância:
    *   Baixe o arquivo de configuração Docker Compose para a versão Milvus 2.4.4:
        ```bash
        $ wget https://github.com/milvus-io/milvus/releases/download/v2.4.4/milvus-standalone-docker-compose.yml -O docker-compose.yml
        ```
    *   Inicie o serviço em segundo plano:
        ```bash
        $ docker-compose up -d
        ```
    *   Verifique se todos os contêineres (`milvus-standalone`, `etcd`, `minio`) estão em execução:
        ```bash
        $ docker-compose ps
        # Aguarde ~30s para todos os serviços iniciarem completamente.
        ```
    *   Instale o PyMilvus, nosso SDK principal para interagir com o banco:
        ```bash
        $ pip install pymilvus>=2.4.0
        ```
    *   Por fim, teste a conexão com o Milvus utilizando um script Python:
        ```python
        from pymilvus import connections
        # Tenta conectar ao Milvus no host e porta padrão
        connections.connect(alias="default", host="localhost", port="19530")
        print("✅ Conexão com Milvus bem-sucedida!")
        ```

**2.3 Instalação em Cluster com Kubernetes e Milvus Operator**
Para ambientes de produção, recomenda-se a instalação em cluster.
*   **Pré-requisitos**: Cluster Kubernetes (v1.20+), `kubectl` e `helm` configurados.
*   **Tarefa Prática 2.3 (Avançada)**: Execute os comandos abaixo para implantar o Milvus Operator.
    *   Instale o CRD (Custom Resource Definition) do Milvus Operator:
        ```bash
        $ kubectl apply -f https://raw.githubusercontent.com/milvus-io/milvus-operator/main/deploy/manifests/operator/config/crd/bases/milvus.io_milvusclusters.yaml
        ```
    *   Instale o Milvus Operator com Helm:
        ```bash
        $ helm repo add milvus-operator https://milvus-operator.github.io/helm-repo
        $ helm install milvus-operator milvus-operator/milvus-operator
        ```
    *   Crie um arquivo `milvus-cluster.yaml` e aplique-o para implantar um cluster:
        ```bash
        $ kubectl apply -f milvus-cluster.yaml
        $ kubectl get pods | grep milvus
        ```

**2.4 Primeiros Passos com PyMilvus**
Para aprender a usar o PyMilvus de forma abrangente, consulte a [documentação oficial da API PyMilvus](https://milvus.io/api-reference/pymilvus/v2.5.x/About.md).

*   **Tarefa Prática 2.4**: Conecte-se à sua instância Milvus utilizando o cliente mais moderno, o `MilvusClient`.
    ```python
    # Importe a classe MilvusClient
    from pymilvus import MilvusClient

    # Crie uma conexão com o client (para modo standalone, autenticação desabilitada)
    # O URI padrão para uma instância local é "http://localhost:19530"
    client = MilvusClient(uri="http://localhost:19530")
    print("✅ Cliente Milvus criado com sucesso!")
    ```

---
### ⚙️ Módulo 3: Administração e Configuração do Sistema

#### 🎯 Objetivos
*   Configurar dependências externas (etcd, MinIO/S3, Pulsar/Kafka) no `milvus.yaml`.
*   Habilitar autenticação para acessar o Milvus.
*   Implementar RBAC para controle de acesso granular.

#### 🔍 Tópicos e Tarefas Práticas

**3.1 Arquivo de Configuração `milvus.yaml`**
O arquivo `milvus.yaml` é o centro de configuração do Milvus. Ele possui mais de 500 parâmetros, mas você pode se concentrar nos mais importantes.

*   **Tarefa Prática 3.1. Configuração de Dependências**: Edite o arquivo `milvus.yaml` para configurar conexões com serviços externos.
    *   **etcd (Meta Store)**: Configure os endpoints e o prefixo raiz para isolamento de metadados.
        ```yaml
        etcd:
          endpoints:
            - 10.0.0.1:2379
            - 10.0.0.2:2379
          rootPath: milvus-prod
        ```
    *   **MinIO (Object Storage)**: Defina o bucket e o prefixo para armazenamento de logs e índices.
        ```yaml
        minio:
          address: 10.0.0.3
          port: 9000
          bucketName: "milvus-bucket"
          rootPath: "milvus/data"
        ```
    *   **Pulsar (Log Broker)**: Especifique o serviço de mensageria.
        ```yaml
        pulsar:
          address: http://pulsar-cluster.default.svc.cluster.local
          port: 8080
        ```

**3.2 Habilitando Autenticação**
Por padrão, o Milvus é executado com autenticação desabilitada, o que significa que qualquer um pode acessá-lo. É uma prática de segurança essencial habilitá-la.

*   **Tarefa Prática 3.2**: Siga os passos para ativar a autenticação.
    *   **Habilitar**: Defina `common.security.authorizationEnabled: true` no `milvus.yaml`.
    *   **Reiniciar**: `$ docker-compose restart` ou recrie os pods no Kubernetes.
    *   **Criar um novo usuário**: Conecte-se com a conta `root` (senha `Milvus`) e execute:
        ```python
        from pymilvus import MilvusClient

        client = MilvusClient(uri="http://localhost:19530", token="root:Milvus")
        client.create_user(user_name="app_user", password="senha_segura") # 👈 Nunca use senhas fracas em produção!
        print(f"✅ Usuário 'app_user' criado com sucesso.")
        ```

**3.3 Controle de Acesso Baseado em Funções (RBAC)**
O RBAC permite um controle granular sobre quem pode fazer o quê. As permissões são concedidas a "funções" (roles), e estas são atribuídas a "usuários".

*   **Tarefa Prática 3.3**: Implemente uma política de segurança usando o código abaixo.
    *   **Crie uma função**: `client.create_role(role_name="app_role")`
    *   **Conceda privilégios**: Dê à função permissão para buscar em qualquer collection.
        ```python
        client.grant_privilege(
            role_name="app_role",
            object_type="Collection",   # Tipo de recurso
            object_name="*",            # "*" para todas as coleções
            privilege="Search"          # Ação permitida
        )
        ```
    *   **Atribua a função ao usuário**: Associe a função `app_role` ao usuário `app_user`.
        ```python
        client.grant_role(user_name="app_user", role_name="app_role")
        ```

---
### 🗂️ Módulo 4: Modelagem de Dados (Schema Design)

#### 🎯 Objetivos
*   Projetar um schema eficiente para dados não estruturados.
*   Criar Collections com campos escalares e vetoriais.
*   Compreender e utilizar diferentes tipos de vetores (densos, esparsos).

#### 🔍 Tópicos e Tarefas Práticas

**4.1 Introdução ao Schema no Milvus**
Uma **Collection** no Milvus equivale a uma tabela em um banco de dados relacional. Ela é composta por colunas chamadas de **campos (fields)**, que podem ser de tipos **escalares** (strings, inteiros) ou **vetoriais**.

*   **Tarefa Prática 4.1**: Analise qual campo é **vetorial** e qual é **escalar** no exemplo de um sistema de busca de produtos: `id`, `embedding_imagem` (vetor de 512 floats), `preco`, `categoria`, `descricao` e `marca`. (`embedding_imagem` é o vetorial; os demais, escalares).

**4.2 Criando uma Collection**
O `MilvusClient` oferece duas formas de criar collections. Uma delas é a mais simplificada, a `create_collection`, que é ótima para testes rápidos.

*   **Tarefa Prática 4.2. Criação Simplificada**: Crie uma collection para armazenar embeddings de produtos com três linhas.
    ```python
    from pymilvus import MilvusClient

    client = MilvusClient(uri="http://localhost:19530")
    collection_name = "produtos_vectors"

    if client.has_collection(collection_name):
        client.drop_collection(collection_name)

    # Criação direta, o Milvus cria um campo 'id' e 'vector' para você.
    client.create_collection(
        collection_name=collection_name,
        dimension=768,        # Dimensão dos seus vetores
        metric_type="COSINE"  # Métrica de similaridade
    )
    print(f"✅ Collection '{collection_name}' criada com sucesso!")
    ```

**4.3 Campos Vetoriais Avançados**
Para maior controle, definimos um `CollectionSchema`, especialmente útil para projetos complexos com múltiplos vetores (mix search) ou tipos de dados específicos.

*   **Tarefa Prática 4.3. Criação Avançada**: Vamos criar uma collection mais realista, com múltiplos campos escalares e vetoriais.
    ```python
    from pymilvus import DataType, FieldSchema, CollectionSchema, MilvusClient

    client = MilvusClient(uri="http://localhost:19530")
    collection_name = "produtos_detalhado"

    if client.has_collection(collection_name):
        client.drop_collection(collection_name)

    # Define os campos da collection
    fields = [
        FieldSchema(name="product_id", dtype=DataType.INT64, is_primary=True, auto_id=False),
        FieldSchema(name="product_name", dtype=DataType.VARCHAR, max_length=255),
        FieldSchema(name="price", dtype=DataType.FLOAT),
        FieldSchema(name="category", dtype=DataType.VARCHAR, max_length=100),
        FieldSchema(name="embedding_text", dtype=DataType.FLOAT_VECTOR, dim=384),
        FieldSchema(name="embedding_image", dtype=DataType.FLOAT_VECTOR, dim=512)
    ]

    schema = CollectionSchema(fields, description="Schema avançado para catálogo de produtos")
    client.create_collection(collection_name=collection_name, schema=schema)
    print(f"✅ Collection '{collection_name}' criada com schema detalhado!")
    ```

**4.4 Tipos de Vetores: Denso vs. Sparse vs. Binário**
*   **Vetores Densos (`FLOAT_VECTOR`)**: Representam semântica densa e são usados para similaridade de significado. Uma imagem é convertida em um vetor denso de 512 floats.
*   **Vetores Esparsos (`SPARSE_FLOAT_VECTOR`)**: Representam termos em alta dimensão com muitos zeros, ideais para busca textual híbrida (BM25).
*   **Vetores Binários (`BINARY_VECTOR`)**: Compactos e rápidos para dados já binários.

*   **Tarefa Prática 4.4**: Dado o cenário de um mecanismo de busca de documentos jurídicos que deve encontrar documentos por semântica e também por palavras exatas (ex: "cláusula 5"), que tipos de vetores seriam mais adequados para implementar uma **busca híbrida**? (A melhor estratégia seria usar **vetores densos** para a busca semântica e **vetores esparsos** para a busca por palavras-chave exatas).

---
### 🚀 Módulo 5: Índices e Otimização de Desempenho

#### 🎯 Objetivos
*   Selecionar o tipo de índice (FLAT, IVF_FLAT, HNSW, etc.) adequado para diferentes cenários.
*   Criar e gerenciar índices em Collections.
*   Ajustar parâmetros de índice (nlist, M, efConstruction) para balancear velocidade e precisão.

#### 🔍 Tópicos e Tarefas Práticas

**5.1 Por que os Índices São Cruciais?**
Um índice no Milvus é uma estrutura de dados que reorganiza os vetores originais. Sem um índice, uma busca é uma **busca por força bruta** (FLAT), que é precisa mas extremamente lenta em conjuntos grandes. **Todo campo de vetor deve ter um índice criado antes de poder ser pesquisado.**

*   **Tarefa Prática 5.1**: Dado uma coleção com 1 milhão de vetores de 768 dimensões. Em termos de **recall** (precisão) e **velocidade**, como você compara o uso de um índice **IVF_FLAT** com a busca **FLAT** (que é, essencialmente, a ausência de um índice avançado)? (FLAT oferece 100% de recall, mas é mais lento. IVF_FLAT acelera a busca, mas pode sacrificar uma pequena fração do recall para ganhar muita velocidade.)

**5.2 Principais Tipos de Índices**

| Índice | Força/Quando Usar | Trade-offs | Parâmetros-Chave |
| :--- | :--- | :--- | :--- |
| **FLAT** | 100% de recall, conjuntos muito pequenos (<10k vetores) | Muito lento em larga escala. | Nenhum |
| **IVF_FLAT** | Boa relação desempenho/precisão. Um bom ponto de partida. | Precisão inferior à HNSW, mas mais rápida para construir. | `nlist` (número de clusters) |
| **IVF_SQ8** | Reduz o uso de memória em ~70-80% vs. IVF_FLAT. | Perda de precisão. | `nlist`, `nprobe` (busca) |
| **IVF_PQ** | Reduz drasticamente o uso de memória e acelera a busca. | Maior perda de precisão. | `nlist`, `m` (subvetores), `nprobe` (busca) |
| **HNSW** | **Alta precisão e alta velocidade**. Melhor para desempenho. | Alto consumo de memória, construção mais lenta. | `M` (máx. conexões), `efConstruction` (qualidade) |
| **DISKANN** | Milhões/bilhões de vetores. Índice em disco, não em RAM. | Latência maior que HNSW. | Nenhum |

**5.3 Criando e Gerenciando Índices**
A criação de índices é feita de forma assíncrona, permitindo que outras operações continuem enquanto o índice é construído.

*   **Tarefa Prática 5.3**: Crie um índice **IVF_FLAT** na sua collection de produtos.
    ```python
    from pymilvus import MilvusClient

    client = MilvusClient(uri="http://localhost:19530")
    collection_name = "produtos_detalhado"
    index_params = client.prepare_index_params()  # Usa o helper para criar params
    index_params.add_index(
        field_name="embedding_text",          # Campo vetorial
        index_type="IVF_FLAT",                # Tipo do índice
        metric_type="COSINE",                 # Métrica de similaridade
        params={"nlist": 128}                 # Parâmetros do índice
    )

    client.create_index(collection_name, index_params)
    print(f"✅ Índice criado para a coleção '{collection_name}'")
    ```
    > 🧠 **Dica de Performance**: O parâmetro `nlist` para IVF_FLAT deve ser aproximadamente `4 * sqrt(N)` para N vetores, e `nprobe` (parâmetro de busca) entre 1 e `nlist`.

**5.4 Otimização de Desempenho: Guia Rápido**
1.  **Para alta precisão e dados pequenos**: Use **FLAT**.
2.  **Equilíbrio geral (recomendado)**: Inicie com **IVF_FLAT** e ajuste `nlist`/`nprobe`.
3.  **Memória limitada**: Use **IVF_SQ8** (menos memória) ou **IVF_PQ** (muito menos memória).
4.  **Máxima velocidade/precisão (memória disponível)**: Use **HNSW** e ajuste `M`.
5.  **Dados massivos (disco vs. RAM)**: Use **DISKANN**.

*   **Tarefa Prática 5.4**: Suponha um sistema de busca de imagens com 50 milhões de vetores de 512 dimensões. A prioridade é a velocidade de busca, mas o custo de memória é uma preocupação. Você priorizaria **HNSW, IVF_SQ8 ou IVF_FLAT**? (IVF_SQ8 seria um bom equilíbrio aqui. Se a precisão for extremamente crítica, IVF_FLAT com muitos nós. HNSW seria a escolha se o orçamento de memória não fosse um problema tão grande.)

---
### 📝 Módulo 6: Operações CRUD com PyMilvus

#### 🎯 Objetivos
*   Inserir dados em uma Collection.
*   Realizar buscas por similaridade (ANN).
*   Executar consultas híbridas (vetor + filtros).
*   Deletar entidades.

#### 🔍 Tópicos e Tarefas Práticas

**6.1 Inserção de Dados (Insert)**
Insira entidades na sua collection. Dados podem ser inseridos como uma lista de dicionários (linhas) ou dicionário de listas (colunas).

*   **Tarefa Prática 6.1**: Insira 10 produtos de exemplo na sua collection.
    ```python
    from pymilvus import MilvusClient
    import random

    client = MilvusClient(uri="http://localhost:19530")
    collection_name = "produtos_detalhado"

    # Dados de exemplo: 10 produtos
    data = []
    for i in range(10):
        data.append({
            "product_id": i,
            "product_name": f"Produto {i}",
            "price": random.uniform(10, 100),
            "category": "Eletrônicos" if i % 2 == 0 else "Livros",
            "embedding_text": [random.random() for _ in range(384)],
            "embedding_image": [random.random() for _ in range(512)]
        })

    res = client.insert(collection_name=collection_name, data=data)
    print(f"✅ Inseridos {res['insert_count']} produtos.")
    ```

**6.2 Busca por Similaridade (Search)**
A operação `search` encontra os vetores mais próximos de um vetor de consulta (query vector). O `limit` (topK) define quantos resultados retornar.

*   **Tarefa Prática 6.2**: Busque os 3 produtos mais similares no campo `embedding_text` com um vetor de consulta aleatório.
    ```python
    # Busca simples por similaridade
    query_vector = [random.random() for _ in range(384)]

    res = client.search(
        collection_name=collection_name,
        data=[query_vector],               # Lista de vetores de consulta
        anns_field="embedding_text",       # Campo vetorial para buscar
        search_params={"metric_type": "COSINE", "params": {"nprobe": 10}},  # Parâmetros de busca
        limit=3                            # Retorna os top-3
    )

    print("Resultados da busca por similaridade:")
    for hits in res:
        for hit in hits:
            print(f" - ID: {hit['id']}, Distância: {hit['distance']:.4f}")
    ```

**6.3 Busca Híbrida (Filtro + Vetor)**
Combine busca vetorial com filtros em campos escalares usando uma expressão booleana (`expr`).

*   **Tarefa Prática 6.3**: Busque produtos similares, mas apenas da categoria "Eletrônicos".
    ```python
    res = client.search(
        collection_name=collection_name,
        data=[query_vector],
        anns_field="embedding_text",
        search_params={"metric_type": "COSINE", "params": {"nprobe": 10}},
        filter='category == "Eletrônicos"',     # Filtro
        limit=3,
        output_fields=["product_name", "price", "category"]  # Campos para retornar
    )

    print("\nResultados da busca híbrida (categoria Eletrônicos):")
    for hits in res:
        for hit in hits:
            print(f" - Nome: {hit['entity']['product_name']}, Preço: {hit['entity']['price']}")
    ```

**6.4 Consulta (Query) e Deleção (Delete)**
A operação `query` recupera dados com base em filtros, não em similaridade. `delete` remove entidades. **Atenção**: `delete` não libera espaço em disco imediatamente.

*   **Tarefa Prática 6.4**: Execute uma query e uma deleção.
    ```python
    # Query: busca por produtos com preço < 50
    res = client.query(
        collection_name=collection_name,
        filter="price < 50.0",
        output_fields=["product_id", "product_name", "price"]
    )
    print(f"\nProdutos com preço < 50: {len(res)} encontrados.")
    for item in res[:3]:
        print(f" - ID: {item['product_id']}, Nome: {item['product_name']}, Preço: {item['price']}")

    # Delete: remove o produto com ID 0
    client.delete(collection_name=collection_name, filter="product_id == 0")
    print("\n🗑️ Produto com ID 0 deletado.")
    ```

---
### 🛠️ Módulo 7: Operações Avançadas e Manutenção

#### 🎯 Objetivos
*   Implementar Partições para organizar e acelerar consultas.
*   Compreender e configurar os níveis de consistência.
*   Realizar backup e restauração do Milvus.

#### 🔍 Tópicos e Tarefas Práticas

**7.1 Partições: Organizando Dados para Performance**
Partições são subconjuntos lógicos de uma Collection, similares a partições de tabelas em bancos relacionais. Ao criar uma Collection, uma partição padrão chamada `_default` é automaticamente gerada.

*   **Tarefa Prática 7.1**: Crie partições e otimize suas buscas.
    ```python
    from pymilvus import MilvusClient

    client = MilvusClient(uri="http://localhost:19530")
    collection_name = "produtos_detalhado"

    # Cria duas partições
    client.create_partition(collection_name, "eletronicos_2024")
    client.create_partition(collection_name, "livros_2024")
    print("✅ Partições criadas.")

    # Insere um produto na partição "eletronicos_2024"
    client.insert(
        collection_name,
        data=[{"product_id": 999, "product_name": "Tablet X", "price": 299.99, "category": "Eletrônicos"}],
        partition_name="eletronicos_2024"
    )

    # Busca somente na partição "eletronicos_2024"
    res = client.search(
        collection_name,
        data=[[random.random() for _ in range(384)]],
        anns_field="embedding_text",
        partition_names=["eletronicos_2024"],
        limit=3
    )
    print(f"✅ Busca realizada apenas na partição 'eletronicos_2024'. {len(res[0])} resultados.")
    ```

**7.2 Níveis de Consistência**
O Milvus oferece 4 níveis de consistência: `Strong`, `Bounded Staleness` (padrão), `Session` e `Eventual`. Eles permitem ajustar o trade-off entre consistência de leitura e latência.

| Nível | Descrição | Quando Usar |
| :--- | :--- | :--- |
| `Strong` | Leitura sempre vê a escrita mais recente. Alta latência. | Testes funcionais, dados financeiros. |
| `Bounded Staleness` (Padrão) | Tolerância a uma pequena janela de inconsistência. | Maioria dos casos, pois balanceia performance e consistência. |
| `Session` | Garante consistência "read-your-writes" dentro da mesma sessão. | Cenários onde o mesmo cliente precisa ver suas próprias escritas imediatamente. |
| `Eventual` | Leituras podem ver dados desatualizados. Maior desempenho. | Análises, recomendações não críticas. |

*   **Tarefa Prática 7.2**: Altere o nível de consistência para **Session** em uma busca.
    ```python
    res = client.search(
        collection_name=collection_name,
        data=[query_vector],
        anns_field="embedding_text",
        consistency_level="Session",      # Define a consistência
        limit=3
    )
    ```

**7.3 Backup e Restauração com Milvus Backup**
O Milvus Backup é uma ferramenta CLI para backup e restauração.
*   **Tarefa Prática 7.3**: Realize um backup manual.
    *   **Baixe a ferramenta**: Obtenha o binário para seu SO em [Milvus Backup Releases](https://github.com/zilliztech/milvus-backup/releases).
    *   **Configure**: Baixe o arquivo `backup.yaml` e ajuste os parâmetros de conexão. Uma estrutura de diretórios adequada é:
        ```
        ├── configs
        │   └── backup.yaml
        ├── milvus-backup
        └── README.md
        ```
        
    *   **Crie um backup**: Execute o comando no diretório com o binário.
        ```bash
        $ ./milvus-backup create -n backup_colecao_produtos -c produtos_detalhado
        ```
    *   **Restaure (exemplo)**: Para restaurar o backup, use o comando:
        ```bash
        $ ./milvus-backup restore -n backup_colecao_produtos -s _restaurado
        ```
        O novo backup será restaurado em uma coleção chamada `produtos_detalhado_restaurado`.

---
### 📊 Módulo 8: Monitoramento e Observabilidade

#### 🎯 Objetivos
*   Configurar o Prometheus para coletar métricas do Milvus.
*   Visualizar as métricas em dashboards do Grafana.
*   Interpretar as principais métricas para troubleshooting e análise de performance.

#### 🔍 Tópicos e Tarefas Práticas

**8.1 Exportando Métricas com Prometheus**
O Milvus expõe métricas no formato Prometheus em seu endpoint `/metrics`. O Prometheus coleta essas métricas periodicamente.
*   **Tarefa Prática 8.1**: Colete métricas no seu ambiente on-premise.
    *   **Configure o Prometheus**: Adicione o job do Milvus no `prometheus.yml`.
        ```yaml
        scrape_configs:
          - job_name: 'milvus'
            static_configs:
              - targets: ['<IP_DO_MILVUS>:9091']  # Porta padrão de métricas
        ```
    *   **Reinicie o Prometheus** e verifique o alvo na interface web do Prometheus.

**8.2 Visualizando Métricas com Grafana**
O Grafana é a ferramenta padrão para criar dashboards a partir dos dados do Prometheus.
*   **Tarefa Prática 8.2**: Visualize as métricas.
    *   **Adicione a fonte de dados**: No Grafana, vá em `Configuration > Data Sources` e adicione o Prometheus (geralmente `http://localhost:9090`).
    *   **Importe um Dashboard**: O Milvus oferece dashboards prontos. Encontre o ID do dashboard na documentação (ex: `milvus-grafana-dashboard.json`) e importe via `+ > Import` no Grafana, informando o ID.

**8.3 Principais Métricas a Monitorar**

| Métrica | Descrição | Insight |
| :--- | :--- | :--- |
| **`milvus_proxy_search_vectors_count`** | Contagem total de vetores de busca processados. | Volume de tráfego de busca. |
| **`milvus_querynode_search_latency`** | Latência das operações de busca nos nós de consulta. | Performance de busca. |
| **`milvus_datacoord_insert_req_count`** | Contagem de requisições de inserção. | Volume de ingestão de dados. |
| **`milvus_rootcoord_collection_num`** | Número total de coleções. | Escala do sistema. |

*   **Tarefa Prática 8.3**: Pratique o uso de alertas. No Grafana, crie um alerta para ser notificado sempre que a latência média de busca (`milvus_querynode_search_latency`) exceder 500ms por mais de 5 minutos.

---
### 💻 Módulo 9: Projeto Final - Sistema RAG

#### 🎯 Objetivos
*   Consolidar todos os conhecimentos do curso.
*   Construir um sistema de busca e geração aumentada por recuperação (RAG).
*   Implementar uma pipeline completa de ingestão e consulta.

#### 🔍 Tópicos e Tarefas Práticas

**9.1 Introdução ao Projeto**
Você construirá um sistema RAG simples para responder perguntas sobre seus próprios documentos (texto). A arquitetura será:
1.  **Ingestão**: Carregar documentos -> Dividir em chunks -> Gerar embeddings -> Armazenar no Milvus.
2.  **Consulta**: Pergunta do usuário -> Gerar embedding da pergunta -> Buscar chunks similares no Milvus -> Formular prompt -> LLM gera resposta.

**9.2 Configuração do Ambiente**
*   **Tarefa Prática 9.2**: Instale as bibliotecas necessárias.
    ```bash
    $ pip install pymilvus openai langchain langchain-community tiktoken sentence-transformers
    ```
    > ⚠️ **Nota de Segurança**: O uso de LLMs (como os da OpenAI) requer uma chave de API válida. Em um ambiente **on-premise**, você pode substituir por um modelo local, como os disponíveis via Ollama ou Hugging Face, ajustando a célula de geração de texto.

**9.3 Pipeline de Ingestão de Documentos**
Carregue e prepare um documento de exemplo (ex: um arquivo `.txt` sobre política de uso de dados).

*   **Tarefa Prática 9.3**: Crie uma célula no notebook para realizar a ingestão.
    ```python
    from langchain.text_splitter import RecursiveCharacterTextSplitter
    from sentence_transformers import SentenceTransformer
    from pymilvus import MilvusClient
    import uuid

    # 1. Carregar e dividir documentos
    with open("documento.txt", "r") as f:
        text = f.read()
    splitter = RecursiveCharacterTextSplitter(chunk_size=500, chunk_overlap=50)
    chunks = splitter.split_text(text)

    # 2. Gerar embeddings com um modelo gratuito
    model = SentenceTransformer('all-MiniLM-L6-v2')
    embeddings = model.encode(chunks)

    # 3. Conectar ao Milvus e criar a coleção
    client = MilvusClient(uri="http://localhost:19530")
    collection_name = "rag_docs"
    if client.has_collection(collection_name):
        client.drop_collection(collection_name)
    client.create_collection(collection_name=collection_name, dimension=384)

    # 4. Inserir os chunks e embeddings
    data = [{"id": str(uuid.uuid4()), "text": chunk, "vector": emb.tolist()} for chunk, emb in zip(chunks, embeddings)]
    client.insert(collection_name, data)
    print(f"✅ Inseridos {len(data)} chunks no Milvus.")
    ```

**9.4 Pipeline de Consulta e Geração**
Implemente a lógica para o usuário fazer uma pergunta e receber uma resposta baseada nos documentos recuperados.

*   **Tarefa Prática 9.4**: Crie uma célula de consulta.
    ```python
    query = "Qual a política de retenção de dados?"  # Exemplo

    # Gera embedding da query
    query_embedding = model.encode([query])[0]

    # Busca os chunks mais similares
    results = client.search(
        collection_name=collection_name,
        data=[query_embedding.tolist()],
        limit=3,
        output_fields=["text"]
    )

    # Concatena os resultados para formar o contexto
    context = "\n\n".join([hit['entity']['text'] for hit in results[0]])

    print("--- Contexto Recuperado ---")
    print(context)
    print("--- Fim do Contexto ---")

    # Prompt para o LLM (exemplo)
    prompt = f"Responda à pergunta com base no contexto abaixo.\nContexto:\n{context}\n\nPergunta: {query}\nResposta:"
    print(f"\nPrompt para o LLM:\n{prompt}")

    # ... chamada para um LLM local ou API para gerar a resposta final.
    ```

**9.5 Próximos Passos e Desafios**
Parabéns, você construiu um sistema RAG funcional! Agora, você pode expandi-lo:
*   **Suporte a múltiplos documentos**: Modifique a pipeline para armazenar metadados (`documento_origem`, `pagina`).
*   **Busca híbrida**: Combine a busca por similaridade vetorial com uma busca por palavras-chave (usando vetores esparsos).
*   **Avaliação**: Implemente métricas para avaliar a qualidade da recuperação (Hit Rate, MRR).

---
### ✅ Conclusão e Próximos Passos

Ao final deste curso, você estará apto a projetar, implantar, otimizar e administrar uma plataforma Milvus em produção. Para continuar sua evolução profissional com o Milvus, recomendo:

*   Explorar a documentação sobre **autenticação** e **RBAC** (módulo 3) para cenários de produção.
*   Estudar **otimização avançada** de índices (módulo 5) para casos de uso com restrições severas de memória.
*   Aprofundar-se em **monitoramento (módulo 8)**, como a integração com **Loki para logs**, para um sistema de observabilidade completo.
*   Implementar sistemas mais robustos, como **busca multimodal**, que combina texto e imagem em uma única consulta.

---

Abaixo está um curso abrangente sobre Backup/Recuperação, Alta Disponibilidade e Atualizações/Migrações do Milvus, projetado para aplicação prática em seu ambiente on-premise:

---

# 🚀 Milvus para Administradores de Banco de Dados: Backup, Escalonamento e Atualizações

## Metodologia e Convenções

*   **Pré-requisitos**: Para aproveitar ao máximo este guia, é essencial ter conhecimentos básicos de Linux, Docker, Kubernetes e ter completado o primeiro curso dos fundamentos do Milvus.
*   **Convenções nos Exemplos de Código**:
    *   **Práticas recomendadas:** Todo código e comando apresentado segue as melhores práticas de segurança, performance e manutenibilidade.
    *   Linhas de código a serem executadas no terminal são prefixadas com `$`.
    *   Linhas de código que são a saída esperada de um comando são prefixadas com `>`.
    *   Blocos de código Python (`import ...`) devem ser executados em um interpretador Python ou em um arquivo `.py`.
    *   **Comentários** (`# Explicação`) são usados para descrever trechos de código.
    *   Para o seu ambiente **on-premise**, lembre-se de substituir endereços IP, portas, senhas e caminhos de exemplo pelos valores da sua própria infraestrutura.

---

## 📦 Módulo 1: Estratégias de Backup e Recuperação de Desastres (DR)

### 🎯 Objetivos

*   Compreender a arquitetura de backup do Milvus.
*   Realizar backup e restauração de dados utilizando a ferramenta oficial `milvus-backup`.
*   Implementar estratégias de backup automatizadas e testar sua eficácia.
*   Configurar replicação de dados entre clusters usando Change Data Capture (CDC).

### 📚 Tópicos e Tarefas Práticas

#### 1.1 Arquitetura de Backup do Milvus

O Milvus oferece diferentes abordagens para garantir a proteção e recuperação dos seus dados, cada uma adequada a um cenário específico:

| Abordagem | Funcionalidade | Melhor para | Custo/Benefício |
| :--- | :--- | :--- | :--- |
| **Milvus Backup (Backup/Recuperação)** | Cria snapshots pontuais de metadados e segmentos de dados. | Proteção pontual contra exclusão acidental de dados; retenção de longo prazo (ex.: requisitos regulatórios de 7 anos) | **Custo de armazenagem** para manter as cópias; processo **mais lento** de recuperação |
| **Milvus CDC (Replicação Contínua)** | Captura alterações em tempo real (Change Data Capture) do cluster principal para um ou mais clusters secundários. | Alta disponibilidade contínua; failover rápido; cross-region ou multi-cloud para minimizar latência | **Custo adicional** de infraestrutura para manter clusters standby; **baixo RPO/RTO** |
| **K8s Snapshots (Backup do Volume)** | Realiza snapshots a nível de armazenamento persistente (PVC), independente do Milvus. | Se você já utiliza snapshots de volume K8s para outros bancos de dados, é uma opção para integração com a estratégia de DR corporativa | Integração com ferramentas de backup existentes (ex.: Trilio for K8s, Velero) |

#### 1.2 Milvus Backup: Ferramenta CLI Oficial

Milvus fornece uma ferramenta de linha de comando chamada `milvus-backup`, que permite realizar backup e restauração de dados.

*   **Tarefa Prática 1.2**: Instale e configure a ferramenta `milvus-backup`.

**Pré-requisitos da Ferramenta**:

*   Sistema Operacional: **CentOS 7.5+** ou **Ubuntu LTS 18.04+**
*   **Go 1.20.2** ou versão mais recente.

1.  **Baixar o Binário**: Acesse a [página de releases oficial do milvus-backup](https://github.com/zilliztech/milvus-backup/releases) e baixe a versão compatível com o seu ambiente (Linux, macOS).

    ```bash
    # Exemplo de download (substitua pela URL da versão desejada)
    $ wget https://github.com/zilliztech/milvus-backup/releases/download/vx.x.x/milvus-backup_Linux_x86_64.tar.gz
    $ tar -xzvf milvus-backup_Linux_x86_64.tar.gz
    ```

2.  **Configurar o Arquivo `backup.yaml`**: Crie um arquivo de configuração com os parâmetros de conexão para o seu cluster Milvus. O layout de diretório deve ficar assim:
    ```
    .
    ├── configs
    │   └── backup.yaml
    ├── milvus-backup
    └── README.md
    ```
    Conteúdo de `configs/backup.yaml`:
    ```yaml
    # configs/backup.yaml
    milvus:
        version: 2.4.0
        cluster:
            host: "localhost"   # Altere para o IP do seu Milvus
            port: "19530"
    minio:
        # Para uma instalação padrão com Docker Compose
        address: "localhost:9000"
        accessKeyID: "minioadmin"
        secretAccessKey: "minioadmin"
        useSSL: false
        bucketName: "milvus-backup"
    ```

3.  **Testar a Conexão**: Verifique se a ferramenta consegue se conectar ao Milvus.
    ```bash
    $ ./milvus-backup check
    > ... Connected to Milvus successfully ...
    ```

*   **Tarefa Prática 1.3**: Realize um backup **total (full)**.

    ```bash
    # Realiza backup de uma coleção específica
    $ ./milvus-backup create -n backup_marketing_junho -c colecao_produtos

    # Comandos úteis:
    # Lista todos os backups disponíveis
    $ ./milvus-backup list
    # Remove um backup
    $ ./milvus-backup delete -n backup_marketing_junho
    ```

    A ferramenta é capaz de realizar backup de 19GB de dados em apenas alguns minutos, e você pode fazer backup de múltiplas coleções em um único comando ou de todas as coleções de uma só vez.

*   **Tarefa Prática 1.4**: Restaure um backup em um novo cluster.

    O comando a seguir restaura o backup em uma nova coleção chamada `colecao_produtos_restaurada`:
    ```bash
    $ ./milvus-backup restore -n backup_marketing_junho -s _restaurada
    ```
    A ferramenta então lê os metadados e segmentos do backup, recria a coleção no Milvus de destino e copia os dados.

#### 1.3 Automatizando Backups com Scripts

Para ambientes de produção, é essencial configurar backups periódicos.

*   **Tarefa Prática 1.5**: Crie um script `backup.sh` para automatizar o backup diário.

    ```bash
    #!/bin/bash
    # backup.sh - Script de backup diário do Milvus

    # Define uma variável com a data atual
    DATA=$(date +%Y%m%d_%H%M%S)
    NOME_BACKUP="backup_prod_$DATA"

    echo "Iniciando backup do Milvus..."

    # Executa o backup de todas as coleções
    ./milvus-backup create -n $NOME_BACKUP -c "*"

    if [ $? -eq 0 ]; then
        echo "Backup $NOME_BACKUP criado com sucesso!"

        # Remove backups com mais de 7 dias
        # (ajuste conforme a política de retenção da sua empresa)
        ./milvus-backup list | grep "backup_prod_" | head -n -7 | xargs -I {} ./milvus-backup delete -n {}
    else
        echo "ERRO: Falha ao criar o backup $NOME_BACKUP"
        exit 1
    fi
    ```

    Agende o script no cron para execução diária à 01:00:
    ```bash
    $ crontab -e
    # Adicione a linha:
    0 1 * * * /caminho/para/backup.sh >> /var/log/milvus_backup.log 2>&1
    ```

#### 1.4 Milvus CDC (Change Data Capture) para Replicação Contínua

CDC permite replicar dados de um cluster Milvus principal para um ou mais clusters de espera (standby), garantindo alta disponibilidade e minimizando a perda de dados em caso de falha.

*   **Tarefa Prática 1.6**: Configure a replicação CDC entre dois clusters.

    **Arquitetura da Solução**: O CDC requer a implantação de um **CDC Node** que monitora as alterações no cluster principal e as aplica ao(s) cluster(s) standby. A topologia comum é mestre-escravo (um cluster ativo, um passivo), mas a ferramenta também suporta um mestre para vários escravos.

    | Topologia | Descrição | Caso de Uso |
    | :--- | :--- | :--- |
    | **Um-para-Um (Active-Standby)** | Um cluster principal (Master) envia alterações para um único cluster de espera (Standby). | **Principal**. Alta disponibilidade regional com failover simples. |
    | **Um-para-Vários (Fan-out)** | Um cluster principal replica para múltiplos clusters de espera. | Distribuição de leitura, disaster recovery multi-região, ambientes de teste sincronizados. |

    **Pré-requisitos**:
    *   Dois clusters Milvus em execução (versões compatíveis).
    *   Acesso à rede entre eles.

    **Passo a passo**: (Consulte a [documentação oficial de configuração](https://milvus.io/docs/zh/set_up_cdc_replication.md) para detalhes exatos. O processo envolve implantar o CDC Node como um serviço e, em seguida, criar uma tarefa de replicação para definir a relação de origem para destino):

    ```yaml
    # Exemplo de configuração da tarefa de replicação
    name: my-replication-task
    source:
      host: primary-milvus.default.svc.cluster.local
      port: 19530
    target:
      host: standby-milvus.default.svc.cluster.local
      port: 19530
    collections:
      - "*"   # Replica todas as coleções
    ```

#### 1.5 Estratégia de Recuperação de Desastres (DR)

Para um plano de DR completo, uma combinação de estratégias é recomendada:

| Nível de Proteção | Estratégia | RPO (Perda de Dados) | RTO (Tempo para Recuperar) | Custo de Implementação |
| :--- | :--- | :--- | :--- | :--- |
| **1. Proteção Básica** | Backup diário (Full) + retenção de 7 dias | Até 24 horas | Horas (restauração completa) | Baixo |
| **2. Proteção Intermediária** | Backup diário (Full) + CDC síncrono (Standby cluster) | Segundos | Minutos (failover manual) | Médio |
| **3. Proteção Avançada** | Backup diário + CDC + Cluster Standby em outra zona (multi-AZ) + Failover automático | Segundos | Segundos (failover automático) | Alto |

**Decisão Arquitetural**: Para um sistema de recomendação para uma empresa de médio porte, um RPO de até 6 horas é aceitável. Para uma plataforma de e-commerce (perda de carrinhos de compra durante o Black Friday é inaceitável), um RPO de segundos com CDC se torna fundamental.

**Diferença entre `switchover` (planejado) e `failover` (automático):**
*   **Switchover (RPO = 0)**: Usado para manutenção planejada. Espera a replicação terminar antes de trocar os papéis.
*   **Failover (RPO > 0)**: Usado quando o cluster principal falha inesperadamente. Implica perda de qualquer dado que ainda não foi replicado para o standby.

---

## ⚙️ Módulo 2: Escalonamento e Alta Disponibilidade (HA)

### 🎯 Objetivos

*   Compreender os diferentes modos de implantação (Standalone vs. Cluster) e seus impactos na HA.
*   Configurar escalonamento horizontal (scale out/in) de componentes do cluster Milvus.
*   Implementar balanceamento de carga (Proxy) e replicação de componentes (Coordinator HA).
*   Monitorar e ajustar a capacidade do cluster.

### 📚 Tópicos e Tarefas Práticas

#### 2.1 Modos de Implantação e Arquitetura

Para entender a HA, é crucial compreender como o Milvus se comporta em seus modos de operação:

| Característica | Standalone | Cluster (Distribuído) |
| :--- | :--- | :--- |
| **Alta Disponibilidade** | Ponto único de falha (SPOF).| Tolerante a falhas (nós redundantes). |
| **Escalonamento Horizontal** | Não suportado. | Suporte nativo para workers. |
| **Cenários de Uso** | Desenvolvimento, testes, POCs. | **Produção**, workloads de alta performance e grande escala. |
| **Complexidade** | Muito baixa (Docker Compose). | Alta (Kubernetes, dependências). |

**Para produção, o modo Cluster é a única escolha viável.**

A arquitetura do Milvus separa os componentes em diferentes papéis, cada um com responsabilidades distintas para escalabilidade e resiliência:

| Componente | Função | Escalonamento Horizontal | Considerações |
| :--- | :--- | :--- | :--- |
| **Proxy** | Ponto de entrada da aplicação (API Gateway). Rotas e distribuição de solicitações. | **Alta**: Stateless (pode ter múltiplas réplicas). | Escale horizontalmente para aumentar o throughput de requisições. |
| **QueryNode** | Executa consultas sobre dados históricos (Já persistidos). | **Média/Alta**: Pode distribuir segmentos entre múltiplos nós. | Escale para maior QPS (consultas por segundo). Aumento linear de desempenho com o número de nós. |
| **DataNode** | Processa dados em crescimento (streaming), flushing e compactação. | **Alta**: Pode processar chunks de dados em paralelo. | Escalonamento melhora a ingestão de dados. |
| **IndexNode** | Constrói índices. | **Média**: Cada nó constrói índices para um segmento de cada vez. | Escalonamento acelera a construção e otimização de índices. |
| **MixCoord (Coordenador)** | Orquestração global (coordena os nós de trabalho). | **Alta**: Suporte Active-Standby. | **Crítico para HA** (desde a v2.3.3). |

#### 2.2 Escalonamento Horizontal (Scale Out/In)

Com o cluster Milvus implantado no Kubernetes usando o Milvus Operator, o processo de escalonamento é declarativo e seguro.

**Pré-condição de Escalonamento**: Para realizar o scale out/in, sua aplicação não precisa estar parada, mas é importante planejar horários de menor pico.

*   **Tarefa Prática 2.2**: Escale os nós de consulta (QueryNode) da sua aplicação.

    A operação é feita editando o recurso customizado (CR) que define o cluster.

    1.  **Edite a configuração do cluster**:
        ```bash
        $ kubectl edit milvus my-release -n milvus
        ```

    2.  **Modifique o número de réplicas** do componente desejado:
        ```yaml
        # ... dentro do objeto Milvus
        spec:
          components:
            queryNode:
              replicas: 5   # Altere de 3 para 5, por exemplo
        ```

    3.  **Salve e saia**. O Milvus Operator automaticamente cria ou remove os pods necessários para atender à nova especificação.

*   **Tarefa Prática 2.3**: Configure o escalonamento automático (Horizontal Pod Autoscaling - HPA).

    O HPA no Kubernetes pode ajustar automaticamente o número de pods de um componente com base em métricas como uso de CPU e memória.

    Criar um recurso HPA para os proxies (porta de entrada da aplicação):
    ```yaml
    # hpa-milvus-proxy.yaml
    apiVersion: autoscaling/v2
    kind: HorizontalPodAutoscaler
    metadata:
      name: milvus-proxy-hpa
      namespace: milvus
    spec:
      scaleTargetRef:
        apiVersion: apps/v1
        kind: Deployment
        name: my-release-milvus-proxy
      minReplicas: 2
      maxReplicas: 10
      metrics:
      - type: Resource
        resource:
          name: cpu
          target:
            type: Utilization
            averageUtilization: 70
    ```
    Aplique a configuração:
    ```bash
    $ kubectl apply -f hpa-milvus-proxy.yaml
    ```
    O sistema então começa a monitorar o recurso e ajustar o número de replicas conforme necessário.

#### 2.3 Componentes de Infraestrutura Críticos para Alta Disponibilidade

Para uma verdadeira alta disponibilidade, você precisa garantir que as dependências externas do Milvus também estejam configuradas em HA.

| Dependência Externa | Função no Milvus | Configuração Essencial para HA em Produção |
| :--- | :--- | :--- |
| **etcd (Metadados)** | Armazena todos os metadados do cluster. | **Cluster com 3 ou 5 nós** (raft quorum) para tolerância a falhas. |
| **Pulsar/Kafka (Message Queue)** | Gerencia o Write-Ahead Logging (WAL) e o stream de dados. | **Cluster Pulsar/Kafka multinó**. Ao menos 3 brokers para garantir HA. |
| **MinIO/S3 (Object Storage)** | Armazena os segmentos de dados e os índices. | **MinIO em modo distribuído** (4+ nós) ou bucket S3 com versionamento ativado. |

*   **Tarefa Prática 2.4**: Configure a alta disponibilidade do coordenador (Coordinator HA).

    Desde a versão 2.3.3, o Milvus oferece suporte nativo à configuração de HA para coordenadores (MixCoord) através do modo Active-Standby. Isso significa que se o coordenador ativo falhar, o standby assume automaticamente a liderança.

    Para ativar esta funcionalidade, edite o YAML de configuração do seu cluster Milvus:
    ```yaml
    # No seu arquivo values.yaml (Helm) ou custom resource (Operator)
    mixCoordinator:
      replicas: 2          # Número de réplicas
      activeStandby:
        enabled: true      # Habilita o modo active-standby
    ```

#### 2.4 Balanceamento de Carga (Proxy) e HA de Acesso

Para tornar o acesso ao cluster altamente disponível, implemente um balanceador de carga na frente dos pods de Proxy do Milvus. Isso distribui o tráfego de entrada e fornece um IP único para a aplicação.

*   **Tarefa Prática 2.5**: Configure HAProxy para balancear o tráfego entre os proxies do Milvus.

    Esta implementação requer dois servidores de balanceamento configurados em alta disponibilidade usando Keepalived, que gerencia um endereço IP virtual (VIP) que flutua entre eles. A configuração do HAProxy redireciona o tráfego para o(s) serviço(s) Kubernetes do Milvus.

    ```haproxy
    # Exemplo de configuração minimalista do HAProxy
    frontend milvus_frontend
        bind *:19530
        default_backend milvus_backend

    backend milvus_backend
        balance roundrobin
        server milvus-proxy-1 <IP_DO_PROXY_1>:19530 check
        server milvus-proxy-2 <IP_DO_PROXY_2>:19530 check
        server milvus-proxy-3 <IP_DO_PROXY_3>:19530 check
    ```

---

## 🔄 Módulo 3: Atualização de Versão e Migração de Dados

### 🎯 Objetivos

*   Compreender as compatibilidades de versão e as melhores práticas para upgrade.
*   Realizar rolling upgrade (atualização sem downtime) de um cluster Milvus em produção.
*   Executar a migração de metadados entre versões principais (major).
*   Planejar a estratégia de rollback em caso de falha.

### 📚 Tópicos e Tarefas Práticas

#### 3.1 Planejamento do Upgrade: Compatibilidade e Checklist de Pré-upgrade

**Compatibilidade**: O primeiro passo é verificar a matriz de compatibilidade do Milvus Backup, especialmente se você usa a ferramenta, e as notas de lançamento da versão alvo. Em geral:

*   **Patching (v2.x.y → v2.x.z)**: Normalmente seguro e suporta **rolling upgrade** sem downtime.
*   **Minor/Major (v2.x.y → v2.(x+1).0)**: Pode exigir migração de metadados, especialmente para versões mais antigas (ex: 2.1.x para 2.2.x).

**Checklist de Pré-upgrade**:

| Item da Checklist | Ação | Por que é importante |
| :--- | :--- | :--- |
| **1. Backup Completo** | Realize um backup completo com `milvus-backup`. | Permite rollback seguro em caso de falha ou corrupção de dados durante o upgrade. |
| **2. Revisar Notas da Versão** | Leia atentamente as [Release Notes](https://milvus.io/docs/release_notes.md) da versão alvo. | Identifica breaking changes, novas features ou depreciações que podem afetar sua aplicação. |
| **3. Validar Ambiente K8s** | `kubectl version` | Garante que a versão do Kubernetes é suportada pela nova versão do Milvus. |
| **4. Testar em Ambiente de Staging** | Execute o procedimento completo em uma cópia do ambiente de produção. | É a única maneira segura de validar o upgrade sem impactar usuários reais. |
| **5. Planejar Janela de Manutenção** | Reserve um período de baixa atividade para o upgrade. | Apesar do rolling upgrade minimizar downtime, uma janela é recomendada para observação pós-upgrade. |

#### 3.2 Realizando Upgrade com Milvus Operator

O Milvus Operator oferece a maneira mais robusta e de alto nível para gerenciar upgrades em clusters Kubernetes.

*   **Tarefa Prática 3.2**: Realize um upgrade de uma versão v2.3.x para v2.4.x.

    Assumindo que o cluster já está com rolling update habilitado:

    1.  **Edite a configuração do cluster**:
        ```bash
        $ kubectl edit milvus my-release -n milvus
        ```

    2.  **Atualize a imagem do Milvus**:
        ```yaml
        spec:
          components:
            image: milvusdb/milvus:v2.4.0   # Atualize para a nova tag
            enableRollingUpdate: true        # Já deve estar true
        ```

    3.  **Salve e saia**. O Operator orquestra o rolling update, atualizando os pods de acordo com suas dependências, o que reduz significativamente o tempo de inatividade do serviço.

    4.  **Acompanhe o progresso**:
        ```bash
        $ kubectl get pods -n milvus -w
        ```
        Você verá os pods sendo recriados um a um, com o serviço permanecendo disponível para consultas durante o processo.

#### 3.3 Migração de Dados para Clusters Novos ou Diferentes

Existem cenários onde um simples upgrade não é suficiente (ex: migração para um hardware novo, ou para um cluster com topologia diferente). Nesses casos, a migração de dados é necessária.

**Estratégias de Migração**:
1.  **Backup e Restore**: Use `milvus-backup` para extrair os dados do cluster antigo e restaurá-los no novo cluster. A ferramenta `milvus-migration` foi desenvolvida pela comunidade para cenários mais específicos, como migração entre diferentes versões ou para o Zilliz Cloud.
2.  **CDC para Migração Contínua**: Configure o CDC entre o cluster antigo (como fonte) e o novo cluster (como destino). Isso permite uma migração *live*, onde as gravações continuam no cluster antigo enquanto o novo é atualizado, e no final você promove o novo cluster com um downtime quase zero.
3.  **Copy de Volumes (K8s)** : Se os clusters compartilham o mesmo armazenamento de objetos (ex: mesmo bucket MinIO), você pode apenas copiar os dados do volume MinIO e os metadados do etcd, garantindo que os caminhos de armazenamento sejam compatíveis.

**Documentação de Produção Crucial**: Embora seja possível copiar os volumes (caminho 3 acima), a recomendação oficial para garantir a integridade dos dados e a compatibilidade entre clusters Milvus é sempre usar as ferramentas oficiais (`milvus-backup`, `milvus-migration`) ou o CDC, que são projetados para manter a consistência.

#### 3.4 Estratégia de Rollback (Downgrade)

Em caso de problemas pós-upgrade, um downgrade pode ser necessário.

*   **Tarefa Prática 3.4**: Realize um downgrade do Milvus.

    **Atenção**: Um downgrade é uma operação potencialmente perigosa. A abordagem mais segura é **restaurar um backup** anterior.

    ```bash
    # Exemplo de downgrade (menos arriscado apenas para upgrades recentes)
    $ kubectl edit milvus my-release -n milvus
    # Altere a imagem para a versão anterior
    spec:
      components:
        image: milvusdb/milvus:v2.3.9
        imageUpdateMode: rollingDowngrade   # Define o modo de downgrade
    ```

    Em versões muito antigas, o downgrade pode não ser suportado ou pode causar corrupção de dados. A **estratégia recomendada** é:
    1.  Fazer backup completo antes do upgrade.
    2.  Após o upgrade, se você precisar voltar, você restaura o backup de pré-upgrade em um novo cluster limpo.
    3.  Redirecione o tráfego para o novo cluster restaurado.

---

## ✅ Conclusão e Próximos Passos

Neste curso, você aprendeu como construir uma estratégia robusta de operações para o Milvus em produção. Agora, você consegue:

*   Implementar **backup e recuperação** de desastres, utilizando `milvus-backup` para backup de dados e automatizando o processo em scripts.
*   Planejar e executar **escalonamento horizontal** do cluster para atender à demanda, balancear carga, e garantir alta disponibilidade de componentes críticos como o Proxy e o Coordenador.
*   Gerenciar o ciclo de vida do Milvus, realizando **upgrades seguros** de versão com mínimo downtime, além de entender quando e como fazer downgrades.

Para continuar sua evolução profissional com o Milvus, recomendo:

*   Explorar o uso de **Velero** para backup de todo o estado de um cluster Kubernetes (incluindo configurações do Milvus Operator e volumes persistentes), o que simplifica a recuperação de desastres em nível de infraestrutura.
*   Aprofundar-se em **otimização de índices e particionamento** para melhorar ainda mais a performance de busca em clusters massivos.
*   Estudar **estratégias avançadas de failover automático**, combinando o CDC do Milvus com ferramentas como **HAProxy** e **Keepalived** para failover quase instantâneo.
*   Ler os **roadmap oficial e os planos de versão do Milvus** para se antecipar a mudanças e novas funcionalidades nas próximas versões, como a planejada v3.0.
