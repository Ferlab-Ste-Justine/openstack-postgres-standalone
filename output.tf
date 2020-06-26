output id {
  value = openstack_compute_instance_v2.postgres.id
}

output ip {
  value = openstack_compute_instance_v2.postgres.network.0.fixed_ip_v4
}

output db_password {
  value = local.postgres_password
}