resource "random_string" "postgres_password" {
  length = 20
  special = false
}

locals {
  postgres_password = var.postgres_password != "" ? var.postgres_password : random_string.postgres_password.result
  postgres_params = "-c ssl=on -c ssl_cert_file=/opt/pg.pem -c ssl_key_file=/opt/pg.key ${var.postgres_params}"
  block_devices = var.image_source.volume_id != "" ? [{
    uuid                  = var.image_source.volume_id
    source_type           = "volume"
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = false
  }] : []
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
  security_group_ids = [openstack_networking_secgroup_v2.postgres_server.id]
  admin_state_up = true
}

resource "openstack_compute_instance_v2" "postgres" {
  name            = var.namespace == "" ? "postgres" : "postgres-${var.namespace}"
  image_id        = var.image_source.image_id != "" ? var.image_source.image_id : null
  flavor_id       = var.flavor_id
  key_pair        = var.keypair_name
  user_data = data.template_cloudinit_config.postgres_config.rendered

  network {
    port = openstack_networking_port_v2.postgres.id
  }

  dynamic "block_device" {
    for_each = local.block_devices
    content {
      uuid                  = block_device.value["uuid"]
      source_type           = block_device.value["source_type"]
      boot_index            = block_device.value["boot_index"]
      destination_type      = block_device.value["destination_type"]
      delete_on_termination = block_device.value["delete_on_termination"]
    }
  }

  lifecycle {
    ignore_changes = [
      user_data,
    ]
  }
}