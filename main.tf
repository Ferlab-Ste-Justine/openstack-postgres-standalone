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
        tls_key = var.postgres_tls_key
        tls_certificate = var.postgres_tls_certificate
        postgres_user = var.postgres_user
      }
    )
  }
}

resource "openstack_compute_instance_v2" "postgres" {
  name            = var.namespace == "" ? "postgres" : "postgres-${var.namespace}"
  image_id        = var.image_id
  flavor_id       = var.flavor_id
  key_pair        = var.keypair_name
  security_groups = var.security_groups
  user_data = data.template_cloudinit_config.postgres_config.rendered

  network {
    name = var.network_name
  }
}