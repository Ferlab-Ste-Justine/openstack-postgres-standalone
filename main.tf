resource "random_string" "postgres_password" {
  length = 20
  special = false
}

locals {
  postgres_password = var.postgres_password != "" ? var.postgres_password : random_string.postgres_password.result
  postgres_params = var.postgres_tls_key != "" ? "-c ssl=on -c ssl_cert_file=/opt/pg.pem -c ssl_key_file=/opt/pg.key ${var.postgres_params}" : var.postgres_params
}

data "template_cloudinit_config" "postgres_config" {
  gzip = true
  base64_encode = true
  part {
    content_type = "text/cloud-config"
    content = templatefile(
      "${path.module}/templates/cloud_config.yaml", 
      {
        postgres_orchestration  = templatefile(
            "${path.module}/templates/docker-compose.yml",
            {
                image = var.postgres_image
                params = local.postgres_params
                user = var.postgres_user
                password = local.postgres_password
                database = var.postgres_database
            }
        )
        tls_key = tls_private_key.key.private_key_pem
        tls_certificate = "${tls_locally_signed_cert.certificate.cert_pem}\n${var.ca.certificate}"
        postgres_image = var.postgres_image
      }
    )
  }
}

resource "openstack_networking_port_v2" "postgres" {
  name           = var.namespace == "" ? "postgres" : "postgres-${var.namespace}"
  network_id     = var.network_id
  security_group_ids = var.security_group_ids
  admin_state_up = true
}

resource "openstack_compute_instance_v2" "postgres" {
  name            = var.namespace == "" ? "postgres" : "postgres-${var.namespace}"
  image_id        = var.image_id
  flavor_id       = var.flavor_id
  key_pair        = var.keypair_name
  user_data = data.template_cloudinit_config.postgres_config.rendered

  network {
    port = openstack_networking_port_v2.postgres.id
  }
}