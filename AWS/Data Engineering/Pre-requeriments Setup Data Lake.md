## Etapas iniciais não cobertas pelo procedimento

O Data Lake descrito parte do pressuposto de que os seguintes recursos já existem:
- Buckets S3 (`raw-bucket` e `consume-bucket`)
- Três funções Lambda (`labFunction-Data-Generator`, `labFunction-Data-Processor`, `labFunction-Promotion-App`)

Para que você possa reproduzir o laboratório do zero (ou documentar a criação completa), estes são os **passos iniciais necessários**:

### 1. Pré‑requisitos da conta AWS
- Conta AWS ativa (você já mencionou como implícito).
- Usuário IAM com permissões administrativas ou, no mínimo, permissões para:
  - Criar buckets S3
  - Criar funções Lambda
  - Criar regras no Amazon EventBridge
  - Criar funções e políticas IAM
- AWS CLI configurada (opcional, mas recomendado) ou acesso ao Console AWS.

### 2. Criar os buckets S3
- **raw-bucket** – armazenará os dados brutos (`cart_abandonment_data.csv`).  
  *Configuração sugerida:* bloqueio de acesso público, versionamento ativado (opcional), tags para custo.
- **consume-bucket** – armazenará os dados processados (`cart_aggregated_data.csv` e `promotion_data.csv`).  
  *Configuração similar.*

### 3. Criar as funções Lambda (código Python)
Cada função precisa de:
- Código (os scripts fornecidos abaixo).
- Uma **role IAM** com políticas que permitam:
  - `AWSLambdaBasicExecutionRole` (logs no CloudWatch).
  - Acesso de leitura/escrita aos buckets S3 específicos.
  - (Para a função processadora e de promoção) permissão para ser acionada por S3 ou EventBridge.
- **Variáveis de ambiente**:
  - `RAW_BUCKET` – nome do bucket raw.
  - `CONSUME_BUCKET` – nome do bucket consume.
  - (Opcional) `REGION` – região AWS.

### 4. Configurar os gatilhos (triggers)
- **`labFunction-Data-Processor`** – Gatilho do S3:
  - Evento: `s3:ObjectCreated:*` no bucket `raw-bucket`.
  - Prefixo opcional (ex.: `cart_abandonment`).
- **`labFunction-Promotion-App`** – Gatilho do EventBridge:
  - Regra que captura eventos `ObjectCreated` no **`consume-bucket`** (para o arquivo `cart_aggregated_data.csv`).
  - Destino: a função Lambda de promoção.

### 5. Configurar notificações do S3 para o EventBridge (opcional, mas usado no laboratório)
No bucket `consume-bucket`, ativar a opção **"Enviar notificações para o Amazon EventBridge para todos os eventos neste bucket"**. Isso garante que a criação do arquivo agregado dispare a regra do EventBridge.

### 6. (Opcional) Criar uma camada Lambda para pandas
Como as funções usam `pandas`, você precisa empacotar a biblioteca. Existem duas opções:
- Usar uma **AWS Lambda Layer** oficial do `pandas` (recomendado).
- Incluir `pandas` e suas dependências diretamente no pacote de implantação (não recomendado devido ao tamanho).

---

## Código Python para as funções Lambda

Abaixo estão os scripts completos. Eles assumem que as variáveis de ambiente `RAW_BUCKET` e `CONSUME_BUCKET` estão definidas.

