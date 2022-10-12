#===========varialbe declare===============

variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "user" {}

variable "region" {
        default = "us-east-1"
}

variable "lambda_function" {

    default = "s3_to_dynamodb_using_terraf"
}

variable "bucket_name" {

    default = "terraformbucket"    # user-terraformbucket
}

# -- set DynamoDb table name and also set partition_key and short key

variable "table_name" {

    default = "test_table_terra" 
}
variable "sort_key" {

    default = "Name" 
}
variable "partition_key" {

    default = "Xender" 
}

#=============================================

provider "aws" {
access_key = "${var.aws_access_key}"
secret_key = "${var.aws_secret_key}"
region     = "${var.region}"
version    = "4.34.0"

}

# IAM Role for lambda function

resource "aws_iam_role" "lambda_role_s3trigg" {

    name = "terraform_aws_role_dyno"
    assume_role_policy = "${file("iam/lambda_role.json")}"
  
}

# IAM policy for logging from a lambda

resource "aws_iam_role_policy" "iam_policy_for_lambda" {

    name = "aws_iam_policy_for_terraform_aws_lambda_roles3"
    role = "${aws_iam_role.lambda_role_s3trigg.id}"
    policy = "${file("iam/lambda_policy.json")}"
}


# generates an archive from content, a file or a directory of files.

locals {
  lambda_zip_locations = "python/s3_to_dynamodb.zip"
}

data "archive_file" "zip_the_python_code" {

    type = "zip"
    source_dir = "python"
    output_path = "${local.lambda_zip_locations}"
}


#create a lambda funtion

resource "aws_lambda_function" "terraform_lambda_func" {

    filename       = "${local.lambda_zip_locations}"
    function_name  = "${var.lambda_function}"
    role           = aws_iam_role.lambda_role_s3trigg.arn
    handler        = "s3_to_dynamodb.lambda_handler"
    runtime        = "python3.8"  
}

# creating bucket

resource "aws_s3_bucket" "bucket" {
  bucket = "${var.user}-${var.bucket_name}"

}

# for triggering lambda function

resource "aws_s3_bucket_notification" "bucket_notification" {

  bucket = aws_s3_bucket.bucket.id

  lambda_function {

    lambda_function_arn = aws_lambda_function.terraform_lambda_func.arn
    events              = ["s3:ObjectCreated:*"]
  }


}

#lambda_permission for s3 to invoke lambda 

resource "aws_lambda_permission" "allow_bucket" {

  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.terraform_lambda_func.arn
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${aws_s3_bucket.bucket.id}"

} 
#--------------------------for glue----------------------------------------

resource "aws_iam_role" "glue_role" {

    name = "terraform_aws_glue_role"
    assume_role_policy = "${file("iam/glue_role.json")}"
  
}

resource "aws_iam_role_policy" "iam_policy_for_glue" {

    name = "aws_iam_policy_for_terraform_aws_glue_role"
    role = "${aws_iam_role.glue_role.id}"
    policy = "${file("iam/glue_policy.json")}"
}

resource "aws_s3_bucket_object" "upload-script" {

    bucket = aws_s3_bucket.bucket.id
    key = "Glue_Script/glue_dyno.py"
    source = "python/glue_dyno.py"
}

resource "aws_glue_job" "try_glue_job" {

    name = "s3_to_dynamodb_job_terraf"
    role_arn = aws_iam_role.glue_role.arn
    max_retries = "2"
    timeout = 2880

    command {

      script_location = "s3://${var.user}-${var.bucket_name}/Glue_Script/glue_dyno.py"

      python_version = "3"

      name = "pythonshell"
    }
    execution_property {
      max_concurrent_runs = 3
    }
  
  # glue_version = "3.0"
}

#================for dynamodb ==================

resource "aws_dynamodb_table" "new-dynamodb-table" {
  name           = var.table_name
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = var.partition_key
  range_key      = var.sort_key

  attribute {
    name = var.partition_key
    type = "S"
  }

  attribute {
    name = var.sort_key
    type = "S"
  }

  global_secondary_index {
    name               = var.sort_key
    hash_key           = var.partition_key
    range_key          = var.sort_key
    write_capacity     = 10
    read_capacity      = 10
    projection_type    = "INCLUDE"
    non_key_attributes = [var.partition_key]
  }

  tags = {
    Name        = var.table_name
    Environment = "production"
  }
}






