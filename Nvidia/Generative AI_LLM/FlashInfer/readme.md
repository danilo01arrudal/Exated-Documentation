
      FlashInfer é uma biblioteca personalizável e eficiente para construir motores de serviço LLM eficientes. 
      Otimizando o armazenamento em cache KV usando formatos de espaço de bloco e componíveis para melhorar o acesso à memória e reduzir a redundância, 
      ele possui um modelo de atenção personalizável que se adapta a várias configurações por meio da compilação just-in-time (JIT). 
      Seu algoritmo de agendamento balanceado de carga se ajusta às solicitações dinâmicas do usuário enquanto permanece compatível com a configuração estática do NVIDIA CUDA Graph. 
      O FlashInfer é integrado às principais estruturas de atendimento LLM, como MLC Engine, SGLang e vLLM, bem como vários mecanismos personalizados.

      A NVIDIA agora está lançando ativamente seus kernels de inferência LLM de melhor desempenho no FlashInfer, 
      incluindo os da NVIDIA TensorRT-LLM, para fácil integração em vLLM, SGLang e mecanismos de inferência personalizados.

      Visão geral da arquitetura do FlashInfer
      Como uma pilha de operadores de GPU NVIDIA construída especificamente para servir LLM, o FlashInfer visa velocidade e velocidade do desenvolvedor para os kernels mais recentes. 
      As plataformas de inferência podem adotar novas ideias sem esperar por novas bibliotecas ou reescrever kernels no CUDA C++. 
      Esses kernels estarão disponíveis para todas as estruturas por meio de uma API DLPack, bem como registrados como operadores PyTorch para fácil integração em muitos mecanismos de inferência. 
      O recurso JIT permite que os usuários materializem os kernels usados pelo modelo de destino, o que significa que o FlashInfer também tem uma pegada mínima como dependência.

      O FlashInfer divide as cargas de trabalho LLM em quatro famílias de operadores - Atenção, GEMM, Comunicação e Amostragem - e expõe 
      cada família por meio de coletivos leves e de alto desempenho que caem em qualquer mecanismo de serviço com alterações mínimas de código.

