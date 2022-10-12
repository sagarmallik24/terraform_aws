import json
import boto3

def lambda_handler(event, context):
  file_name=event['Records'][0]['s3']['object']['key']
  bucket_name=event['Records'][0]['s3']['bucket']['name']
  print("filename:",file_name)
  print("bucketname:",bucket_name)
  client=boto3.client('glue')
  response=client.start_job_run(JobName='s3_to_dynamodb_job_terraf', Arguments={
                                                              '--key':file_name,
                                                            '--bucket':bucket_name,
                                                            })
  print("lambda invoke")
  print(response)