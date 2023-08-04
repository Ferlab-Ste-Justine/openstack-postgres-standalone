# About

This package is a terraform module to provision a standalone postgres instance, not attached to any container orchestration.

Postgres will run on a background container set to always restart.

The postgres instance will run over tls and expect to receive the credentials of a certificate authority (can be self-signed) to sign its credentials.

Additionally, security groups are generated with this module and the following security groups are returned as output by the module: client, bastion.

Any machine wishing to connect to the postgres server (as a postgres or ssh client) will need to have the corresponding security groups assigned to it.

It is assumed that the postgres image used has the following characteristics (which the official postgres images will have):

- The container command is passed as parameters to the **postgres** entrypoint
- The **PGDATA** environment variable indicates where postgres should store its database files
- The **POSTGRES_USER** environment variable indicates the user that will be used to access the database
- The **POSTGRES_PASSWORD** environment variable indicates the password that will be used for authentication when accessing the database
- The **POSTGRES_DB** environment variable indicates the name of the database that will be accessed
- The image has a user named "postgres" and the database will run as that user

# Usage

## Variables

The module takes the following variables as input:

- **name**: Name to give to the vm, its port and the prefix of security groups
- **image_source**: Source of the image to provision the postgres node on. It takes the following keys (only one of the two fields should be used, the other one should be empty):
  - **image_id**: Id of the image to associate with a vm that has local storage
  - **volume_id**: Id of a volume containing the os to associate with the vm
- **flavor_id**: The id of the vm flavor the postgres node will have.
- **network_id**: Id of the network to connect the postgres node
- **keypair_name**: Name of the keypair that will be used to ssh on the postgres node
- **extra_security_group_ids**: List of extra security groups to assign beyond the one already assigned by the module (defaults to `[]`)
- **postgres_image**: Docker image to launch the postgres container with
- **postgres_params**: Additional command line parameters to pass to postgres when launching it
- **postgres_data**: Path where to store the configuration and data files (defaults to `/data`)
- **postgres_user**: User that will be used to access the database
- **postgres_database**: Name of the database that will be accessed
- **postgres_password**: Password that will be used to access the database. If omitted, a random password is generated

The following input variables are also required for postgres' certificate for tls communication:
- **key_length**: Length of the certificate's RSA key (defaults to 4096)
- **certificate_validity_period**: How long it takes for the certificate to expire in hours (defaults to 100 years)
- **certificate_early_renewal_period**: How long Terraform should wait before reprovisioning the certificate (defaults to 99 years)
- **organization**: Organization the certificate is for (defaults to "ferlab")
- **domains**: Dns names the database will be accessed under
- **ca**: The certificate authority that will sign the db's certificate. Should have the following keys: key, key_algorithm, certificate

The following arguments will be pre-fixed to **postgres_params**: ```-c ssl=on -c ssl_cert_file=/opt/pg.pem -c ssl_key_file=/opt/pg.key```

## Output

The module outputs the following variables as output:
- **id**: ID of the postgres vm
- **ip**: Ip of the postgres vm on the network it was assigned to
- **db_password**: Database password used to authenticate 
against the postgres database
- **groups**: Is a map with the following 2 keys: client, bastion. Each is a resource of type **openstack_networking_secgroup_v2** that allows to connect to the postgres server as a postgres client and a bastion respectively

## Example

Here is an example of how the module might be used: 

```
resource "tls_private_key" "ca" {
  algorithm   = "RSA"
  rsa_bits = 4096
}

resource "tls_self_signed_cert" "ca" {
  key_algorithm   = tls_private_key.ca.algorithm
  private_key_pem = tls_private_key.ca.private_key_pem

  subject {
    common_name  = "myca"
  }

  validity_period_hours = 100*365*24
  early_renewal_hours = 99*365*24

  allowed_uses = [
    "digital_signature",
    "key_encipherment",
    "cert_signing",
  ]

  is_ca_certificate = true
}

module "postgres" {
  source = "git::https://github.com/Ferlab-Ste-Justine/openstack-postgres-standalone.git"
  name = "test-qa-postgres"
  image_source = {
    image_id = module.ubuntu_bionic_image.id
    volume_id = ""
  }
  flavor_id = module.reference_infra.flavors.micro.id
  keypair_name = openstack_compute_keypair_v2.bastion_internal_keypair.name
  network_id = module.reference_infra.networks.internal.id
  postgres_image = "postgres:12.3"
  postgres_user = "someadmin"
  postgres_database = "somedb"
  domains = ["postgres-qa"]
  ca = {
    key = tls_private_key.ca.private_key_pem
    key_algorithm = tls_private_key.ca.algorithm
    certificate = tls_self_signed_cert.ca.cert_pem
  }
}
```

# Gotcha

To safeguard against potential outages and loss of data, changes to the server's user data will be ignored without reprovisioning.

To reprovision a new instance with changes to the following parameters, the module should be explicitly deleted and re-created:
- postgres_image
- postgres_params
- postgres_data
- postgres_user
- postgres_password
- postgres_database