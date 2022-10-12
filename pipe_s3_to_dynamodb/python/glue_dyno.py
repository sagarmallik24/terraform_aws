import sys
import boto3
import pandas as pd
from io import StringIO
from awsglue.utils import getResolvedOptions


K2=boto3.client('s3')
args = getResolvedOptions(sys.argv, [
                                    "key",
                                    "bucket"])
print(args)
file_name=args['key']
bucket_name= args['bucket']
data=K2.get_object(Bucket=bucket_name, Key=file_name)
data=data['Body'].read().decode('utf-8')

dynamodb = boto3.resource('dynamodb') 

data = pd.read_csv(StringIO(data), sep = ",")

table = dynamodb.Table('test_table_terra')

for i, j, k, l in zip(data['Name'], data['Xender'], data['DOB'],data['Sallary']):
    table.put_item(Item = {
        "Name": str(i), 
        "Xender": str(j),
        "DOB": str(k),
        "Sallary": str(l)
            
    })



