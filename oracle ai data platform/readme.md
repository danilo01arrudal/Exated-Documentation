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

---

### Ações para Estabelecer: 1. Fundação da Tenancy e Ingestão (VISA Scenario)

Para um sistema de cartões, a ingestão precisa suportar baixa latência e alta disponibilidade. Utilizaremos o Oracle AI Data Platform Workbench (como ilustrado na imagem que você enviou) para automatizar o fluxo entre os nós de processamento.

#### Fase 1.1: Governança de Acesso e Identidade (Foco em Dados Sensíveis)

        Diferente do varejo comum, aqui a segregação de funções deve impedir que desenvolvedores de IA acessem dados brutos de cartões.
        Compartimentos Críticos:
        Crie Card_Network_Root > Compliance_Raw_Data (acesso restrito) e AI_Sandbox_Dev.
        Políticas de "Least Privilege" para AIDP:

SQL
-- Permite que o Workbench gerencie recursos apenas no compartimento financeiro
allow group aiOpsAdmins to manage ai-data-platforms in compartment Compliance_Raw_Data
-- Permite que o serviço interaja com o Object Storage para logs de transações
allow any-user to manage buckets in compartment Compliance_Raw_Data where all {request.principal.type='aidataplatform'}

#### Fase 1.2: Instanciação do Workbench e Lakehouse Financeiro

Criação da Instância AIDP:

Navegue até Analytics & AI > AI Data Platform.

Nome: VISA_Network_Intelligence_Workbench.

Vínculo com o Oracle AI Database 26ai:

Provisione ou vincule uma instância Autonomous AI Database. No cenário financeiro, selecione o tipo de workload Transaction Processing (ATP) para garantir a atomicidade das transações que alimentam os modelos.

Configuração de Redes Privadas (Crucial para VISA):

Configure um Private Endpoint para que o Workbench consuma feeds de transações do seu datacenter on-premises via FastConnect, garantindo que nenhum dado trafegue pela internet pública.

##### Fase 1.3: Estruturação da Camada Bronze (Landing Zone Segura)

Bucket Bronze de Transações:

Crie o bucket: Visa_Bronze_TX_Logs.

Configuração de Segurança: Habilite criptografia gerenciada pelo cliente (Vault) e ative a versão do objeto.

Gatilho de Eventos: Marque a opção Emit Object Events.

Mapeamento no Master Catalog:

No Workbench, crie um External Catalog.

Mapeie as entidades de transação bruta (ISO 8583). Isso cria a visão lógica necessária para que as Tasks (como as Task_4 e Task_5 da sua imagem) comecem a processar o refinamento sem mover o dado fisicamente.

#### Fase 1.4: Automação do Live Feed (Ingestão em Tempo Real)

Para detectar fraudes, o dado deve ser ingerido no momento em que o arquivo de log cai no bucket:

Configuração no Database Actions:

Acesse o Live Feed Data no seu Autonomous AI Database.

Selecione o bucket Visa_Bronze_TX_Logs.

Ative a Notification URL e copie-a.

Orquestração OCI (Eventos + Notificações):

Crie um OCI Notification Topic chamado Fraud_Alert_Ingest.

Crie uma OCI Event Rule:

Condição: Object - Create no bucket Bronze.

Ação: Enviar para o tópico via protocolo HTTPS usando a URL copiada.

Checklist de Entrega (Fase 1 - VISA):

[ ] Tenancy isolada com Private Endpoints (Criptografia de ponta a ponta).

[ ] Workbench configurado e pronto para orquestrar as Tasks de transformação.

[ ] Bucket Bronze emitindo eventos para ingestão em milissegundos.

[ ] Master Catalog mapeado para feeds ISO 8583.

---

### Fase 2: Provisionamento do AI Data Platform Workbench (VISA Scenario)

#### 2.1. Instanciação e Vínculo com o Lakehouse Financeiro

O Workbench atua como a camada de desenvolvimento colaborativo que conecta cientistas de dados, engenheiros e analistas de fraude. 

Criação da Instância:

No console OCI, navegue até Analytics & AI > AI Data Platform Workbenches.

Clique em Create AI Data Platform Workbench.

Nome: VISA_Intelligence_Workbench.

Políticas de Acesso: Selecione Advanced para aplicar permissões restritas apenas ao compartimento financeiro, garantindo o princípio do privilégio mínimo exigido pelo PCI-DSS.

Configuração do Primeiro Workspace:

Crie o workspace: Fraud_Detection_Production.

Este workspace isolará os artefatos de IA (notebooks e workflows) usados para o scoring de transações VISA.

