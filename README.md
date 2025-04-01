### Healthcare Microservices Deployment to ECS

- provided microservices are JavaScript based applications
- Node docker image can be used to containarize the applications
- applications depend upon the certain library - express
- install the library/package in the docker file 
- I have used/created 2 Dockerfile respectively for the patient and appointment applications

### Terraform 

- terraform state is maintained in s3 with dynamodb lock mechanism
- used terraform provided modules vpc, alb, ecs, ecr


### how to start contributing
- clone the project
- terraform init to begin the terraform journey
- terraform plan or terraform graph to visualise the effect of the scripts
- 

### Github actions
- pipeline to trigger on [pull_request]
    - Terraform fmt and validate on all PRs
    - Terraform plan on pull requests
- pipeline to trigger on [merge]
    - Terraform apply on merges to main branch


## Improvements

- terraform scripts enhancement 
