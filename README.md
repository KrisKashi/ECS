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

 role