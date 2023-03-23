terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = ">= 1.0.0, < 2.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0.0, < 4.0.0"
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
