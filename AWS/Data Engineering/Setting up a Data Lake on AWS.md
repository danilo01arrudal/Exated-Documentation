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
Para iniciar o laboratório, na parte superior da página, selecione Iniciar Laboratório .

 Atenção: você deve aguardar até que os serviços da AWS provisionados estejam prontos antes de prosseguir.

Para abrir o laboratório, selecione Abrir Console.

Você será conectado automaticamente ao Console de Gerenciamento da AWS em uma nova aba do navegador.

 Aviso: Não altere a região a menos que seja instruído a fazê-lo.


[lab_diagram](https://github.com/danilo01arrudal/Exated-Documentation/blob/main/AWS/Data%20Engineering/images/0001.png)






















 
