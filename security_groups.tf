resource "openstack_networking_secgroup_v2" "postgres_server" {
  name                 = "${var.name}-server"
  description          = "Security group for postgres server"
  delete_default_rules = true
}

resource "openstack_networking_secgroup_v2" "postgres_client" {
  name                 = "${var.name}-client"
  description          = "Security group for the clients connecting to postgres server"
  delete_default_rules = true
}

resource "openstack_networking_secgroup_v2" "postgres_bastion" {
  name                 = "${var.name}-bastion"
  description          = "Security group for the bastion connecting to postgres server"
  delete_default_rules = true
}

locals {
  bastion_group_ids = var.bastion_security_group_id != "" ? [var.bastion_security_group_id, openstack_networking_secgroup_v2.postgres_bastion.id] : [openstack_networking_secgroup_v2.postgres_bastion.id]
}

//Allow all outbound traffic for server and bastion
resource "openstack_networking_secgroup_rule_v2" "postgres_server_outgoing_v4" {
  direction         = "egress"
  ethertype         = "IPv4"
  security_group_id = openstack_networking_secgroup_v2.postgres_server.id
}

resource "openstack_networking_secgroup_rule_v2" "postgres_server_outgoing_v6" {
  direction         = "egress"
  ethertype         = "IPv6"
  security_group_id = openstack_networking_secgroup_v2.postgres_server.id
}

resource "openstack_networking_secgroup_rule_v2" "postgres_bastion_outgoing_v4" {
  direction         = "egress"
  ethertype         = "IPv4"
  security_group_id = openstack_networking_secgroup_v2.postgres_bastion.id
}

resource "openstack_networking_secgroup_rule_v2" "postgres_bastion_outgoing_v6" {
  direction         = "egress"
  ethertype         = "IPv6"
  security_group_id = openstack_networking_secgroup_v2.postgres_bastion.id
}

//Allow port 22 traffic from the bastion
resource "openstack_networking_secgroup_rule_v2" "internal_ssh_access" {
  for_each          = { for idx, id in local.bastion_group_ids : idx => id }
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_group_id   = each.value
  security_group_id = openstack_networking_secgroup_v2.postgres_server.id
}

//Allow port 22 traffic on the bastion
resource "openstack_networking_secgroup_rule_v2" "external_ssh_access" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.postgres_bastion.id
}

//Allow port 5432 traffic from the client
resource "openstack_networking_secgroup_rule_v2" "client_postgres_access" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 5432
  port_range_max    = 5432
  remote_group_id   = openstack_networking_secgroup_v2.postgres_client.id
  security_group_id = openstack_networking_secgroup_v2.postgres_server.id
}

//Allow clients and bastion to use icmp
resource "openstack_networking_secgroup_rule_v2" "client_icmp_access_v4" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_group_id   = openstack_networking_secgroup_v2.postgres_client.id
  security_group_id = openstack_networking_secgroup_v2.postgres_server.id
}

resource "openstack_networking_secgroup_rule_v2" "client_icmp_access_v6" {
  direction         = "ingress"
  ethertype         = "IPv6"
  protocol          = "ipv6-icmp"
  remote_group_id   = openstack_networking_secgroup_v2.postgres_client.id
  security_group_id = openstack_networking_secgroup_v2.postgres_server.id
}

resource "openstack_networking_secgroup_rule_v2" "bastion_icmp_access_v4" {
  for_each          = { for idx, id in local.bastion_group_ids : idx => id }
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_group_id   = each.value
  security_group_id = openstack_networking_secgroup_v2.postgres_server.id
}

resource "openstack_networking_secgroup_rule_v2" "bastion_icmp_access_v6" {
  for_each          = { for idx, id in local.bastion_group_ids : idx => id }
  direction         = "ingress"
  ethertype         = "IPv6"
  protocol          = "ipv6-icmp"
  remote_group_id   = each.value
  security_group_id = openstack_networking_secgroup_v2.postgres_server.id
}

resource "openstack_networking_secgroup_rule_v2" "bastion_external_icmp_access" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.postgres_bastion.id
}