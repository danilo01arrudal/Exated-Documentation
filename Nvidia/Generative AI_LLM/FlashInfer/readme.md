
FlashInfer é uma biblioteca personalizável e eficiente para construir motores de serviço LLM eficientes. 
Otimizando o armazenamento em cache KV usando formatos de espaço de bloco e componíveis para melhorar o acesso à memória e reduzir a redundância, 
ele possui um modelo de atenção personalizável que se adapta a várias configurações por meio da compilação just-in-time (JIT). 
Seu algoritmo de agendamento balanceado de carga se ajusta às solicitações dinâmicas do usuário enquanto permanece compatível com a configuração estática do NVIDIA CUDA Graph. 
O FlashInfer é integrado às principais estruturas de atendimento LLM, como MLC Engine, SGLang e vLLM, bem como vários mecanismos personalizados.

A NVIDIA agora está lançando ativamente seus kernels de inferência LLM de melhor desempenho no FlashInfer, 
incluindo os da NVIDIA TensorRT-LLM, para fácil integração em vLLM, SGLang e mecanismos de inferência personalizados.

