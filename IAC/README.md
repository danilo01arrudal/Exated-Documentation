# Infraestrutura como código

![Texto Alternativo](https://www.redhat.com/themes/custom/rhdc/img/red-hat-social-share.jpg)

### Conceito

Infraestrutura como código (IaC) refere-se ao gerenciamento e provisionamento da infraestrutura por meio de códigos, em vez de processos manuais. 
A sigla vem do termo em inglês, "Infrastructure as Code".

Nesta abordagem, arquivos de configuração que incluem as especificações da sua infraestrutura são criados, facilitando a edição e a distribuição das suas configurações. 
A IaC também assegura o provisionamento do mesmo ambiente, todas as vezes. Ao codificar e documentar as especificações de configuração, 
a IaC auxilia no gerenciamento de configuração e ajuda a evitar alterações de configuração ad-hoc não documentadas.

O controle de versão é uma parte importante da IaC. Os arquivos de configuração devem pertencer à fonte como qualquer outro código-fonte de software. 
Ao implantar a infraestrutura como código, também é possível separá-la em módulos, que podem ser combinados de diferentes maneiras por meio da automação.
Ao automatizar o provisionamento da infraestrutura com a IaC, os desenvolvedores não precisam provisionar e gerenciar manualmente servidores, 
sistemas operacionais, armazenamento e outros componentes de infraestrutura sempre que criam ou implantam uma aplicação.

A codificação da infraestrutura oferece um template de provisionamento para você seguir. 
Ainda que esse processo possa ser feito manualmente, há ferramentas de automação, como o Red Hat® Ansible® Automation Platform, capazes de cuidar disso para você. 

### IaC declarativa e IaC imperativa

Há dois tipos de abordagem de IaC: declarativa e imperativa. 

A abordagem declarativa define o estado desejado do sistema, incluindo os recursos necessários, as propriedades que eles precisam ter e uma ferramenta de IaC para configurá-lo. 
Essa abordagem também mantém uma lista do estado atual dos objetos do seu sistema, simplificando o gerenciamento da desativação da infraestrutura.

Por outro lado, a abordagem imperativa define os comandos específicos necessários para alcançar a configuração desejada. Depois, esses comandos precisam ser executados na ordem correta. 
Muitas das ferramentas de IaC que usam uma abordagem declarativa provisionam automaticamente a infraestrutura desejada. Se você alterar o estado desejado, uma ferramenta de IaC declarativa aplicará as alterações para você. Uma ferramenta imperativa exige que você saiba como as alterações deverão ser aplicadas.

As ferramentas de IaC, geralmente, funcionam nas duas abordagens, mas costumam preferir uma delas.

### Benefícios

O provisionamento de infraestrutura sempre foi um processo manual, caro e demorado. 
Agora, o gerenciamento de infraestrutura migrou do hardware físico em datacenters (ainda que eles ainda sejam um componente da sua organização) para virtualização, containers e cloud computing. 

Com a cloud computing, o número de componentes de infraestrutura aumentou, mais aplicações são colocadas em produção diariamente e as infraestruturas precisam ser flexíveis para as frequentes alterações, escalas e desativações. Hoje em dia, sem a implementação de uma prática de IaC, fica cada vez mais difícil gerenciar a escala da infraestrutura.

A IaC pode ajudar sua organização a gerenciar as necessidades de infraestrutura de TI, melhorando a consistência e reduzindo erros e a necessidade de configuração manual.

    Benefícios:

        * Redução de custos
        * Aumento na velocidade das implantações
        * Redução de erros 
        * Melhoria na consistência da infraestrutura
        * Eliminação de desvios de configuração

### Ferramentas

As ferramentas de gerenciamento de configuração e automação do servidor em geral podem ser usadas para alcançar a IaC. Há também soluções específicas para IaC. 

    Estas são algumas escolhas bastante conhecidas:

        * Chef
        * Puppet
        * Red Hat Ansible Automation Platform
        * Saltstack
        * Terraform 
        * AWS CloudFormation

O Ansible Automation Platform pode ser usado para provisionar sistemas operacionais e dispositivos de rede, implantar aplicações e gerenciar configurações.

### Importância para as práticas de DevOps

A IaC é uma parte importante da implementação de práticas de DevOps e de integração e entrega contínuas (CI/CD). 
Ela elimina a maioria do trabalho de provisionamento realizado pelos desenvolvedores. Assim, eles podem executar um script para preparar a infraestrutura.  
Dessa forma, as implantações de aplicações não ficam aguardando pela infraestrutura e os administradores do sistema não gerenciam processos manuais demorados. 
A prática de CI/CD conta com monitoramento e automação contínuos durante o ciclo de vida da aplicação, desde a integração e o teste até a entrega e a implantação. 
Para automatizar o ambiente, é necessário ter consistência. A automação de implantações de aplicações não funciona quando as equipes de desenvolvimento e de operações implantam aplicações ou configuram ambientes de maneira diferente.

O alinhamento das equipes de desenvolvimento e de operações usando uma abordagem de DevOps gera menos erros, implantações manuais e inconsistências. 
A IaC ajuda a alinhar as equipes de desenvolvimento e de operações porque ambas podem usar a mesma descrição da implantação de aplicações, compatível com a abordagem de DevOps.
É necessário usar o mesmo processo de implantação em todos os ambientes, incluindo o de produção. A IaC gera o mesmo toda vez que é usada.
Ela também elimina a necessidade de manter ambientes de implantação individuais com configurações exclusivas que não podem ser reproduzidas automaticamente e garante a consistência do ambiente de produção.

As práticas recomendadas de DevOps também são aplicadas à infraestrutura na IaC. A infraestrutura pode passar pelo mesmo pipeline de CI/CD usado pelas aplicações durante o desenvolvimento de software, ou seja, aplicando os mesmos testes e controle de versão ao código da infraestrutura.

### Por que escolher a Red Hat para a automação?

Ao adotar essa abordagem por toda a empresa, você automatiza não apenas os processos de TI, mas também tecnologias, equipes e organizações. 

O Red Hat® Ansible® Automation Platform oferece todas as ferramentas necessárias para implementar a automação em toda a empresa, incluindo playbooks, solução orientada a eventos, um painel gráfico e análises de dados. O Ansible Automation Platform também usa webhooks para automatizar fluxos de trabalho de IaC e oferecer práticas GitOps.

Os Ansible playbooks são escritos em YAML e descrevem o estado desejado dos sistemas, geralmente mantidos no controle de origem. O Ansible Automation Platform coloca seus sistemas no estado desejado, seja qual for o estado atual deles. 

Com o Ansible Automation Platform, suas instalações, upgrades e tarefas diárias de gerenciamento se tornam reproduzíveis e confiáveis.
Com a solução de automação adequada, você pode acelerar a implantação de novas aplicações e serviços, gerenciar a infraestrutura de TI com mais eficiência e aumentar a produtividade do desenvolvimento de aplicações.







