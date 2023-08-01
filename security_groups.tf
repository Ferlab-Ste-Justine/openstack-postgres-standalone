
resource "openstack_networking_secgroup_v2" "postgres_server" {
  name                 = "postgres-${var.namespace}"
  description          = "Security group for postgres server"
  delete_default_rules = true
}

resource "openstack_networking_secgroup_v2" "postgres_client" {
  name                 = "postgres-client-${var.namespace}"
  description          = "Security group for the clients connecting to postgres server"
  delete_default_rules = true
}

resource "openstack_networking_secgroup_v2" "postgres_bastion" {
  name                 = "postgres-bastion-${var.namespace}"
  description          = "Security group for the bastion connecting to etcd members"
  delete_default_rules = true
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
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_group_id  = openstack_networking_secgroup_v2.postgres_bastion.id
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
  remote_group_id  = openstack_networking_secgroup_v2.postgres_client.id
  security_group_id = openstack_networking_secgroup_v2.postgres_server.id
}

//Allow clients and bastion to use icmp
resource "openstack_networking_secgroup_rule_v2" "client_icmp_access_v4" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_group_id  = openstack_networking_secgroup_v2.postgres_client.id
  security_group_id = openstack_networking_secgroup_v2.postgres_server.id
}

resource "openstack_networking_secgroup_rule_v2" "client_icmp_access_v6" {
  direction         = "ingress"
  ethertype         = "IPv6"
  protocol          = "ipv6-icmp"
  remote_group_id  = openstack_networking_secgroup_v2.postgres_client.id
  security_group_id = openstack_networking_secgroup_v2.postgres_server.id
}

resource "openstack_networking_secgroup_rule_v2" "bastion_icmp_access_v4" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_group_id  = openstack_networking_secgroup_v2.postgres_bastion.id
  security_group_id = openstack_networking_secgroup_v2.postgres_server.id
}

resource "openstack_networking_secgroup_rule_v2" "bastion_icmp_access_v6" {
  direction         = "ingress"
  ethertype         = "IPv6"
  protocol          = "ipv6-icmp"
  remote_group_id  = openstack_networking_secgroup_v2.postgres_bastion.id
  security_group_id = openstack_networking_secgroup_v2.postgres_server.id
}

resource "openstack_networking_secgroup_rule_v2" "bastion_external_icmp_access" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.postgres_bastion.id
}