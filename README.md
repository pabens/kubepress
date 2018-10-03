# kubepress

Wordpress on AWS Demo

* create a 2 replica wordpress instance
* using an in-cluster mariadb
* behind an ELB
* on an AWS EKS cluster with 2 worker nodes managed by terraform

# Requirements

The following must be installed on your local machine...

* aws-cli
* aws account credentials
* kubectl
* helm

These will be installed by [the installer script](scripts/travis-installer) if running on [travis](.travis.yaml).

# tl;dr

create a cluster and a blog...

```
make kubepress
```

destroy everything...

```
make destroy
```

# Makefile

Everything is orchestrated via the [Makefile](Makefile) including creation and destruction of the cluster and application installs.

# AWS EKS Cluster

This project uses [terraform](https://www.terraform.io/) to create an AWS EKS Control Plane and a 2 node worker pool. This is managed by terraform. More details are available in the [terraform](terraform/) directory.

Once the cluster control plane is available, the AWS Auth config map must be added in order to allow worker nodes to successfully join the cluster.

# Helm

The application will be installed and managed by [helm](https://helm.sh/). Once the cluster is ready, the helm tiller is installed along with a [service account and an RBAC role binding](resources/tiller/) granting admin permissions to the service account.

# Storage

The WordPress helm chart uses persistent volume claims for both the wordpress instances and the mariadb database. Once the cluster is ready, a [default storage class](resources/storage/) for the disk provisioner is created to allow EBS GP2 disks to be automatically provisioned to fulfill these claims.

# WordPress Chart

The application install uses the stable [WordPress Chart](https://github.com/helm/charts/tree/master/stable/wordpress). Additional values used by the install are provided via the custom [values.yaml](values.yaml) file.

# kubectl config

You can manually get the cluster kubeconfig by running....

```
aws eks update-kubeconfig --name kubepress
```

# TODO

Improvements and things to add...

* The `terraform destroy` fails when there is a kubernetes-managed load balancer still active in the VPC. The orphaned ELB must then be manually removed.
* Replace the load balancer with an ingress controller, cert-manager and external-dns.
* Add an [Ark](https://github.com/heptio/ark) service to the cluster to provide backup of the service and its persistent disks.
* Use an external RDS DB via the chart settings in [values-external-db.yaml](values-external-db.yaml).
* Add pod anti-affinity annotations to ensure wordpress pods spread properly across worker nodes.
* Add resource requests/limits.
* Add remote state to terraform or save travis artifacts to S3
