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
