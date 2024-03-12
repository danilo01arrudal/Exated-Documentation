# Site Reliability Engineering: o que é SRE?

![Texto Alternativo](https://www.redhat.com/rhdc/managed-files/RH_BRAND_7764_01_MECH_Open%20Hybrid%20Cloud_Full%20Color_Grey_0.png)

## O que é engenharia de confiabilidade de sites?

Site Reliability Engineering (SRE) ou engenharia de confiabilidade de sites é uma abordagem da engenharia de software para gerenciar sistemas e automatizar tarefas operacionais de TI. 
Equipes de SRE usam softwares como ferramentas para gerenciar sistemas, solucionar problemas e automatizar tarefas operacionais.

Na abordagem de SRE, as tarefas que historicamente eram realizadas pelas equipes de operações, muitas vezes manualmente, são delegadas a engenheiros ou equipes de operações que usam software e automação para solucionar problemas e gerenciar sistemas de produção. 
A prática de SRE é muito útil, sobretudo na criação de sistemas de software escaláveis e altamente confiáveis. Ela ajuda a gerenciar sistemas extensos por meio do código, o que é mais escalável e viável para administradores de sistemas que administram centenas ou milhares de máquinas. 
O conceito de engenharia de confiabilidade de sites foi criado pela equipe de engenharia do Google e é atribuído a Ben Treynor Sloss. 

A abordagem SRE ajuda as equipes a encontrar um equilíbrio entre lançar novas funcionalidades e assegurar que elas sejam confiáveis para os usuários.
Padronização e automação são dois componentes importantes do modelo de SRE. Engenheiros de confiabilidade de sites buscam sempre uma maneira de aprimorar e automatizar as tarefas operacionais.
Dessa forma, a SRE ajuda a melhorar a confiabilidade do sistema hoje e à medida que cresce ao longo do tempo. 
As práticas de SRE facilitam o trabalho das equipes que estão migrando as operações de TI da abordagem mais tradicional para uma abordagem nativa em nuvem.

## Funções do engenheiro de confiabilidade de sites

A função do engenheiro de confiabilidade de sites é singular e requer experiência com administração de sistemas (sysadmin), desenvolvimento de software com uma base adicional em operações ou alguém em uma função de operações de TI que também tenha habilidades de desenvolvimento de software. 
As equipes de SRE são responsáveis pela maneira como o código é implantado, configurado e monitorado, bem como pela disponibilidade, latência, gerenciamento de mudanças, resposta a emergências e gerenciamento de capacidade dos serviços em produção.
As equipes de SRE determinam o lançamento de novas funcionalidades usando acordos de nível de serviço (SLAs) para definir a confiabilidade obrigatória do sistema por meio de indicadores de nível de serviço (SLI) e objetivos de nível de serviço (SLO). 

O SLI mede aspectos específicos dos níveis de serviços oferecidos. Os principais indicadores incluem latência de solicitação, disponibilidade, taxa de erro e capacidade do sistema. O SLO é baseado no intervalo ou valor desejado para um nível de serviço com base no SLI.
Um SLO para a confiabilidade exigida do sistema é então baseado no downtime determinado como aceitável. Esse nível de downtime é chamado de "orçamento de erro", o limite máximo permitido para erros e interrupções. 
Na abordagem de SRE, não se espera que haja 100% de confiabilidade, mas as falhas são planejadas e esperadas.
Uma vez já estabelecida, a equipe de desenvolvimento pode "gastar" o orçamento de erro ao lançar uma funcionalidade nova. Com base no SLO e no orçamento de erro disponível, a equipe determina se é viável ou não lançar uma certa solução, ou serviço.

Se um serviço em execução está dentro desse orçamento, então, a equipe de desenvolvimento pode lançar esse serviço quando desejar. No entanto, se o sistema apresentar muitos erros ou permanecer inativo por um tempo maior do que o permitido pelo orçamento de erro, nenhum lançamento novo deverá ser realizado até que as falhas estejam no parâmetro.   
A equipe de desenvolvimento conduz testes automatizados nas operações para demonstrar a confiabilidade. 
Os engenheiros de confiabilidade de sites dividem seu tempo entre a execução de tarefas operacionais e o trabalho em projetos. Conforme as práticas recomendadas pelo Google para SRE, os engenheiros de confiabilidade de sites só podem passar no máximo 50% do tempo trabalhando nas operações, o que deve ser monitorado para assegurar que essa porcentagem não seja ultrapassada.  

O restante do tempo é gasto em tarefas de desenvolvimento, como criação de funcionalidades novas, escalonamento do sistema e implementação da automação.
O excesso de trabalho operacional e o baixo desempenho dos serviços podem ser redirecionados para que a equipe de desenvolvimento solucione esses problemas. Assim, o engenheiro de confiabilidade de sites não passa tanto tempo nas operações de uma aplicação ou um serviço. 
A automação é uma parte importante da função do engenheiro de confiabilidade de sites. Se eles estiverem enfrentando um problema que se repete, então devem criar uma solução automatizada. 

Manter o equilíbrio entre o trabalho operacional e de desenvolvimento é essencial na abordagem de SRE. 

## DevOps e SRE: principais diferenças

A metodologia DevOps é uma abordagem de cultura, automação e design de plataforma, cujo objetivo é agregar mais valor aos negócios e aumentar a capacidade de resposta às mudanças por meio de entregas de serviços rápidas e de alta qualidade. A SRE pode ser considerada uma forma de implementar a metodologia DevOps.

Assim como o DevOps, a SRE tem como foco a cultura e os relacionamentos. Ambas as abordagens visam aproximar as equipes de operações e desenvolvimento para acelerar a entrega de serviços. 
Ciclos de desenvolvimento mais rápidos, melhor qualidade de serviço, maior confiabilidade e redução no tempo gasto pela TI em cada aplicação desenvolvida são alguns dos possíveis benefícios alcançáveis com as práticas de DevOps e SRE.

No entanto, a SRE é diferente do DevOps porque depende dos engenheiros de confiabilidade de sites da equipe de desenvolvimento que também têm experiência em operações de TI para eliminar problemas de comunicação e fluxo de trabalho.

A função do engenheiro de confiabilidade de sites combina as habilidades das equipes de desenvolvimento com as de operações porque tem responsabilidades que abrangem ambas as áreas. 
Um engenheiro de confiabilidade pode auxiliar as equipes de DevOps cujos desenvolvedores estão sobrecarregados com as tarefas operacionais e precisam de alguém com habilidades mais especializadas nessa área. 
Ao codificar e criar novas funcionalidades, o DevOps se concentra em percorrer o pipeline de desenvolvimento eficientemente. Já a abordagem de SRE se concentra no equilíbrio entre os esforços de manter a confiabilidade de sites e a criação de novas funcionalidades. 
As plataformas de aplicações modernas baseadas em tecnologia de containers, Kubernetes e microsserviços são essenciais para as práticas de DevOps por ajudarem a entregar segurança e inovação nos serviços de software.