Vínculo com o Banco de Dados (Camada Gold):

Selecione obrigatoriamente um Oracle Autonomous AI Database versão 26ai ou superior.

No cenário VISA, escolha o workload Transaction Processing (ATP) para garantir a atomicidade das transações e o processamento de vetores em milissegundos.

#### 2.2. Configuração de Redes Privadas (Private Endpoint)

Para que o Workbench processe transações sem expô-las à internet, é obrigatória a configuração de um Private Endpoint.

Provisionamento do Endpoint Reverso:

Configure o Private Endpoint em uma sub-rede dedicada dentro da sua VCN financeira.

Requisito de IP: Reserve no mínimo 8 endereços IP na sub-rede (o serviço consumirá 3 nativamente para o balanceamento do Workbench).

Resolução de Nomes (DNS):

O Private Endpoint do AIDP não suporta IPs diretos para fontes externas (como servidores de autorização on-premises). Você deve configurar o resolver de DNS da sub-rede para resolver os hostnames dos sistemas legados da VISA.

Regras de Egress (Saída):

Configure o Security List ou NSG para permitir tráfego de saída apenas para as portas específicas do banco de dados (1521/1522) e repositórios de segurança.

#### 2.3. Configuração de Compute (Clusters Spark)

O motor de processamento do Workbench é movido pelo Apache Spark gerenciado, essencial para transformar logs brutos ISO 8583 em formatos IA-ready (Bronze para Silver).

Criação do Cluster Spark:

Dentro do Workbench, vá na aba Compute e clique em Create Cluster.

Configuração de Auto-scaling: Ative o escalonamento automático para suportar picos de processamento em datas como Black Friday sem intervenção manual.

Instalação de Bibliotecas Customizadas:

Crie um arquivo requirements.txt no diretório compartilhado e instale bibliotecas de ciência de dados (como pandas, scikit-learn ou conectores JDBC específicos para sistemas financeiros).

#### 2.4. Governança de Roles e Auditoria (Padrão Compliance)

A plataforma utiliza RBAC (Controle de Acesso Baseado em Função) para separar quem desenvolve a IA de quem audita as decisões financeiras.

Atribuição de Papéis Sistêmicos:

AI_DATA_PLATFORM_ADMIN: Atribuído apenas ao gestor de infraestrutura (capaz de gerenciar todos os objetos).

AUDITOR: Atribuído à equipe de conformidade da VISA para visualizar toda a trilha de auditoria dos modelos e interações de IA.

Mapeamento de Usuários:

Vincule os grupos do seu Identity Domain (ex: visaFraudTeam) às roles do Workbench para garantir que apenas analistas autorizados criem os fluxos de automação.

Resumo do Checklist de Entrega (Fase 2)

[ ] Workbench instanciado com política Advanced (PCI-ready).

[ ] Workspace de produção isolado e vinculado ao Autonomous 26ai.

[ ] Private Endpoint configurado com reserva de 8 IPs e DNS funcional.

[ ] Cluster Spark configurado com Auto-scaling para volumes massivos.

[ ] Roles de Auditoria ativadas para rastreabilidade financeira.

Resultado: O ambiente está pronto para que possamos construir os fluxos de automação (como os vistos no diagrama: Task_4 para transações válidas e Task_5 para casos suspeitos).

---

### Fase 3: Implementação da Camada Bronze (Landing Zone Segura)

#### 3.1. Configuração do OCI Object Storage (Landing Zone)

A Camada Bronze reside fisicamente em buckets criptografados no OCI Object Storage, projetados para escala ilimitada e durabilidade de "11 noves".

Criação do Bucket Bronze:

Navegue até Storage > Object Storage > Buckets.

Nome: Visa_Bronze_Landing_Zone.

Criptografia: Selecione Encrypt using customer-managed keys vinculada ao seu OCI Vault para atender aos requisitos de segurança de dados financeiros.

Habilitação de Eventos (Obrigatório):

Nas propriedades do bucket, clique em Edit ao lado de Emit Object Events.

Marque a caixa e salve. Isso permite que o OCI Events dispare a automação de ingestão.

#### 3.2. Registro no Master Catalog (Workbench)

O Master Catalog no Workbench fornece uma visão lógica centralizada sem a necessidade de mover o dado fisicamente.

Criação do External Catalog:

No Workbench, vá em Master Catalog e clique em Create Catalog.

Tipo: External Catalog.

Fonte: OCI Object Storage.

Associação: Vincule ao bucket Visa_Bronze_Landing_Zone.

Mapeamento de Entidades:

