## Visão geral do laboratório

A loja virtual da Example Corp. apresenta um alto índice de abandono de carrinho diariamente, o que leva à exclusão desses registros do banco de dados para liberar espaço de armazenamento. Como especialista em Engenharia de Dados da empresa, você é responsável por encontrar uma solução de armazenamento de baixo custo na AWS para armazenar esses registros e permitir que a loja virtual realize processamento analítico diretamente nessa solução de armazenamento.

Neste laboratório, você explorará os componentes de um data lake, organizará seus dados em camadas (ou zonas) e usará o Amazon S3 como camada de armazenamento do seu data lake.

### Objetivos
Ao final deste laboratório, você deverá ser capaz de fazer o seguinte:

Utilize o Amazon S3 como camada de armazenamento de um data lake.
Organize os dados em camadas (ou zonas) no Amazon S3.
Configure uma notificação de evento do S3 para invocar uma função do AWS Lambda.
Crie uma regra do Amazon EventBridge para invocar a função Lambda.

### Pré-requisitos de conhecimento técnico
Este laboratório requer os seguintes pré-requisitos:

Acesso a um computador com Microsoft Windows, Mac OS X ou Linux (Ubuntu, SuSE ou Red Hat)
Um navegador de internet moderno, como o Chrome ou o Firefox.
Conhecimento básico de nuvem e serviços da AWS.

### Legenda
Ao longo deste laboratório, são utilizados diversos ícones para chamar a atenção para diferentes tipos de instruções e anotações. A lista a seguir explica a finalidade de cada ícone:

* **Resultado esperado**: Um exemplo de resultado que você pode usar para verificar a saída de um comando ou arquivo editado.
* **Nota**: Uma dica, sugestão ou orientação importante.
* **Saiba mais**: Onde encontrar mais informações.
* **Conteúdo do arquivo**: Um bloco de código que exibe o conteúdo de um script ou arquivo que você precisa executar, o qual foi previamente criado para você.
* **Atualizar**: Momento em que você pode precisar atualizar a página ou lista de um navegador da web para exibir novas informações.
* **Copiar e editar**: Uma situação em que copiar um comando, script ou outro texto para um editor de texto (para editar variáveis ​​específicas dentro dele) pode ser mais fácil do que editar diretamente na linha de comando ou no terminal.
* **Tarefa concluída**: Um ponto de conclusão ou resumo do experimento.

### Iniciar laboratório
1. Para iniciar o laboratório, na parte superior da página, selecione Iniciar Laboratório .

 Atenção: você deve aguardar até que os serviços da AWS provisionados estejam prontos antes de prosseguir.

2. Para abrir o laboratório, selecione Abrir Console.

Você será conectado automaticamente ao Console de Gerenciamento da AWS em uma nova aba do navegador.

 Aviso: Não altere a região a menos que seja instruído a fazê-lo.

### Erros comuns de login
Erro: Selecionar Iniciar Laboratório não tem efeito.
Em alguns casos, certas extensões de navegador que bloqueiam pop-ups ou scripts podem impedir que o botão " Iniciar Laboratório" funcione corretamente. Se você tiver problemas para iniciar o laboratório:

Adicione o domínio do laboratório à lista de permissões do seu bloqueador de pop-ups ou scripts, ou desative-o.
Atualize a página e tente novamente.

### Ambiente de laboratório
O diagrama a seguir mostra a arquitetura básica do ambiente de laboratório:

