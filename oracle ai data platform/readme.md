## 1. Fundação e Governança de Dados (Arquitetura Medallion)

    1.1 Provisionamento do Workbench: Criar a instância do Oracle AI Data Platform Workbench para centralizar fluxos de engenharia e ciência de dados.

    1.2 Configuração de IAM e RBAC: Estabelecer políticas de Identity and Access Management (IAM) e definir funções de acesso (Admin, Data Engineer, Data Steward).

    1.3 Estruturação das Camadas Medallion: Provisionar buckets no Object Storage e esquemas no Autonomous Database para as camadas Bronze (bruto), Silver (limpo) e Gold (curado/IA-ready).

    1.4 Implementação de Formatos Abertos: Configurar o suporte nativo para Apache Iceberg e Delta Lake para garantir interoperabilidade multicloud.

    1.5 Catálogo Mestre Unificado: Registrar todas as fontes de dados estruturadas e não estruturadas no Master Catalog para rastreamento de linhagem e metadados.

## 2. Gestão de Dados Híbrida e Busca Vetorial

    2.1 Criação de Vector Stores: Configurar o tipo de dado VECTOR nativo no Oracle AI Database 26ai.

    2.2 Pipelines de Embedding: Desenvolver fluxos para conversão de dados não estruturados (documentos, imagens) em vetores utilizando modelos ONNX ou APIs de provedores externos.

    2.3 Infraestrutura de RAG: Implementar a arquitetura de Retrieval-Augmented Generation para conectar modelos de linguagem (LLMs) aos dados proprietários em tempo real.

    2.4 Indexação Vetorial: Criar índices de busca por similaridade (HNSW) para garantir performance em consultas semânticas de larga escala.

## 3. Performance e Otimização de Workloads de IA

    3.1 Ativação do Autonomous AI Database: Provisionar instâncias autônomas para automação de patching, tunning e escalonamento elástico.

    3.2 Configuração In-Memory Deep Vectorization: Habilitar o processamento vetorial em memória para acelerar consultas de IA.

    3.3 Otimização de Metadados para Select AI: Enriquecer o dicionário de dados (comentários em tabelas e restrições) para aumentar a acurácia da tradução de linguagem natural para SQL.

    3.4 Data Lake Accelerator: Configurar o acelerador de consultas para otimizar a performance de dados residentes em nuvens de terceiros ou object storage.

## 4. Segurança e Guardrails de IA

    4.1 Implementação de AI Security Guardrails: Configurar filtros para moderação de conteúdo, detecção de injeção de prompt e proteção de informações de identificação pessoal (PII).

    4.2 Propagação de RBAC para IA: Garantir que as políticas de segurança do banco de dados (VPD, RAS) sejam aplicadas automaticamente às respostas geradas pelos agentes de IA.

    4.3 Isolamento via Database Vault: Ativar o Oracle Database Vault para restringir o acesso de usuários privilegiados a dados sensíveis durante processos de treinamento.

    4.4 Auditoria Fina (FGA): Estabelecer trilhas de auditoria para monitorar interações com LLMs e o uso de dados pela IA.

## 5. Desenvolvimento de Sistemas Agênticos

    5.1 Configuração de Select AI Profiles: Definir perfis de IA que integrem o banco de dados a provedores de LLM (OCI GenAI, OpenAI, Cohere).

    5.2 Habilitação de Servidores MCP: Ativar o Model Context Protocol (MCP) para permitir que assistentes de IA descubram e executem ferramentas de banco de dados nativamente.

    5.3 Orquestração Agent2Agent (A2A): Implementar o protocolo A2A para permitir a colaboração segura entre múltiplos agentes especializados.

    5.4 Interfaces Conversacionais APEX: Desenvolver aplicações low-code integradas ao assistente de IA para interação via linguagem natural.

## 6. FinOps e Governança Financeira

    5.1 Configuração do FinOps Hub: Centralizar o monitoramento de custos no console OCI utilizando o padrão FOCUS.

    5.2 Implementação de Elastic Pools: Agrupar instâncias de banco de dados para otimizar o compartilhamento de recursos e reduzir o TCO.

    5.3 Orçamentos e Cotas: Definir limites de gastos (Budgets) e cotas de serviço específicas para workloads de treinamento e inferência de IA.

    5.4 Ciclo de Vida de Dados (ADO): Configurar políticas de Automatic Data Optimization para mover dados históricos para camadas de armazenamento de baixo custo.

*semi revisado*

