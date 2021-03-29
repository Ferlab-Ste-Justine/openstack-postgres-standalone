output id {
  value = openstack_compute_instance_v2.postgres.id
}

output ip {
  value = openstack_networking_port_v2.postgres.all_fixed_ips.0
}

output db_password {
  value = local.postgres_password
}