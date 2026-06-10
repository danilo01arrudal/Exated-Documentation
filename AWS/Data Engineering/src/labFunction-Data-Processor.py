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
