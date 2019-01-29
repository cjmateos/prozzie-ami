# prozzie-ami

Project to construct Prozzie Marketplace AMI

## AMI and template creation

  1. [Configure your AWS credentials on your CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html)
  At least you need the following permissions
  attached to your access keys:
  ```json
  {
      "Version": "2012-10-17",
      "Statement": [
          {
              "Effect": "Allow",
              "Action": [
                  "ec2:AttachVolume",
                  "ec2:AuthorizeSecurityGroupIngress",
                  "ec2:CopyImage",
                  "ec2:CreateImage",
                  "ec2:CreateKeypair",
                  "ec2:CreateSecurityGroup",
                  "ec2:CreateSnapshot",
                  "ec2:CreateTags",
                  "ec2:CreateVolume",
                  "ec2:DeleteKeyPair",
                  "ec2:DeleteSecurityGroup",
                  "ec2:DeleteSnapshot",
                  "ec2:DeleteVolume",
                  "ec2:DeregisterImage",
                  "ec2:DescribeImageAttribute",
                  "ec2:DescribeImages",
                  "ec2:DescribeInstances",
                  "ec2:DescribeRegions",
                  "ec2:DescribeSecurityGroups",
                  "ec2:DescribeSnapshots",
                  "ec2:DescribeSubnets",
                  "ec2:DescribeTags",
                  "ec2:DescribeVolumes",
                  "ec2:DetachVolume",
                  "ec2:GetPasswordData",
                  "ec2:ModifyImageAttribute",
                  "ec2:ModifyInstanceAttribute",
                  "ec2:ModifySnapshotAttribute",
                  "ec2:RegisterImage",
                  "ec2:RunInstances",
                  "ec2:StopInstances",
                  "ec2:TerminateInstances"
              ],
              "Resource": "*"
          }
      ]
  }
```
2. Go to project folder
3. Execute:
```
make
```
At the end of execution you will have in standard output the generated AMI ID.

## Design

This project defines two process on Prozzie AMI:

1. Provisioning: AMI creation process. In this phase, everything is executed BEFORE AMI creation.

2. Bootstrapping: Instance configuration process. In this phase, everything is
executed AFTER AMI creation, when instance has been launched and it's running
for production.

Packer executes provisioning phase using chef cookbooks defined in
`cookbooks/provision` directory.
Cloud-init (that is configured in provisioning phase), executes bootstrapping
phase using chef cookbooks defined in `cookbooks/bootstrap` directory.

Only chef-solo is used, it isn't necessary to use a chef server.
