 Docker decisons

 - Scratch runtime - have to manually copy CA certs ; worth for slimmer image 

 - Explicit alpine version in runtime to avoid latest breaking it

 - Multi-stage build to reduce image size



runtime multibuild steps:
 Scratch = Ditsroless
- find out requirements
- copy app, config, ssl certs
expose port 8080
ENTRYPOINT


AWS Archetectiure

- Fargate serverless
 - Dont have to manage server via EC2
 - EKS would be overkill as singular container


 Troubleshooting:

 - Security group on ECS task and ALB needs to match 

 - 80 and 443 allowed but app runs on 8080 ; route through target groups 

 - therefore Security group needs inbound rule of 443,80, and 8080 within its on security group

 - Need to also route 80 to 443 to enforce https



 - AWS Route53 manages ACM cert for ssl (https) given to the load balancer

 - Cloudflare CNAME points to ALB DNS


 Terraform 

 - State file managed remotely in an s3 bucket for flexibility/ best practice

 - modularised format for reusability and organisation

 - use of variables to make the code more DRY

 - DNS manaaged via cloudflare to be more cloud agnostic

- ALB is referenced by DNS name as IP addresses can change.

- Output files are needed for values in modules which are referenced by other modules, EG IAM module outputs the role ARN to be used by the ecs module.

Structure : Module outputs variable, variable is referenced in the variables file in other module, in main.tf value is passed in when calling to the module.*

*security group lives in the main itself so can be called directly, but still needs to be set in main.

debugging :

- when using JSON encode, the end of the configuration block cannot be on the same line as where the jsopn encode ends, terraform prompts to use a newline.

- Cloudflare provider is not by /hashicorp so needs to be explicitly declared in ACM block where needed; otherwise routes to hashicorp/cloudflare provider doesnt exist.


- terraform main.tf needs its own variable list for every .var


- Significant error

""Error: Invalid index
│ 
│   on modules/acm/acm.tf line 45, in resource "aws_acm_certificate_validation" "dns":
│   45:   validation_record_fqdns =[aws_acm_certificate.cert.domain_validation_options[0].resource_record_name] #Hostname declared explicitly as theres reported bugs in the clouudflare terraform module referencing.
│ 
│ Elements of a set are identified only by their value and don't have any separate index or key to select with, so it's only possible
│ to perform operations across all elements of the set.""


Cause: ACM data is a set, rather than a numbered list so values within it are unnumbered. Regardless of the fact I had only one domain on this project.

solution : convert set to list with terraforms inbuilt function tolist()



- Security groups in ECS module, needs to be defined as a list/set even if only assigning one SG.


- Record names already existing needs to be deleted in cloudflare

- ECS needs to be awsvpc and needs to explicilty state fargate in the service module.

- ECS CPU and memory modules were nested in the jsonencode where they need to be above it as the json is only for the container config.

- ECS CPU and memory in service needs to be specific parings from preset AWS values, eg 256 cpu supports 512,1gb,2gb memory only

- ECS service block needs force new deployment to be true when making changes so tasks get updated with new terraform config

- ECS needs public IP to pull image from ECR registry and internet access (since we're using public subnet)

, therefore needs to be in SG egress, also needs exec role to have permissions to do this in first place


- IAM roles need to be created, defined who can assume the role, then seperate block attaches the actual permissions

Testing:

Terraform fmt : simple formatting of main and provider
Terraform validate: used to scan for missing values/ incorrect values
Terraform plan: check if all variables plug in as intended, and see what will be created


 ACM 

 - needed cloudflare provider to validate DNS ownership, one record to connect to alb and one for ACM to connect to listener for https

 - more complex but keeps the DNS cloud agnostic and flexible, maintaining cloudflares useful features.

 - when adding the ACM to the listener we reference the validation resource's arn, in order to make sure it exists before being mapped to alb



 ECS

 needs 

 - SG  between ALB and ECR port 8080

 - cluster creation

 - task creation 

 - service creation with the task running

 - IAM roles; read ECR, read tasks, create clusters



 IAM -

 Role - name of a role itself, trust_policy is who can assume it

 role policy - JSON doc entailing what it can do 


Future improvements:

- implement auto-scaling groups
