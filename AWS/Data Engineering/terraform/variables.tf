variable "aws_region" {
  description = "Região AWS onde os recursos serão criados"
  type        = string
  default     = "us-east-1"
}

variable "raw_bucket_name" {
  description = "Nome do bucket S3 para dados brutos"
  type        = string
  default     = "raw-bucket"
}

variable "consume_bucket_name" {
  description = "Nome do bucket S3 para dados processados"
  type        = string
  default     = "consume-bucket"
}
