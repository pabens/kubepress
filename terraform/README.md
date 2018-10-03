# EKS Getting Started Guide Configuration

This is the full configuration from https://www.terraform.io/docs/providers/aws/guides/eks-getting-started.html

See that guide for additional information.

# Description

Creates an EKS cluster control plane and a t2.medium worker node ASG in a VPC in eu-west-1 along with all associated roles and security groups.

## Instance Type

This uses t2.medium as it is the minimum instance size that meets the cluster networking requirements. The t3 instance types are not currently recommended for use with EKS. Note that use of the t2 burstable instance type means heavy utilization may result in CPU credit exhaustion.

# Terraform Resources

Overview of stuff that terraform creates...

## VPC Resources
  * VPC
  * Subnets
  * Internet Gateway
  * Route Table

## EKS Cluster Resources
  * IAM Role to allow EKS service to manage other AWS services
  * EC2 Security Group to allow networking traffic with EKS cluster
  * EKS Cluster

## EKS Worker Nodes Resources
  * IAM role allowing Kubernetes actions to access other AWS services
  * EC2 Security Group to allow networking traffic
  * Data source to fetch latest EKS worker AMI
  * AutoScaling Launch Configuration to configure worker instances
  * AutoScaling Group to launch worker instances


# Additions

The following was added to the [eks-cluster.tf](eks-cluster.tf) terraform configuration to allow cluster provisioning of ELBs

```
resource "aws_iam_service_linked_role" "elasticloadbalancing" {
  aws_service_name = "elasticloadbalancing.amazonaws.com"
}
```