Mapeie os arquivos brutos (CSV/JSON/Parquet) como entidades lógicas. Isso permite que os analistas de fraude executem consultas SQL diretamente sobre os arquivos brutos usando o motor Spark.

#### 3.3. Automação da Ingestão via Live Feed (Event-Driven)

Diferente de processos em lote (batch) tradicionais, o Live Feed carrega os dados automaticamente no Autonomous AI Database assim que eles chegam ao bucket.

Geração da URL de Notificação:

No Database Actions do seu Autonomous AI Database, vá em Data Studio > Data Load > Feed Data.

Crie um objeto Live Table Feed apontando para o bucket Bronze.

Marque Enable for Notification. O sistema gerará uma Notification URL única. Copie esta URL.

Configuração do OCI Notification & Events:

Notifications: Crie um tópico Visa_Ingest_Topic. Crie uma subscrição com o protocolo HTTPS (Custom URL) e cole a URL copiada acima.

Events Service: Crie uma regra Trigger_Visa_Ingest.

Condição: Event Type: Object Storage, Event: Object - Create.

Filtro: Bucket Name: Visa_Bronze_Landing_Zone.

Ação: Enviar para o tópico Visa_Ingest_Topic.

#### 3.4. Orquestração da Automação (Visual Workflow)

Como ilustrado na imagem do seu modelo (Workbench Automation), a Camada Bronze dispara o fluxo inicial.

Definição da Tarefa de Entrada:

Crie um Workflow no Workbench onde a primeira tarefa é o monitoramento da Camada Bronze.

Configure dependências para que o refinamento (Camada Prata) só inicie após a confirmação do Live Table Feed bem-sucedido.

Resumo do Checklist de Entrega (Fase 3)

[ ] Bucket Bronze criado com Customer-Managed Keys e Emit Object Events habilitado.

[ ] Master Catalog configurado com External Catalog para visão lógica dos dados brutos.

[ ] Live Table Feed configurado no banco de dados com a opção de notificação ativa.

[ ] OCI Event Rule vinculada para disparar a ingestão no momento da criação do arquivo.

[ ] Auditoria de Acesso ativada para rastrear todas as movimentações na Camada Bronze (Compliance VISA).

Resultado: Sua infraestrutura agora possui uma "esteira" de dados em tempo real. Cada transação VISA que "cai" no bucket é imediatamente refletida no banco de dados, pronta para o refinamento.

---

### Fase 4: Refinamento Medallion (Silver & Gold) e Scoring de Fraude

#### 4.1. Construção da Camada Silver (Standardization & Cleaning)

O objetivo aqui é tornar os dados estruturalmente íntegros, consistentes e fáceis de unir com outras fontes.

Parseamento ISO 8583: Criar um Python Notebook no Workbench vinculado ao seu Cluster Spark para converter os campos complexos de logs de cartões em colunas relacionais legíveis.

Padronização Financeira: Implementar rotinas de normalização para códigos de moedas, unidades de tempo (fuso horário global da rede) e nomes de estabelecimentos (Merchant Cleaning).

Escrita em Formato Aberto: Salvar o resultado no Object Storage utilizando Apache Iceberg ou Delta Lake. Isso permite "Time Travel" (consultar versões passadas dos dados para auditorias de fraude retroativas).

#### 4.2. Implementação do Fluxo de Automação (Branching Logic)

Aqui aplicamos a lógica visual vista na sua imagem, onde o fluxo se divide após uma avaliação.

Task de Scoring (O Gatilho): Criar uma tarefa que executa um modelo de Machine Learning (via Oracle Machine Learning ou modelo ONNX importado) para calcular o risk_score da transação. 

Implementação da Ramificação (Condicional):

Caminho Verde (Task_4 - Approved): Se o risk_score for baixo (Ex: < 0.7), a automação move o dado diretamente para a Camada Gold.

Caminho Vermelho (Task_5 - Suspicious): Se o risco for alto, a tarefa envia o registro para uma fila de investigação manual e bloqueia preventivamente o limite do cartão.

#### 4.3. Curadoria da Camada Gold (IA-Ready Database)

A Camada Gold é o destino final no Autonomous AI Database, onde os produtos de dados mais confiáveis são armazenados para consumo imediato por aplicações e IAs.

Materialização de Tabelas Gold: Configurar a Task_4 para inserir os dados limpos em tabelas relacionais indexadas no banco de dados autônomo.

Enriquecimento Semântico para IA: Adicionar anotações e comentários nas tabelas Gold. Isso é vital para que o Select AI entenda o contexto (ex: "A coluna TX_AMT refere-se ao valor bruto da transação antes de taxas").

