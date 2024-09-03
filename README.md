## Deploy a Stack with HCP Terraform

A Terraform Stack allows you to compose Terraform modules and deploy them with a shared lifecycle. With Stacks, you can split your Terraform configuration into composable modules with a shared lifecycle, deploy the same configuration to multiple environments, and orchestrate changes between your environments.

In this tutorial you will deploy a Terraform Stack consisting of an AWS Lambda function and related resources. Then, you will deploy a second instance of your Stack in another region.

### Prerequisites

This tutorial assumes that you are familiar with the Terraform workflow. If you
are new to Terraform, complete the [Get Started
tutorials](/terraform/tutorials/aws-get-started) first.

In order to complete this tutorial, you will need the following:

- An [AWS
  account](https://portal.aws.amazon.com/billing/signup?nc2=h_ct&src=default&redirect_url=https%3A%2F%2Faws.amazon.com%2Fregistration-confirmation#/start).
- An [HCP Terraform
  account](https://app.terraform.io/signup/account?utm_source=learn).
- An [HCP Terraform variable set configured with your AWS
  credentials](/terraform/tutorials/cloud-get-started/cloud-create-variable-set).

### Create example repository

Navigate to the [template
repository](https://github.com/hashicorp/learn-terraform-stacks-deploy) for this
tutorial. Click the **Use this template** button and select **Create a new
repository**. Choose a GitHub account to create the repository in and name the
new repository `learn-terraform-stacks-deploy`. Leave the rest of the settings
at their default values.

Clone your example repository, replacing `USER` with your own GitHub username.

```shell-session
$ git clone https://github.com/USER/learn-terraform-stacks-deploy.git
```

Change to the repository directory.

```shell-session
$ cd learn-terraform-stacks-deploy
```

### Review components and deployment

Explore the example configuration to review how this Terraform Stack's configuration is organized.

<CodeBlockConfig hideClipboard>

```shell-session
$ tree
.
├── CODEOWNERS
├── LICENSE
├── README.md
├── api-gateway
│   ├── main.tf
│   ├── outputs.tf
│   └── variables.tf
├── components.tfstack.hcl
├── deployments.tfdeploy.hcl
├── lambda
│   ├── hello-world
│   │   └── hello.rb
│   ├── main.tf
│   ├── outputs.tf
│   └── variables.tf
├── providers.tfstack.hcl
├── s3
│   ├── main.tf
│   └── outputs.tf
└── variables.tfstack.hcl
```

In addition to the licensing-related files and README, the example repository
contains three directories containing Terrraform modules, `api-gateway`,
`lambda`, and `s3`. The Terraform configuration in these directories define the
components that will make up your stack. The repository also includes two file
types specific to Terraform Stacks configuration, a deployments filed named
`deployments.tfdeploy.hcl`, and three stacks files with the extension
`.tfstack.hcl`.

As with Terraform configuration files, HCP Terraform will process all of the blocks in all of the `tfstack.hcl` and `tfdeploy.hcl` files in your stack's root directory in dependancy order, so you can organize your stacks configuration into multiple files just like Terraform configuration.

#### Review components

Open the `providers.tfstack.hcl` file. This file contains the provider configuration for your stack.

<CodeBlockConfig hideClipboard filename="providers.tfstack.hcl">

```hcl
required_providers {
  aws = {
    source  = "hashicorp/aws"
    version = "~> 5.7.0"
  }

  random = {
    source  = "hashicorp/random"
    version = "~> 3.5.1"
  }

  archive = {
    source  = "hashicorp/archive"
    version = "~> 2.4.0"
  }

  local = {
    source = "hashicorp/local"
    version = "~> 2.4.0"
  }
}

provider "aws" "configurations" {
  for_each = var.regions

  config {
    region = each.value

    assume_role_with_web_identity {
      role_arn           = var.role_arn
      web_identity_token = var.identity_token
    }

    default_tags {
      tags = var.default_tags
    }
  }
}

provider "random" "this" {}
provider "archive" "this" {}
provider "local" "this" {}
```

</CodeBlockConfig>

The `required_providers` block defines the providers used in this configuration, and uses a syntax similar to the `required_providers` block nested inside the `terraform` block in Terraform configuration.

This configuration also includes `provider` blocks that configure each provider. Unlike Terraform configuration, stacks provider blocks include a label, allowing you to configure multiple providers of each time if needed. The configuration also includes a `for_each` block so that stacks will use a seperate AWS provider configuration for each region. Terraform stacks allow you to write stacks configurations that deploy similar infrastructure across multiple cloud provider regions.

Next, review the `components.tfstack.hcl` file. This file contains all of the
components for your stack. Like Terraform configuration, you can organize your
stacks configuration into multiple files without affecting the resulting
infrastructure. 

<CodeBlockConfig hideClipBoard filename="components.tfstack.hcl">

```hcl
component "s3" {
  for_each = var.regions

  source = "./s3"

  inputs = {
    region = each.value
  }

  providers = {
    aws    = provider.aws.configurations[each.value]
    random = provider.random.this
  }
}

component "lambda" {
  for_each = var.regions

  source = "./lambda"

  inputs = {
    region    = var.regions
    bucket_id = component.s3[each.value].bucket_id
  }

  providers = {
    aws     = provider.aws.configurations[each.value]
    archive = provider.archive.this
    local   = provider.local.this
    random  = provider.random.this
  }
}

component "api_gateway" {
  for_each = var.regions

  source = "./api-gateway"

  inputs = {
    region               = each.value
    lambda_function_name = component.lambda[each.value].function_name
    lambda_invoke_arn    = component.lambda[each.value].invoke_arn
  }

  providers = {
    aws    = provider.aws.configurations[each.value]
    random = provider.random.this
  }
}
```

</CodeBlockConfig>

This file includes configuration for three components. A stacks component
sources its configuration from a Terraform module, and also includes input
arguments to that module, and the providers Terraform will use to provision your infrastructure.

The example configuration uses the `for_each` meta-argument for each of the components, and sets the AWS for the given region for each instance of the component to use.

#### Review deployments

<CodeBlockConfig hideClipboard filename="deployments.tfdeploy.hcl">

```hcl
deployment "development" {
  inputs = {
    regions        = ["us-east-1"]
    role_arn       = "<Set to your development AWS account IAM role ARN>"
    identity_token = identity_token.aws.jwt
    default_tags   = { stacks-preview-example = "lambda-component-expansion-stack" }
  }
}

deployment "production" {
  inputs = {
    regions        = ["us-east-1", "us-west-1"]
    role_arn       = "<Set to your production AWS account IAM role ARN>"
    identity_token = identity_token.aws.jwt
    default_tags   = { stacks-preview-example = "lambda-component-expansion-stack" }
  }
}
```

</CodeBlockConfig>

This stack includes two deployments, one for development, and a second for
production. Each deployment block represents an instance of the configuration
defined in the stack, configured with the given inputs. Deployments also support orchestration rules, which allow you to define the behavior of your stack in code.

### Create stack in HCP Terraform

Use the example configuration to provision your stack. To do so, log in to [HCP
Terraform](https://app.terraform.io/app), and select the organization you wish
to use for this tutorial.

First, create a project for your stack. Navigate to `Projects`, click the `+ New Project` button, name your project `Learn Terraform stacks`, and click the
`Create` button to create it.

Next, ensure that stacks is enabled for your organization by navigating to
`Settings > General`. Ensure that the box next to `Stacks` is checked, and click
the `Update organization` button.

Then, ensure that your AWS credentials variable set is configured for your
project. Navigate to `Settings > Variable sets`, and select your AWS credentials
variable set. Under `Variable set scope`, either select `Apply globally` to
apply the set to all workspaces in your organization, or select `Apply to specific projects and workspaces`, and add the `Learn Terraform stacks` project
to the list under `Apply to projects`. Scroll to the bottom of the page and
click `Save variable set` to apply it to your new project.

Return to your project by navigating to `Projects` and selecting your `Learn Terraform stacks` project. Select `Stacks` from the left nav and click `+ New stack`.

On the `Connect to VCS` page, select your GitHub account. Then, choose the
repository you created for this tutorial, `learn-terraform-stacks-deploy`. On the next page, leave your stack name the same as your repository name, and click `Create stack` to create it.

### Provision infrastructure
### Add a new deployment
### Destroy infrastructure
### Next steps