![lab_diagram](https://github.com/danilo01arrudal/Exated-Documentation/blob/main/AWS/Data%20Engineering/images/0001.png)

Descrição da imagem: O diagrama anterior demonstra uma arquitetura simplificada de um data lake. Ele contém uma camada para dados brutos (zona de dados brutos), uma camada para dados consumíveis (zona de consumo) e três aplicações distintas que ingerem, processam e consomem os dados.

A lista a seguir detalha os principais recursos no diagrama:

* Esta solução demonstra uma arquitetura simplificada de data lake. Ela contém uma camada para dados brutos (zona de dados brutos), uma camada para dados consumíveis (zona de consumo) e três aplicações distintas que ingerem, processam e consomem os dados.
* A aplicação de backend de comércio eletrônico é uma função AWS Lambda que ingere dados no bucket da zona raw do Amazon S3.
Após a ingestão dos dados brutos no data lake, a camada de processamento está pronta para iniciar a transformação dos dados e enviá-los para o bucket S3 da zona de consumo. Este bucket contém os dados transformados, prontos para serem consumidos.
* Um data lake normalmente possui pelo menos três camadas (ou zonas) de dados: brutos, de preparação e de consumo. Esses nomes podem variar, e você também pode adicionar camadas adicionais de acordo com suas necessidades.
* Quando os dados estão prontos para serem utilizados, o aplicativo de promoções acessa os dados diretamente no data lake e os agrega para fornecer dados de abandono para cada cliente. Esses dados podem ser usados ​​para identificar quais descontos de produtos enviar aos clientes.

### Serviços utilizados neste laboratório
**AWS Lambda**
O AWS Lambda é um serviço de computação que permite executar código sem provisionar ou gerenciar servidores. O Lambda executa seu código em uma infraestrutura de computação de alta disponibilidade e realiza toda a administração dos recursos de computação, incluindo manutenção de servidores e sistemas operacionais, provisionamento de capacidade e escalonamento automático, além de registro de logs. Com o Lambda, tudo o que você precisa fazer é fornecer seu código em um dos ambientes de execução de linguagem compatíveis com o Lambda.

 Saiba mais: Consulte " O que é AWS Lambda?" na seção Recursos adicionais para obter mais informações.

**Amazon Simple Storage Service (Amazon S3)**
O Amazon Simple Storage Service (Amazon S3) é um serviço de armazenamento de objetos que oferece escalabilidade, disponibilidade de dados, segurança e desempenho líderes do setor. Clientes de todos os portes e segmentos podem usar o Amazon S3 para armazenar e proteger qualquer quantidade de dados para uma variedade de casos de uso, como data lakes, sites, aplicativos móveis, backup e restauração, arquivamento, aplicativos corporativos, dispositivos IoT e análise de big data. O Amazon S3 oferece recursos de gerenciamento para que você possa otimizar, organizar e configurar o acesso aos seus dados para atender às suas necessidades específicas de negócios, organização e conformidade.

 Saiba mais: Consulte " O que é o Amazon S3?" na seção Recursos adicionais para obter mais informações.

### Serviços da AWS não utilizados neste laboratório
As funcionalidades dos serviços da AWS utilizadas neste laboratório estão limitadas ao que o laboratório exige. Podem ocorrer erros ao acessar outros serviços ou executar ações além das descritas neste guia do laboratório.

---

#### Tarefa 1: Analisar os buckets S3 para a zona de dados brutos e a zona de consumo.

Nesta tarefa, você revisará os buckets do S3 que foram pré-criados para este laboratório.

3. Na parte superior do Console de Gerenciamento da AWS, na barra de pesquisa, procure e selecioneS3.
Na seção **Buckets de uso geral** , você deverá ver os dois buckets a seguir, que já foram criados para este laboratório:

* O primeiro bucket, cujo nome começa com **raw-bucket**, é usado como uma camada para dados brutos (zona raw).
* O segundo bucket, cujo nome começa com **consume-bucket**, é usado como uma camada para dados consumíveis (zona de consumo).
A zona (ou camada) de dados brutos contém os dados ingeridos das fontes de dados no formato de dados brutos, que é a cópia imutável dos dados. Essa zona pode incluir objetos de dados estruturados, semiestruturados e não estruturados, como bancos de dados, backups, arquivos, imagens e arquivos (JSON, CSV, XML, texto etc.).

Após obter os dados brutos, você deseja transformá-los. As transformações podem envolver a agregação de dados de diferentes fontes ou a alteração do formato do arquivo dos dados recebidos. Neste laboratório, o bucket S3 da zona de consumo representa a camada transformada.

 Tarefa concluída: Você revisou com sucesso os buckets do S3 para a zona de dados brutos e a zona de consumo que foram pré-criados para este laboratório.

 ---

#### Tarefa 2: Criar notificação de evento no S3 e enviar eventos para o Amazon EventBridge.
Nesta tarefa, você criará uma notificação de evento do S3 para o bucket da zona raw. Você usará o recurso de Notificações de Eventos do Amazon S3 para receber notificações quando determinados eventos ocorrerem no seu bucket do S3. Posteriormente, você também enviará esses eventos para o Amazon EventBridge.

---

#### Tarefa 2.1: Criar notificação de evento S3
4. Na seção **Buckets de uso geral** , escolha o bucket S3 da zona raw (bucket que começa com o nome **raw-bucket** ).

5. Na página do bucket da zona bruta, selecione a guia **Propriedades** .

6. Desça até a seção **Notificações de eventos** e selecione **Criar notificação de evento** .

7. Na página **Criar notificação de evento** , na seção **Configuração geral** , configure o seguinte:

* No campo **Nome do evento** , insira **Evento do processador**.
8. Na seção **Tipos de evento** , para **Criação de objeto** , escolha **Inserir** .

9. Desça até a seção **Destino** e configure o seguinte:

* Em **Destino** , escolha **Função Lambda**, caso ainda não esteja selecionada.
* Em **Especificar função Lambda** , escolha **Escolher uma das suas funções Lambda**, caso ainda não esteja selecionada.
* Para a **função Lambda** , use o menu suspenso e escolha **labFunction-Data-Processor** .

Neste caso, a função Lambda **labFunction-Data-Processor** é selecionada como o destino para onde você deseja que o Amazon S3 envie as notificações. Você armazena essa configuração no sub-recurso de notificação associado a um bucket.

10. Selecione **Salvar alterações** .

É exibido um banner com a mensagem. **Notificação de evento "Evento do Processador" criada com sucesso. Operação concluída com êxito.**

#### Tarefa 2.2: Enviar eventos para o Amazon EventBridge
O Amazon S3 pode enviar eventos para o Amazon EventBridge sempre que determinados eventos ocorrerem no seu bucket. Ao contrário de outros destinos, você não precisa selecionar quais tipos de eventos deseja enviar.

11. Desça até a seção **Notificações de eventos** e, para **Amazon EventBridge** , escolha Editar .

12. Na página **Editar Amazon EventBridge** , em **Enviar notificações para o Amazon EventBridge para todos os eventos neste bucket** , selecione **Ativado** .

Selecione **Salvar alterações** .

É exibido um banner com a mensagem. **Notificações de eventos editadas com sucesso. Operação concluída com êxito.**

**Tarefa concluída**: você criou com êxito uma notificação de evento S3 para o bucket da zona raw e habilitou a opção de enviar eventos para o Amazon EventBridge.

---

#### Tarefa 3: Analise a camada de ingestão da sua solução de data lake.
Nesta tarefa, você revisará a camada de ingestão da sua solução de data lake. A função Lambda labFunction-Data-Generator atua como o aplicativo de backend de e-commerce que ingere dados no bucket da zona raw do Amazon S3.

#### Tarefa 3.1: Configurar e testar a função Lambda labFunction-Data-Generator
14. Na parte superior do Console de Gerenciamento da AWS, na barra de pesquisa, procure e selecione **Lambda**.

15. Na seção **Funções** , escolha a função **labFunction-Data-Generator**.

16. Desça até a aba **Código**.

17. **Conteúdo do arquivo**: Na janela **index.py** , revise o código da função **labFunction-Data-Generator**.

**Observação**: Esta função cria dados aleatórios de abandono de carrinho de compras usando o pacote Faker do Python.

**Saiba mais**: Faker é um pacote Python que gera dados falsos para você. Consulte a seção " Bem-vindo à documentação do Faker!" na seção **Recursos adicionais** para obter mais informações.

18. Selecione a aba **Configuração**.

19. Na guia **Configuração** , selecione **Variáveis ​​de ambiente**.

20. Na seção **Variáveis ​​de ambiente**, escolha **Editar**.

21. Na seção **Variáveis ​​de ambiente**, para a chave **input_bucket**, em **Valor**, substitua o texto genérico REPLACE_WITH_INPUT_BUCKET pelo valor de **RawBucketName** fornecido à esquerda destas instruções.

22. Selecione **Salvar**.

É exibido um banner com a mensagem. **A função labFunction-Data-Generator foi atualizada com sucesso.**

23. Selecione a aba **Teste** .

24. No campo **Nome do evento** , insira **Evento de teste**.

25. Selecione **Salvar**.

É exibido um banner com a mensagem. **O evento de teste “TestEvent” foi salvo com sucesso**.

26. Para executar o evento de teste, selecione **Testar**.

27. Quando o teste terminar de ser executado, em **"Executando função: concluída com sucesso"** , selecione **"Detalhes"** para visualizar a saída.

**Resultado esperado**: As cinco primeiras linhas de dados do carrinho de compras, criadas por esta função, devem ser exibidas.

    ************************
    **** EXAMPLE OUTPUT ****
    ************************

    START RequestId: 85ed1153-2c0e-4464-b15e-bfb7fc9bd027 Version: $LATEST
    cart_id  customer_id  product_id  product_amount product_price
    0       10            3           5              15         $9.47
    1        5            0           6              13    $17,048.51
    2        0            8          10               9         $5.09
    3       10            2           2               1        $25.84
    4        0            5           8               9       $690.31
    END RequestId: 85ed1153-2c0e-4464-b15e-bfb7fc9bd027
    REPORT RequestId: 85ed1153-2c0e-4464-b15e-bfb7fc9bd027	Duration: 4266.55 ms	Billed Duration: 4267 ms	Memory Size: 128 MB	Max Memory Used: 124 MB	Init Duration: 1938.82 ms

    Request ID: 85ed1153-2c0e-4464-b15e-bfb7fc9bd027

Tarefa 3.2: Analisar os dados no bucket S3 da zona bruta
Na parte superior do Console de Gerenciamento da AWS, na barra de pesquisa, procure e selecioneS3.

Na seção Buckets de uso geral , escolha o bucket S3 da zona raw (bucket que começa com o nome raw-bucket- ).

Na aba Objetos , marque a caixa de seleção para selecionar o arquivo cart_abandonment_data.csv .

 Atualizar: Se o arquivo .csv não for exibido, selecione o ícone de atualização.

Selecione "Download" e salve o arquivo cart_abandonment_data.csv no seu dispositivo.

No seu dispositivo, abra o arquivo cart_abandonment_data.csv usando um editor de sua preferência.

 Resultado esperado: Observe que as primeiras entradas correspondem ao que foi exibido na saída do evento de teste da função labFunction-Data-Generator .

 Tarefa concluída: Você revisou com sucesso a camada de ingestão da sua solução de data lake.

Tarefa 4: Analise a camada de processamento da sua solução de data lake.
Nesta tarefa, você revisará a camada de processamento da sua solução de data lake. Após a ingestão dos dados brutos no data lake, a camada de processamento estará pronta para iniciar a transformação dos dados e enviá-los para o bucket S3 da zona de consumo. A função Lambda `labFunction-Data-Processor` atua como a aplicação que transforma os dados e os envia para o bucket S3 da zona de consumo.

Tarefa 4.1: Configurar a função Lambda labFunction-Data-Processor
Na parte superior do Console de Gerenciamento da AWS, na barra de pesquisa, procure e selecioneLambda.

Na seção Funções , selecione a função labFunction-Data-Processor .

Na seção Visão geral da função , verifique se o S3 está listado como o gatilho da função.

 Observação: esse gatilho foi adicionado quando você configurou as notificações de eventos no bucket S3 da zona raw.

Desça até a aba Código .

 Conteúdo do arquivo: Na janela index.py , revise o código da função labFunction-Data-Processor .

 Observação: Esta função agrega os dados de abandono de carrinho de compras e os classifica por ID do produto, utilizando a biblioteca de análise de dados pandas do Python.

 Saiba mais: Pandas é uma ferramenta de análise e manipulação de dados de código aberto, rápida, poderosa e flexível, construída sobre a linguagem de programação Python. Consulte a seção Recursos adicionais para obter mais informações sobre o pandas .

Selecione a aba Configuração .

Na guia Configuração , selecione Variáveis ​​de ambiente .

Na seção Variáveis ​​de ambiente , escolha Editar .

Na seção Variáveis ​​de ambiente :

Na chave input_bucket , em Valor , substitua o texto genérico REPLACE_WITH_INPUT_BUCKET pelo valor de RawBucketName fornecido à esquerda destas instruções.
Na chave output_bucket , em Valor , substitua o texto genérico REPLACE_WITH_OUTPUT_BUCKET pelo valor de ConsumeBucketName fornecido à esquerda destas instruções.
Selecione Salvar .

É exibido um banner com a mensagem.A função labFunction-Data-Processor foi atualizada com sucesso.

No menu de navegação superior, escolha Funções .

Na seção Funções , escolha a função labFunction-Data-Generator .

Desça até a aba Código .

Para executar o evento de teste uma segunda vez, escolha Testar (Ctrl+Shift+I) .

Resultado esperado:

    ************************
    **** EXAMPLE OUTPUT ****
    ************************

    Status: Succeeded
    Test Event Name: TestEvent

    Response:
    null

    The area below shows the last 4 KB of the execution log.

    Function Logs:
    START RequestId: b6cfd7bf-8e13-4ac6-bc29-739cf4dcca8f Version: $LATEST
    cart_id  customer_id  product_id  product_amount product_price
    0       10            1           9               4     $8,295.85
    1        8            3          10              17     $3,482.04
    2       10            3           7              18       $788.59
    3        4            6           9               6     $2,936.20
    4        6            2           3               4         $9.76
    END RequestId: b6cfd7bf-8e13-4ac6-bc29-739cf4dcca8f
    REPORT RequestId: b6cfd7bf-8e13-4ac6-bc29-739cf4dcca8f	Duration: 1305.71 ms	Billed Duration: 1306 ms	Memory Size: 128 MB	Max Memory Used: 128 MB	Init Duration: 1938.82 ms

    Request ID: b6cfd7bf-8e13-4ac6-bc29-739cf4dcca8f














 