Data Lake Accelerator: Habilitar este recurso para que consultas na Camada Gold possam unir dados do banco com históricos massivos que ainda residem no Object Storage sem perda de performance.

#### 4.4. Governança e Linhagem (Master Catalog)

Registro de Linhagem (Lineage Tracking): Configurar o Master Catalog para documentar todo o caminho do dado: desde o log bruto no bucket Bronze até a tabela de fraude na Camada Gold.

Data Steward Oversight: Atribuir a role de Data Steward para garantir que as transformações sigam as normas de compliance da rede VISA.

Resumo do Checklist de Entrega (Fase 4)

[ ] Notebook Spark configurado para transformar logs ISO 8583 em formato Iceberg/Delta.

[ ] Workflow Visual implementado com ramificação condicional (Scoring de Fraude).

[ ] Camada Gold instanciada no Autonomous 26ai com anotações semânticas.

[ ] Linhagem de Dados mapeada no Master Catalog para auditoria (Compliance VISA).

[ ] Elastic Scaling ativo no Cluster Spark para suportar volumes transacionais globais.

Resultado: Seus dados não são mais apenas "logs"; eles são agora Produtos de Dados Inteligentes. O sistema já decide automaticamente o que é fraude e o que é transação legítima.

---

### Fase 5: Segurança e Guardrails de IA (VISA Compliance)

#### 5.1. Implementação de AI Security Guardrails (OCI Generative AI)

Configuraremos os filtros nativos que interceptam a comunicação entre o usuário e o LLM para garantir que a IA "não fale o que não deve".

Detecção de PII e PAN: Configurar o guardrail de Personally Identifiable Information para identificar e mascarar automaticamente nomes, CPFs e, crucialmente, números de cartões de crédito em prompts e respostas.

Defesa contra Prompt Injection: Ativar o filtro de Prompt Injection Defense com modo Block. Isso atribui um score de risco a cada pergunta do usuário; se o sistema detectar uma tentativa de burlar as regras de fraude da VISA, a requisição é rejeitada instantaneamente.

Moderação de Conteúdo: Habilitar categorias de bloqueio para garantir que o assistente de IA se comporte estritamente como um consultor financeiro, evitando temas não relacionados ao negócio.

#### 5.2. Configuração do Select AI Secure (Database Level)

Aqui, configuramos o banco de dados para validar o SQL gerado pela IA antes de sua execução, protegendo a Camada Gold.

Definição de Translation Profiles: Criar perfis de tradução no DBMS_CLOUD_AI que forcem o LLM a seguir regras específicas de consulta.

Callback Functions para Validação: Implementar uma função de callback em PL/SQL que inspeciona o SQL gerado. Se a IA tentar acessar uma tabela de auditoria restrita ou ignorar um filtro de segurança, a função deve ajustar o SQL ou rejeitar a transação.

Controle de Acesso Dinâmico (VPD/RAS): Garantir que as políticas de Virtual Private Database (VPD) aplicadas às tabelas Gold sejam herdadas pelo Select AI. Se um analista de nível 1 não tem permissão para ver transações acima de $10k via SQL, a IA também não poderá mostrar esses dados a ele.

#### 5.3. Isolamento de Privilégios com Oracle Database Vault

Essencial para impedir que até mesmo os administradores de banco de dados (DBAs) acessem os dados sensíveis que alimentam os modelos de IA.

Criação de Realms de Segurança: Isolar os esquemas da Camada Gold e os Vector Stores dentro de um Vault Realm.

Segregação de Funções: Definir que apenas o processo de automação do Workbench (Task_4) pode inserir dados na Gold, enquanto desenvolvedores só podem acessar dados anonimizados na Sandbox. 

#### 5.4. Auditoria Fina e Rastreabilidade (FGA)

Estabelecer uma trilha de evidências para auditorias regulatórias da rede de cartões.

Configuração de Fine-Grained Auditing (FGA): Monitorar acessos específicos a colunas de risk_score e logs de transações suspeitas.

Auditoria de Conversas de IA: Utilizar a API de conversação do Select AI para persistir cada interação (pergunta do usuário vs. resposta da IA) em logs imutáveis no Object Storage para análise posterior de conformidade.

Resumo do Checklist de Entrega (Fase 5)

[ ] AI Guardrails ativos (PII e Prompt Injection) em modo Block.

[ ] Select AI Profile configurado com funções de callback para validação de SQL.

[ ] Database Vault Realms protegendo os Vector Stores e tabelas Gold. 

[ ] Políticas de VPD propagadas para a interface conversacional da IA.

[ ] Trilha de Auditoria FGA habilitada para monitorar o comportamento dos Agentes de IA.

