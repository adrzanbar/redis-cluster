resource "openstack_compute_keypair_v2" "keypair" {
  name       = "keypair"
  public_key = "<your public key>"
}

resource "openstack_compute_instance_v2" "rke2-server" {
  name            = "rke2-server"
  flavor_id       = "f1b18649-187d-44ca-856d-3c9644b33da5"
  key_pair        = openstack_compute_keypair_v2.keypair.name
  security_groups = ["default", "<your custom security group>"]

  block_device {
    uuid                  = "7b8d4804-eb56-4fd1-80c6-7840d23d93f3"
    source_type           = "image"
    volume_size           = 20
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
  }

  network {
    name = "main_net"
  }
}

resource "openstack_compute_instance_v2" "rke2-agent" {
  count           = 2
  name            = "rke2-agent-${count.index + 1}"
  flavor_id       = "f1b18649-187d-44ca-856d-3c9644b33da5"
  key_pair        = openstack_compute_keypair_v2.keypair.name
  security_groups = ["default", "<your custom security group>"]

  block_device {
    uuid                  = "7b8d4804-eb56-4fd1-80c6-7840d23d93f3"
    source_type           = "image"
    volume_size           = 20
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
  }

  network {
    name = "main_net"
  }
}