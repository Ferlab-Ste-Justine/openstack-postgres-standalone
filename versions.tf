terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "= 1.51.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "= 3.4.3"
    }
    template = {
      source  = "hashicorp/template"
      version = "= 2.2.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "= 3.4.0"
    }
  }
  required_version = ">= 0.14"
}