Resultado: Sua plataforma agora é uma "fortaleza de dados". A IA pode gerar insights poderosos sobre fraudes e transações, mas está tecnicamente impossibilitada de vazar dados críticos ou ser manipulada por usuários mal-intencionados.

--- 

### Fase 6: Sistemas Agênticos de Disputa e Sustentabilidade Financeira (FinOps)

#### 6.1. Orquestração do Ecossistema Agêntico (Pilar: Sistemas Agênticos)

Implementaremos o framework Select AI Agent para criar uma força de trabalho digital capaz de raciocinar sobre as transações da Camada Gold.

Criação de Agentes Especializados:

Ação: Utilizar o procedimento DBMS_CLOUD_AI_AGENT.CREATE_AGENT para instanciar o Agente de Investigação de Fraude (vinculado à Task_5 da imagem) e o Agente de Conciliação de Disputas.

Ação: Definir o atributo role para cada agente (ex: "Você é um especialista em normas PCI e resoluções de chargeback VISA").

Implementação do Protocolo Agent2Agent (A2A):

Ação: Configurar a comunicação entre agentes de diferentes departamentos. Se o Agente de Fraude detectar uma irregularidade, ele deve notificar o Agente de Compliance via protocolo A2A para gerar um relatório regulatório instantâneo.

Ação: Publicar o AgentCard no recurso /.well-known/agent.json para permitir a descoberta automática de capacidades entre os sistemas da rede.

Habilitação do Autonomous AI Database MCP Server:

Ação: Ativar o Model Context Protocol (MCP) para que ferramentas externas (como o Claude Desktop ou aplicações VS Code de desenvolvedores) acessem as ferramentas de banco de dados e RAG nativamente sem código de integração customizado.

Ação: Registrar ferramentas customizadas via DBMS_CLOUD_AI_AGENT.CREATE_TOOL para permitir que a IA execute estornos diretamente no sistema legado da VISA de forma segura.

#### 6.2. Desenvolvimento de Interfaces Conversacionais (Oracle APEX)

Ação: Desenvolver um portal low-code no Oracle APEX para analistas de risco, integrando o APEX AI Application Generator.

Ação: Implementar o assistente de chat que utiliza o perfil de Select AI configurado na Fase 5, permitindo que o analista pergunte em linguagem natural: "Quais transações na Task_5 possuem alta similaridade vetorial com fraudes conhecidas no Japão?". 

#### 6.3. Governança Financeira e Eficiência (Pilar: FinOps na Nuvem)

Garantir que o processamento massivo de IA para a VISA seja financeiramente sustentável.

Implementação de Elastic Pools:

Ação: Agrupar as instâncias de Autonomous AI Database em um Elastic Pool. Isso permite que a VISA compartilhe recursos de CPU/Memória entre o banco de produção e os ambientes de sandbox de IA, reduzindo o TCO total.

Ação: Configurar o auto-scaling para que, durante eventos de alto tráfego (ex: Natal), a capacidade computacional suba instantaneamente e retorne ao mínimo em períodos de baixa para evitar desperdícios.

Configuração do FinOps Hub (Padrão FOCUS):

Ação: Ativar o OCI FinOps Hub e configurar relatórios de custo compatíveis com a especificação FOCUS.

Ação: Criar políticas de Budget (Orçamento) no compartimento Card_Network_Root para enviar alertas em tempo real se o consumo de tokens de LLM exceder o planejado para o trimestre.

Ciclo de Vida de Dados Automatizado (ADO):

Ação: Implementar políticas de Automatic Data Optimization para mover logs de transações com mais de 12 meses da Camada Gold para o Object Storage (Archive Storage), mantendo a integridade para auditorias de conformidade (PCI-DSS) a um custo mínimo. 

Checklist Final de Requisitos ("To Do" - Fase 6)

[ ] Agentes de IA instanciados e papéis (roles) definidos via DBMS_CLOUD_AI_AGENT.

[ ] Ferramentas de Estorno registradas e expostas via MCP Server.

[ ] Protocolo A2A configurado para colaboração entre agentes de Fraude e Compliance.

[ ] Elastic Pool ativado para consolidação de recursos e redução de custos.

[ ] FinOps Hub operacional com visibilidade de custos de IA por unidade de negócio.

[ ] Políticas ADO aplicadas para gestão de custo de armazenamento de longo prazo. 

Resultado Final: Com a conclusão da Fase 6, a rede VISA opera uma plataforma de dados autônoma, onde a ingestão, o refinamento, a segurança e a resolução de problemas são orquestrados por IA, com controle financeiro total e escala global.
