# Patient Record Migration Core Infrastructure

Provides support for creating an AWS VPC that provides access to the NHS OpenTest environment using a VPN tunnel.

## Structure

The repository contains [Infrastructure as Code](https://martinfowler.com/bliki/InfrastructureAsCode.html) to create an [AWS CodePipeline](https://aws.amazon.com/codepipeline/) pipeline to provide [Continuous Delivery](https://martinfowler.com/bliki/ContinuousDelivery.html) of the infrastructure and the actual infrastructure code itself.

The environment is provisioned using the [Terragrunt](https://github.com/gruntwork-io/terragrunt) wrapper for [Terraform](https://terraform.io).

The pipeline is provided in the `pipeline` directory, the desired infrastructure code in the root.  Within each of these is an directory `env/<env-name>-<account-name>` which provides the Terragrunt configuration for the environment and a `package` directory that contains the non-environment specific code.

```
└── e2e
    ├── *.js
    env
    ├── <env-name>-<account-name>
    |   └── <package-name>
    |       └── terraform.tfvars
    packages
    ├── <package-name>
    |   └── *.tf
    ├── modules
    |   └── <module-name>
    |       └── *.tf
    pipeline
    └── env
        ├── <env-name>-<account-name>
        |   └── <package-name>
        |       └── terraform.tfvars
        packages
        ├── <package-name>
        |   └── *.tf
```

## Usage

1. Install [Terraform](https://terraform.io)
2. Install [Terragrunt](https://github.com/gruntwork-io/terragrunt)
3. Create the pipeline

```
$ cd pipeline/env/<env-name>-<account-name>
$ terragrunt apply-all
```

Once the pipeline has been created it will provision the rest of the infrastructure.