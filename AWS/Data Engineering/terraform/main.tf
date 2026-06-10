terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# ----------------------------------------------
# BUCKETS S3
# ----------------------------------------------
resource "aws_s3_bucket" "raw" {
  bucket = "${var.raw_bucket_name}-${data.aws_caller_identity.current.account_id}"
  force_destroy = true
}

resource "aws_s3_bucket" "consume" {
  bucket = "${var.consume_bucket_name}-${data.aws_caller_identity.current.account_id}"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "raw_block" {
  bucket = aws_s3_bucket.raw.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "consume_block" {
  bucket = aws_s3_bucket.consume.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Ativar envio de notificações para o EventBridge (bucket consume)
resource "aws_s3_bucket_notification" "consume_eventbridge" {
  bucket = aws_s3_bucket.consume.id
  eventbridge = true
}

# ----------------------------------------------
# IAM ROLES E POLÍTICAS
# ----------------------------------------------
data "aws_caller_identity" "current" {}
data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# Política base para logs do CloudWatch
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  for_each = toset([
    aws_iam_role.role_generator.name,
    aws_iam_role.role_processor.name,
    aws_iam_role.role_promotion.name
  ])
  role       = each.value
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Política de acesso aos buckets S3
resource "aws_iam_role" "role_generator" {
  name = "lambda-data-generator-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_role" "role_processor" {
  name = "lambda-data-processor-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_role" "role_promotion" {
  name = "lambda-promotion-app-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_policy" "s3_access" {
  name = "lambda-s3-access"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = [
          "${aws_s3_bucket.raw.arn}/*",
          "${aws_s3_bucket.consume.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "s3_generator" {
  role       = aws_iam_role.role_generator.name
  policy_arn = aws_iam_policy.s3_access.arn
}

resource "aws_iam_role_policy_attachment" "s3_processor" {
  role       = aws_iam_role.role_processor.name
  policy_arn = aws_iam_policy.s3_access.arn
}

resource "aws_iam_role_policy_attachment" "s3_promotion" {
  role       = aws_iam_role.role_promotion.name
  policy_arn = aws_iam_policy.s3_access.arn
}

# ----------------------------------------------
# CAMADA LAMBDA COM PANDAS (build local)
# ----------------------------------------------
resource "null_resource" "build_pandas_layer" {
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command = <<EOT
      mkdir -p layer_content/python
      pip install pandas -t layer_content/python
      cd layer_content
      zip -r ../pandas_layer.zip .
      cd ..
      rm -rf layer_content
    EOT
    interpreter = ["/bin/bash", "-c"]
  }
}

resource "aws_lambda_layer_version" "pandas_layer" {
  layer_name = "pandas_layer"
  filename   = "pandas_layer.zip"
  compatible_runtimes = ["python3.9", "python3.10", "python3.11", "python3.12"]

  depends_on = [null_resource.build_pandas_layer]
}

# ----------------------------------------------
# CÓDIGO DAS FUNÇÕES LAMBDA
# ----------------------------------------------
# Gerador (sem dependências externas)
resource "local_file" "data_generator_py" {
  filename = "${path.module}/lambda_functions/data_generator.py"
  content = <<-EOF
import json
import boto3
import csv
import random
from io import StringIO
import os

s3 = boto3.client('s3')
RAW_BUCKET = os.environ['RAW_BUCKET']

def lambda_handler(event, context):
    rows = []
    for i in range(1000):
        cart_id = random.randint(0, 10)
        customer_id = random.randint(0, 10)
        product_id = random.randint(0, 10)
        product_amount = random.randint(1, 20)
        price = round(random.uniform(0.1, 1000), 2)
        product_price = f"${price:,.2f}"
        rows.append([cart_id, customer_id, product_id, product_amount, product_price])

    output = StringIO()
    writer = csv.writer(output)
    writer.writerow(['cart_id', 'customer_id', 'product_id', 'product_amount', 'product_price'])
    writer.writerows(rows)

    s3.put_object(
        Bucket=RAW_BUCKET,
        Key='cart_abandonment_data.csv',
        Body=output.getvalue().encode('utf-8')
    )
    return {'statusCode': 200, 'body': json.dumps('Arquivo gerado com sucesso!')}
EOF
}

resource "local_file" "data_processor_py" {
  filename = "${path.module}/lambda_functions/data_processor.py"
  content = <<-EOF
import json
import boto3
import pandas as pd
from io import StringIO
import os

s3 = boto3.client('s3')
RAW_BUCKET = os.environ['RAW_BUCKET']
CONSUME_BUCKET = os.environ['CONSUME_BUCKET']

def lambda_handler(event, context):
    obj = s3.get_object(Bucket=RAW_BUCKET, Key='cart_abandonment_data.csv')
    df = pd.read_csv(obj['Body'])
    # Limpeza do preço (remove cifrão e vírgulas)
    df['product_price'] = df['product_price'].replace('[\$,]', '', regex=True).astype(float)
    aggregated = df.groupby('product_id', as_index=False)['product_amount'].sum()
    aggregated = aggregated.sort_values('product_amount', ascending=False)

    csv_buffer = StringIO()
    aggregated.to_csv(csv_buffer, index=False)
    s3.put_object(Bucket=CONSUME_BUCKET, Key='cart_aggregated_data.csv', Body=csv_buffer.getvalue().encode('utf-8'))
    return {'statusCode': 200, 'body': json.dumps('Agregação concluída!')}
EOF
}

resource "local_file" "promotion_app_py" {
  filename = "${path.module}/lambda_functions/promotion_app.py"
  content = <<-EOF
import json
import boto3
import pandas as pd
from io import StringIO
import os

s3 = boto3.client('s3')
RAW_BUCKET = os.environ['RAW_BUCKET']
CONSUME_BUCKET = os.environ['CONSUME_BUCKET']

def lambda_handler(event, context):
    obj = s3.get_object(Bucket=RAW_BUCKET, Key='cart_abandonment_data.csv')
    df = pd.read_csv(obj['Body'])
    promo = df.groupby(['customer_id', 'product_id'], as_index=False)['product_amount'].sum()
    promo = promo.sort_values(['customer_id', 'product_amount'], ascending=[True, False])

    csv_buffer = StringIO()
    promo.to_csv(csv_buffer, index=False)
    s3.put_object(Bucket=CONSUME_BUCKET, Key='promotion_data.csv', Body=csv_buffer.getvalue().encode('utf-8'))
    return {'statusCode': 200, 'body': json.dumps('Dados de promoção gerados!')}
EOF
}

# Compactar os códigos
data "archive_file" "generator_zip" {
  type        = "zip"
  source_file = local_file.data_generator_py.filename
  output_path = "${path.module}/generator.zip"
}

data "archive_file" "processor_zip" {
  type        = "zip"
  source_file = local_file.data_processor_py.filename
  output_path = "${path.module}/processor.zip"
}

data "archive_file" "promotion_zip" {
  type        = "zip"
  source_file = local_file.promotion_app_py.filename
  output_path = "${path.module}/promotion.zip"
}

# ----------------------------------------------
# FUNÇÕES LAMBDA
# ----------------------------------------------
resource "aws_lambda_function" "data_generator" {
  filename         = data.archive_file.generator_zip.output_path
  function_name    = "labFunction-Data-Generator"
  role             = aws_iam_role.role_generator.arn
  handler          = "data_generator.lambda_handler"
  runtime          = "python3.12"
  timeout          = 60
  memory_size      = 128

  environment {
    variables = {
      RAW_BUCKET = aws_s3_bucket.raw.id
    }
  }
}

resource "aws_lambda_function" "data_processor" {
  filename         = data.archive_file.processor_zip.output_path
  function_name    = "labFunction-Data-Processor"
  role             = aws_iam_role.role_processor.arn
  handler          = "data_processor.lambda_handler"
  runtime          = "python3.12"
  timeout          = 120
  memory_size      = 512
  layers           = [aws_lambda_layer_version.pandas_layer.arn]

  environment {
    variables = {
      RAW_BUCKET     = aws_s3_bucket.raw.id
      CONSUME_BUCKET = aws_s3_bucket.consume.id
    }
  }
}

resource "aws_lambda_function" "promotion_app" {
  filename         = data.archive_file.promotion_zip.output_path
  function_name    = "labFunction-Promotion-App"
  role             = aws_iam_role.role_promotion.arn
  handler          = "promotion_app.lambda_handler"
  runtime          = "python3.12"
  timeout          = 120
  memory_size      = 512
  layers           = [aws_lambda_layer_version.pandas_layer.arn]

  environment {
    variables = {
      RAW_BUCKET     = aws_s3_bucket.raw.id
      CONSUME_BUCKET = aws_s3_bucket.consume.id
    }
  }
}

# ----------------------------------------------
# GATILHO S3 -> LAMBDA (Processador)
# ----------------------------------------------
resource "aws_lambda_permission" "allow_s3_processor" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.data_processor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.raw.arn
}

resource "aws_s3_bucket_notification" "raw_trigger" {
  bucket = aws_s3_bucket.raw.id
  lambda_function {
    lambda_function_arn = aws_lambda_function.data_processor.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "cart_abandonment"
  }
  depends_on = [aws_lambda_permission.allow_s3_processor]
}

# ----------------------------------------------
# EVENTBRIDGE -> LAMBDA (Promoção)
# ----------------------------------------------
resource "aws_cloudwatch_event_rule" "promotion_rule" {
  name        = "promotion-trigger"
  description = "Dispara a função de promoção quando cart_aggregated_data.csv é criado no bucket consume"
  event_pattern = jsonencode({
    source = ["aws.s3"]
    detail-type = ["AWS API Call via CloudTrail"]
    detail = {
      eventSource = ["s3.amazonaws.com"]
      eventName   = ["PutObject", "CompleteMultipartUpload"]
      requestParameters = {
        bucketName = [aws_s3_bucket.consume.id]
        key        = ["cart_aggregated_data.csv"]
      }
    }
  })
}

resource "aws_cloudwatch_event_target" "promotion_target" {
  rule      = aws_cloudwatch_event_rule.promotion_rule.name
  target_id = "InvokePromotionLambda"
  arn       = aws_lambda_function.promotion_app.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.promotion_app.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.promotion_rule.arn
}
