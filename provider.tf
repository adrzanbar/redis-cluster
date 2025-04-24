# Define required providers
terraform {
  required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 3.0.0"
    }
  }
}

# Configure the OpenStack Provider
provider "openstack" {
  user_name   = "<your user name>"
  tenant_name = "<your tenant name>"
  domain_name = "sistemas_distribuidos"
  auth_url    = "http://keystone.cumulus.ingenieria.uncuyo.edu.ar/v3"
  region      = "RegionOne"
}