> **Importante:** Para usar `pandas` no Lambda, você deve adicionar a [camada AWS SDK for pandas (awswrangler)](https://aws-sdk-pandas.readthedocs.io/en/stable/layers.html) ou uma camada personalizada com pandas.

### 1. `labFunction-Data-Generator` – Gerador de dados sintéticos

```python
import json
import boto3
import os
import random
import csv
from io import StringIO
from faker import Faker  # Necessário adicionar Faker via camada ou empacotamento

s3 = boto3.client('s3')
fake = Faker()

RAW_BUCKET = os.environ['RAW_BUCKET']

def lambda_handler(event, context):
    # Gerar 1000 registros de abandono de carrinho
    rows = []
    for i in range(1000):
        cart_id = random.randint(0, 10)
        customer_id = random.randint(0, 10)
        product_id = random.randint(0, 10)
        product_amount = random.randint(1, 20)
        product_price = round(random.uniform(0.1, 1000), 2)
        rows.append([cart_id, customer_id, product_id, product_amount, f"${product_price:,.2f}"])
    
    # Escrever CSV em memória
    output = StringIO()
    writer = csv.writer(output)
    writer.writerow(['cart_id', 'customer_id', 'product_id', 'product_amount', 'product_price'])
    writer.writerows(rows)
    
    # Upload para o bucket raw
    s3.put_object(
        Bucket=RAW_BUCKET,
        Key='cart_abandonment_data.csv',
        Body=output.getvalue().encode('utf-8')
    )
    
    return {
        'statusCode': 200,
        'body': json.dumps('Arquivo gerado com sucesso!')
    }
```

### 2. `labFunction-Data-Processor` – Agregação por produto

```python
import json
import boto3
import os
import pandas as pd
from io import StringIO

s3 = boto3.client('s3')

RAW_BUCKET = os.environ['RAW_BUCKET']
CONSUME_BUCKET = os.environ['CONSUME_BUCKET']

def lambda_handler(event, context):
    # Baixar o arquivo raw do S3
    obj = s3.get_object(Bucket=RAW_BUCKET, Key='cart_abandonment_data.csv')
    df = pd.read_csv(obj['Body'])
    
    # Limpeza: remover cifrão e converter product_price para numérico (se necessário)
    df['product_price'] = df['product_price'].replace('[\$,]', '', regex=True).astype(float)
    
    # Agregação: somar product_amount por product_id
    aggregated = df.groupby('product_id', as_index=False)['product_amount'].sum()
    aggregated = aggregated.sort_values('product_amount', ascending=False)
    
    # Salvar como CSV no bucket consume
    csv_buffer = StringIO()
    aggregated.to_csv(csv_buffer, index=False)
    
    s3.put_object(
        Bucket=CONSUME_BUCKET,
        Key='cart_aggregated_data.csv',
        Body=csv_buffer.getvalue().encode('utf-8')
    )
    
    return {
        'statusCode': 200,
        'body': json.dumps('Agregação concluída!')
    }
```

### 3. `labFunction-Promotion-App` – Agregação por cliente e produto

```python
import json
import boto3
import os
import pandas as pd
from io import StringIO

s3 = boto3.client('s3')

RAW_BUCKET = os.environ['RAW_BUCKET']
CONSUME_BUCKET = os.environ['CONSUME_BUCKET']

def lambda_handler(event, context):
    # Lê o dado bruto novamente (ou poderia ler o agregado, mas precisa do customer_id)
    obj = s3.get_object(Bucket=RAW_BUCKET, Key='cart_abandonment_data.csv')
    df = pd.read_csv(obj['Body'])
    
    # Agregação por customer_id e product_id
    promo = df.groupby(['customer_id', 'product_id'], as_index=False)['product_amount'].sum()
    promo = promo.sort_values(['customer_id', 'product_amount'], ascending=[True, False])
    
    # Salvar no bucket consume
    csv_buffer = StringIO()
    promo.to_csv(csv_buffer, index=False)
    
    s3.put_object(
        Bucket=CONSUME_BUCKET,
        Key='promotion_data.csv',
        Body=csv_buffer.getvalue().encode('utf-8')
    )
    
    return {
        'statusCode': 200,
        'body': json.dumps('Dados de promoção gerados!')
    }
```

---

## Permissões IAM (role para as funções Lambda)

Exemplo de política gerenciada a ser anexada à role de cada função:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:PutObject"
            ],
            "Resource": [
                "arn:aws:s3:::seu-raw-bucket/*",
                "arn:aws:s3:::seu-consume-bucket/*"
            ]
        }
    ]
}
```

Além disso, para a função `labFunction-Data-Processor` que é acionada diretamente pelo S3, a role deve permitir a permissão `lambda:InvokeFunction` para o serviço S3 (já configurada automaticamente ao adicionar o trigger via console).

---

## Sugestão de ordem para enriquecer seu documento

1. **Pré‑requisitos** (conta AWS, CLI, permissões)
2. **Criação dos buckets S3** (comandos ou console)
3. **Criação das roles IAM** (políticas customizadas)
4. **Criação das funções Lambda** com os códigos acima
5. **Configuração de variáveis de ambiente** nas funções
6. **Criação do trigger S3** para a função processadora
7. **Criação da regra no EventBridge** para a função de promoção
8. **Teste manual** (invocar a função geradora via console)
9. **Verificação dos resultados** nos buckets S3


