# Infrastructure ADR
Some general principle followed in the infrastructure code.


##Terraform style

#(001) Stick to declarative style, avoid ifs and loops unless -incredibly- necessary.
Try not to ever introduce logic or conditionals in Terraform scripts, even when supported by the language itself. Try to use modules (and code modularity) rather than use count whenever possible.
Rationale: Infrastructure is provisioned by terraform and setup (as made to work) via other toolings, such aws cli and so on. So Terraform should just deal with creating static infra objects, and should consequently be used declarativly to provision the simplest infra that can possbly be setup later, even if the provisioned infra is not working at provisining time.

#(002)Do not use inline resources, in general try to use association statements to associate resources.
Whenever possible do not use inline resource creation, but rather create independent entities that can then get attached one to the other. E.g. aws_iam_role_policy with the policy specified with the policy property. Do create the role with aws_iam_role, do create the policy with aws_iam_policy, and then attach the policy to the role with aws_iam_role_policy_attachment. 
Rationale: More than one AWS objects may be created when a single terraform object with inline statements is declared. Subsequent changes to the terraform objects and/or any of its inline statements will lead to the destruction and recreation of all the AWS object initially created, rather than just the single AWS object which should actually change. Using such techniques reduces the infra change footprint when re-running terraform and the risk associated with it, and promote reusability of terraform and AWS objects (where opportune).

#(003)Do use Terraform datasources sparringly and only if needed.
Try not to use Terraform datasources to fetch properies of object you have created (as opposed to entities which are always present in any AWS account). Datasource becomes a breaking point when the provisioned infrastructure is inconsistent with the script or the state, and will make creation and destruction impossible.

#(004)Terraform scripts and modules outputs always come as strings -withouth spaces-, never as list or complex data structure.
Using anything other than strings makes impossible to easily pass parameters between independent terraform scripts.

#(005)Files don't cost anything. Use as many as you need to.
In the context of a single terraform scripts try to organise the files either for function or for service provided, so not to have countless and unrelated between them terraform statements in a single file.

#(006)Do not have any non terraform specific code in terraform scripts.
Do please use teh file directive or the template_file terraform object.

#(007)Maintain locality of the infra provisioning.
Always try to provision AWS resources the closest possible to where they are being used.

#(008)Do namespace infra resources across different envirnments and multiple AWS accounts.
AWS resources namespace is scoped differently depending on the specific resources, and AWS resources should always be named keeping in mind that you will need multiple instances of a specific service in a single AWS account, and multiple instance of the same service in multiple AWS account. Therefore resources whose name is scoped on a AWS account basis needs to be scoped per environment (e.g., multiple ELB for a specific service are named accordingly to the environment/deployment, such as service1-dev, service1-qa, service1-prod). Resources whose name is scoped across the entire AWS cloud needs to be scoped using the AWS account number (e.g. S3 buckets, bucket-dev-5555555555, bucket-prod-5555555555, bucket-dev-7777777777).  

##Infra provisioning and lifecycles

#(100)Do use a share-nothing approach.
When provisioning the infra for multiple services which happens to use similar resources do not attempt to reuse such resources across multiple services.
Rationale: A DRY approach at code level is always welcome, especially if implemented via the use of terraform modules. On the contrary, you should avoid a DRY approach at infrastructure level, that is sharing phisical infra resources across services. Infra resources shared across multiple instances of a service, or even across different services always results in coupling points, dependency between services, and monolithic terraform scripts. Infra resources sharing is only allowed when there's cost issue (e.g. I'd rather create multiple databases in one RDS instance rather then multiple RDS instances) or where there's technologica limitations to further decoupling (e.g. needing network connectivity between private services and being therefore forced to share one network, or creating one apigw endpoint used by multiple apigw resources, as it's not possible to redeclare the endpoint multiple times).
Any dependendecy between services should be provisioned independently, and then be consumed by multiple services provisioned indepenedently. E.g., I have a terraform script which creates a network, and additional and independent terraform scripts which consume the output of the network script. When such strict decoupling is technological difficult, then decoupling should be implemented at terraform script level via the ise of modules and composable infrastructure.

#(101)Do not to try to setup the infrastructure at provisioning time. Just provision it. Set it up and make it works later. 
Terraform script should provision the minimum amount of infrastructure needed to get into a state where further iterative setup is possible at a later time. E.g. do create a Lambda infra via terraform, keep updating it with new code using the AWS CLI. Do setup an ECR+ECS infra for containers, keep adding new container revisions to ECR and updating the ECS task definition using the AWS CLI.

#(102)Differentiate between provisioning and operational lifecycle.
Services provisioning can almost always be split between what is needed for the service to run and what is needed in order to update and maintain the service. Those two lifecycle should be kept decoupled and provisioned accordingly. E.g, the provisioning of a Lambda function and its roles belong to the service provisioning lifecycle, as it's the monimal amount of infra needed to have the lambda run. Provisioning the cloudwatch instrumentation, the codepipeline CI and the bucket used to temporarely hold the updated payload belongs to the operational lifecycle. Both the infrastructure sets are needed to have a full lifecycle for the service, but they should be provisioned independently.

#(103)Infra development is done in two cycle. Iterative development via laptop push, deployment, testing and compliancy via CI.
Iterative and frequent Terraform development is performed on the laptop using Terragrunt as a terraform interface/wrapper. Once the code is suffiiently stable it is then deployed using the CI which may have a larger and more taxing number of tests, and is more oriented to compliance.


