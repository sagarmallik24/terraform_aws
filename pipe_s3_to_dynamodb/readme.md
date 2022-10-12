## Project Overview
#### This project contains source code and supporting files for a terraform application that you can deploy with the terminal.
#### It includes the follwing files and folder:

- In IAM Directory, we have AWS lambda function and glue job roles and policies, you can change the policies according to your requirement.

- Python Directory- we have glue script and lambda function.

#### This code for creating pipe line between AWS S3 BUCKET TO AWS DYNAMODB TABLE.

- In main.tf you can change your region, AWS lambda function name, AWS Dynamodb table name and partition key ,sort_key in Variable section.

#### For deployment open your terminal in main.tf directory then run commands: 

    1. terraform init
    2. terraform plan -out=user.txt 
            -  when planing the terrafrom file it will ask aws credintials that will be save in terraform.tfvars

    3. terraform apply -- user.txt



