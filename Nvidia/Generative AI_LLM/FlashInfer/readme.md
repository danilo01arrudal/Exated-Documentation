
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

      * Atenção

      Solicitações de inferência modernas chegam com comprimentos de sequência extremamente diferentes, tamanhos de bloco de cache KV, regras de mascaramento e esquemas de codificação posicional. FlashInfer absorve esse dinamismo por:

      - Armazenamento unificado: representando cada layout de cache como uma matriz esparsa de bloco/vetor.
      - Kernels de Template & JIT: uma base de código CUDA/CUTLASS cujos botões de especialização, logits/key/query, agrupados, MLA e variantes futuras.
      - Interface inspetor-executor: uma API amigável ao PyTorch que primeiro inspeciona formas de solicitação e padrões de compartilhamento de prefixos e, em seguida, inicia kernels ajustados por meio de um agendador leve para manter as GPUs saturadas.

      * GEMM e comunicação

      Os blocos LLM ainda dependem muito da multiplicação matricial. Além dos cálculos tradicionais GEMV/GEMM e da comunicação de redução total, 
      avanços recentes, como mistura de especialistas e camadas de LoRA, introduzem novos requisitos, 
      como GEMM agrupado - muitas multiplicações de pequenas matrizes em uma única chamada - e comunicação all-to-all. 
      O FlashInfer seleciona os kernels de código aberto ou NVIDIA mais rápidos (incluindo caminhos tensor-core fp4 / fp8) e os apresenta atrás de uma API consistente, 
      para que a pilha de serviço possa trocar GPUs ou kernels sem tocar na lógica do aplicativo.

      * Amostragem de token

      Gerar o próximo token geralmente gargalos a filtragem Top-K/Top-P. As implementações tradicionais classificam todo o vocabulário, 
      o que é um trabalho de desperdício quando apenas um punhado de logits importa. 
      O FlashInfer substitui as classificações globais por um amostrador baseado em rejeição e sem classificação que poda tokens improváveis em tempo real, 
      reduzindo a latência em grandes vocabulários e permanecendo numericamente fiel.

      * Inferência à prova de futuro

      Com essas camadas no lugar, as estruturas de serviço podem alterar os layouts do KV-cache, introduzir novos designs de atenção, 
      lotes de comprimentos arbitrários ou perseguir metas de latência mais rígidas sem reescrever kernels ou voltar para a CPU. 
      Desde a primeira consulta até o token final, o FlashInfer mantém o caminho de inferência crítica na GPU—flexível, à prova de futuro e rápido.

      Usando FlashInfer

      O pacote Flashinfer está disponível no PyPI. Você pode experimentar com:

      pip install flashinfer-python

      O FlashInfer tem APIs nativas do Torch com o design de plan/run para dissociar a compilação/seleção/ajuste do kernel e a execução do kernel. Para atenção, a API se parece com:

      from flashinfer.attention import BatchAttention
      attention = BatchAttention(backend="cutlass") # we provide multiple backend implementations
      attention.plan(
        qo_offsets, # offsets of each request in variable length query/output
        kv_lens, # kv length of each request in page table
        kv_block_table, # block table denoting the block indices in page table, could be packed/padded
        num_qo_heads, # number of query/output heads
        num_kv_heads, # number of key/value heads
        head_dim_qk, # head dimension of query/key
        head_dim_vo, # head dimension of value/output
        dtype_q=torch.bfloat16, # query data type
        dtype_kv=torch.bfloat16, # kv data type
        dtype_o=torch.bfloat16, # output data type
        **variant_kwargs, # other arguments specifying attention variants
      )
      O, lse = attention.run(q, (k, v)) # return output/lse

      A seleção e o ajuste do kernel são realizados no estágio do plan, que reúne os metadados necessários para o kernel. 
      As mesmas informações do plano podem ser reutilizadas para execuções posteriores que compartilham os mesmos metadados (todas as camadas em uma etapa de geração de LLM).

      Os usuários podem escolher entre vários back-ends de atenção para obter o melhor desempenho para seu caso de uso. 
      Todos os kernels são seguros para CUDAGraph, permitindo o serviço de inferência LLM de baixa latência.

      Para o processamento de logits, uma interface modular compõe diferentes processadores de logits juntos, 
      e flashinfer emite uma implementação eficiente baseada em amostragem de rejeição fundida. 
      Nossa recente postagem no blog explica como funciona o algoritmo de amostragem de rejeição flashinfer.

      import flashinfer
      from flashinfer.logits_processor import LogitsPipe, Temperature, Softmax, TopP, Sample
 
      # Create a pipeline
      pipe = LogitsPipe([
          Temperature(),      # Scale logits by temperature
          Softmax(),          # Convert logits to probabilities
          TopP(),             # Apply top-p filtering
          Sample()            # Sample from the distribution
      ])
 
      # Apply the pipeline
      logits = torch.randn(batch_size, vocab_size, device="cuda")
      output_ids = pipe(logits, temperature=0.7, top_p=0.9)

      Para começar a usar o FlashInfer, consulte o repositório e a documentação do GitHub.
      




