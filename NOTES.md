# Task 1 — EC2 instances

The `instances` map in `environments/dev/terraform.tfvars` supplies all five
instances, each with a different instance type, root volume type, size, and key
pair. It includes both io1 and io2 volumes. Every instance receives Name,
Environment, and Owner tags. The outputs map each name to its ID and private IP.

I protected `database` with `prevent_destroy = true` because accidentally
replacing or deleting a database could lose its data. Terraform requires a
literal lifecycle value, so two filtered `for_each` blocks use the same input:
one for the database and one for the other four instances.

# Task 2 — Remote state and locking

The backend stores state at `s3://devopslab/dev/terraform.tfstate` and uses
`dev-terraform-locks` in us-east-1 for locking. The bucket and table must exist
before initialization. The table needs a string partition key named `LockID`.

With separate local state files, two people can apply at the same time without
seeing each other's changes, causing duplicate resources or conflicting updates.
The shared backend uses one state file, and the DynamoDB lock allows only one
state-changing operation at a time. Other operations fail to acquire the lock
or wait when a lock timeout is supplied. DynamoDB locking is used to meet the
assignment, although Terraform now marks it deprecated.

# Task 3 — IAM and cross-account access

Group1 contains engine and ci, with access keys and no console login profiles.
Group2 contains alice and bob, with console passwords and access keys.
RoleA allows administration outside IAM and explicitly denies `iam:*`.
RoleB can only assume roleC. RoleC trusts roleB's exact ARN and grants `s3:*`
only on the existing bucket supplied through `bucket_name` and its objects.

**Would I use IAM users and access keys in production?**
Usually no. I would use OIDC federation for CI, workload roles for applications,
and IAM Identity Center for human access. These provide temporary credentials
instead of long-lived keys. The IAM users here satisfy the assignment.

**Why trust roleB instead of Account A root?**
Trusting Account A root delegates trust to the account, allowing its
administrators to authorize other identities. Trusting roleB's exact ARN limits
assumption to roleB sessions. Its own trust policy controls who can obtain
those sessions.

For deployment, supply the existing bucket name, account profiles, and public
PGP keys for all four users in `environments/dev/terraform.tfvars`. The PGP keys
encrypt generated credentials. The account IDs and network values are examples
to replace before a real deployment.

# Task 4 — CI policy

The custom policy is `policies/ci-pipeline.json`. It allows pushes to ECR
repository `dev-app`, task registration for family `dev-app`, deployment to
`dev-app-service` in `dev-app-cluster`, and read-only access to the named
artifacts bucket. It is supplied as JSON only, without a Terraform attachment.

I left out resource creation/deletion, S3 writes, IAM administration, unrelated
resources, and role assumption because the pipeline does not need them.
`iam:PassRole` is limited to two ECS task roles and the ECS tasks service.
`DescribeServices` supports deployment checks; `ListBucket` supports artifact
discovery. ECR authentication requires `Resource = "*"`; repository operations
remain scoped. `BatchGetImage` supports manifest checks during image pushes.
Tags, historical S3 versions, and KMS permissions are omitted; this example
assumes untagged task registration and SSE-S3 artifacts.

# Task 5 — Bug fixes

The corrected standalone snippet is `task5.tf`.

1. `user/roleB` identifies an IAM user, not roleB. The trust principal must be
   `arn:aws:iam::000000000000:role/roleB`. The original principal either does not
   exist and is rejected by AWS, or trusts the wrong identity and prevents
   roleB from assuming roleC.
2. `s3:*` with `Resource = "*"` grants excessive access. The fix names one bucket
   ARN and its `/*` object ARN. Both are needed for bucket and object operations.
   This is a permissions-scope bug, not the cause of the failed assumption.

RoleB also needs permission to assume roleC, which Task 3 supplies. The snippet
uses an example bucket name to replace and must run with Account B credentials.
It is separate from dev, which already manages roleC. Using `roleC.id` is valid
and was not a bug.

# Verification

Terraform 1.14.5 and AWS provider 5.100.0 were used. Formatting, JSON parsing,
and Terraform validation passed; validation reports provider-declaration
warnings. All six mock tests passed. Live AWS deployment, authorization, and
remote locking have not been tested.

```sh
terraform -chdir=environments/dev init -backend=false
terraform -chdir=environments/dev test
```

To view the combined environment test's mocked outputs:

```sh
terraform -chdir=environments/dev test -filter=tests/dev.tftest.hcl -verbose
```
