data "yandex_compute_image" "ubuntu2404" {
  family = "ubuntu-2404-lts-oslogin"
}
resource "yandex_vpc_network" "default" {
  name = var.project
}
resource "yandex_vpc_gateway" "default" {
  name = var.project
  shared_egress_gateway {}
}
resource "yandex_vpc_route_table" "default" {
  name       = var.project
  network_id = yandex_vpc_network.default.id
  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.default.id
  }
}
resource "yandex_vpc_subnet" "default" {
  name           = "${var.project}-${var.zone}"
  network_id     = yandex_vpc_network.default.id
  v4_cidr_blocks = ["10.130.0.0/24"]
  route_table_id = yandex_vpc_route_table.default.id
}
resource "yandex_compute_instance" "lb" {
  count       = 1
  name        = format("%s-%02d", "${var.project}", count.index + 1)
  hostname    = format("%s-%02d", "${var.project}", count.index + 1)
  platform_id = "standard-v3"
  resources {
    cores         = 2
    memory        = 1
    core_fraction = 20
  }
  scheduling_policy { preemptible = true }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu2404.id
      size     = 20
      type     = "network-hdd"
    }
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.default.id
    nat       = true
  }
  metadata = local.yandex_compute_instance_metadata
}
resource "yandex_compute_instance" "backend" {
  count       = 2
  name        = format("%s-%02d", "${var.project}-backend", count.index + 1)
  hostname    = format("%s-%02d", "${var.project}-backend", count.index + 1)
  platform_id = "standard-v3"
  resources {
    cores         = 2
    memory        = 1
    core_fraction = 20
  }
  scheduling_policy { preemptible = true }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu2404.id
      size     = 20
      type     = "network-hdd"
    }
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.default.id
    nat       = false
  }
  metadata = local.yandex_compute_instance_metadata
}
resource "yandex_compute_instance" "db" {
  count       = 1
  name        = format("%s-%02d", "${var.project}-db", count.index + 1)
  hostname    = format("%s-%02d", "${var.project}-db", count.index + 1)
  platform_id = "standard-v3"
  resources {
    cores         = 2
    memory        = 1
    core_fraction = 20
  }
  scheduling_policy { preemptible = true }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu2404.id
      size     = 20
      type     = "network-hdd"
    }
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.default.id
    nat       = false
  }
  metadata = local.yandex_compute_instance_metadata
}
resource "local_file" "inventory" {
  filename = "${path.root}/inventory.yml"
  content = templatefile("${path.module}/inventory.tftpl", {
    ssh_username = var.ssh_username,
    ssh_key_file = var.ssh_key_file,
    groups = [
      {
        name  = "lb"
        hosts = yandex_compute_instance.lb
      },
      {
        name     = "backend",
        hosts    = yandex_compute_instance.backend
        jumphost = one(yandex_compute_instance.lb)
      },
      {
        name     = "db"
        hosts    = yandex_compute_instance.db
        jumphost = one(yandex_compute_instance.lb)
      }
    ],
  })
}
