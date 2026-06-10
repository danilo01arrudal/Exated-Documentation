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
