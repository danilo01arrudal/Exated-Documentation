output "raw_bucket_name" {
  value = aws_s3_bucket.raw.id
}

output "consume_bucket_name" {
  value = aws_s3_bucket.consume.id
}

output "data_generator_function" {
  value = aws_lambda_function.data_generator.function_name
}

output "data_processor_function" {
  value = aws_lambda_function.data_processor.function_name
}

output "promotion_app_function" {
  value = aws_lambda_function.promotion_app.function_name
}
