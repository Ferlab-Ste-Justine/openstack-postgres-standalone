# About

This package is a terraform module to provision a standalone postgres instance, not attached to any container orchestration.

Postgres will run on a background container set to always restart.

It is assumed that the postgres image used has the following characteristics (which the official postgres images will have):

- The container command is passed as parameters to the **postgres** entrypoint
- The **PGDATA** environment variable indicates where postgres should store its database files
- The **POSTGRES_USER** environment variable indicates the user that will be used to access the database
- The **POSTGRES_PASSWORD** environment variable indicates the password that will be used for authentication when accessing the database
- The **POSTGRES_DB** environment variable indicates the name of the database that will be accessed

# Usage

## Variables

The module takes the following variables as input:

- namespace: A string to namespace all the postgres vm name (ie, `postgres-<namespace>`). If this variable is omitted, a namespace suffix will not be added.
- flavor_id: The id of the vm flavor the postgres node will have.
- security_groups: List of security groups to assign to the postgres node. Defaults to `["default"]`
- image_id: ID of the vm image to use to provision the postgres node on
- network_name: Name of the network to connect the postgres node
- keypair_name: Name of the keypair that will be used to ssh on the postgres node
- postgres_image: Docker image to launch the postgres container with
- postgres_params: Additional command line parameters to pass to postgres when launching it
- postgres_user: User that will be used to access the database
- postgres_database: Name of the database that will be accessed
- postgres_password: Password that will be used to access the database. If omitted, a random password is generated

## Output

The module outputs the following variables as output:
- id: ID of the postgres vm
- ip: Ip of the postgres vm on the network it was assigned to
- db_password: Database password used to authenticate against the postgres database

## Example

Here is an example of how the module might be used:

```
#Pre-existing resources we depend on
module "reference_infra" {
  source = "./cqdg-reference-infra"
}

#Default image we assign to all vms
module "ubuntu_bionic_image" {
  source = "./image"
  name = "Ubuntu-Bionic-2020-06-10"
  url = "https://cloud-images.ubuntu.com/releases/bionic/release-20200610.1/ubuntu-18.04-server-cloudimg-amd64.img"
}

#Ssh key that will be used to open an ssh session from the bastion to other machines
resource "openstack_compute_keypair_v2" "bastion_internal_keypair" {
  name = "bastion_internal_keypair"
}

#Provision aidbox database
module "postgres" {
  source = "git::https://github.com/Ferlab-Ste-Justine/openstack-postgres-standalone.git"
  namespace = "aidbox"
  image_id = module.ubuntu_bionic_image.id
  flavor_id = module.reference_infra.flavors.micro.id
  keypair_name = openstack_compute_keypair_v2.bastion_internal_keypair.name
  network_name = module.reference_infra.networks.internal.name
  postgres_image = "aidbox/db:11.1.0"
  postgres_user = "postgres"
  postgres_database = "devbox"
}
```