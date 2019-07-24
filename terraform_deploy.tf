#Deploy to CSP
# GCP Provider
provider "google" {
  region      = "${var.region}"
  project     = "${var.project_name}"
  credentials = "${file("${var.credentials_file_path}")}"
  }
resource "google_compute_instance" "docker" {
  count = 1

  name         = "tf-docker-${count.index}"
  machine_type = "f1-micro"
  zone         = "${var.region_zone}"
  tags         = ["docker-node"]

  boot_disk {
    initialize_params {
      image = "kelvinxue1107/ss-docker"
    }
  }

  network_interface {
    network = "default"

    access_config {
      # Ephemeral
    }
  }

  metadata {
    ssh-keys = "root:${file("${var.public_key_path}")}"
  }


  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "root"
      private_key = "${file("${var.private_key_path}")}"
      agent       = false
    }

    inline = [
      "sudo curl -sSL https://get.docker.com/ | sh",
      "sudo usermod -aG docker `echo $USER`",
      "sudo docker run -d -p 80:80 nginx"
    ]
  }

  service_account {
    scopes = ["https://www.googleapis.com/auth/compute.readonly"]
  }
}

resource "google_compute_firewall" "default" {
  name    = "hpc-backup"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80"]
    ports    = ["443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["docker-node"]
}
provider "aws" {
    version = "~> 2.0"
    region = "us-west-1"
  }
resource "" 
provider "azurerm" {
  version = "=1.28.0"
}
resource "azurerm_container_group" "ss-docker" {
  name                = "ss-docker-bbr"
  location            = "${azurerm_resource_group.example.location}"
  resource_group_name = "${azurerm_resource_group.example.name}"
  ip_address_type     = "public"
  dns_name_label      = "aci-label"
  os_type             = "Linux"

  container {
    name   = "ss-bbr"
    image  = "dockerhub.com/kelvinxue1107/s4bbr:latest"
    cpu    = "0.5"
    memory = "1.5"

    ports {
      port     = 443
      protocol = "TCP"
    }
  }