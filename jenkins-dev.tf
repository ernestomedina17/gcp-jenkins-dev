provider "google" {
  # credentials = GOOGLE_APPLICATION_CREDENTIALS
  # project     = CLOUDSDK_CORE_PROJECT
  # region      = CLOUDSDK_COMPUTE_REGIONT
  # zone	= CLOUDSDK_COMPUTE_ZONE
}

resource "google_compute_instance" "nginx-httpd" {
  name         = "nginx-httpd"
  machine_type = "g1-small"
  tags = ["web"]

  boot_disk {
    initialize_params {
      # image = "rhel-cloud/rhel7-ansible"
      image = "rhel7-ansible"
    }
  }

  // Local SSD disk
  # scratch_disk {}

  network_interface {
    network = "default"

    access_config {
      nat_ip = "34.121.97.143"
      public_ptr_domain_name = "mariannmiranda.com"
    }
  }

  metadata = {
    Name     = "OS Login for svc accounts"
    enable-oslogin = "TRUE"
  }

  # metadata_startup_script = "echo hi > /test.txt"

  # service_account {
  #   scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  # }

  provisioner "remote-exec" {
    inline = ["echo 'running ansible playbook'"]

    connection {
      type        = "ssh"
      user        = var.SSH_USERNAME
      private_key = file(var.private_key_path)
      host        = google_compute_instance.nginx-httpd.network_interface.0.access_config.0.nat_ip
    }
  }
  provisioner "local-exec" {
    command = "ansible-playbook -u '${var.SSH_USERNAME}' -i '${var.RESERVED_IP},' --private-key ${var.private_key_path} -e 'public_ip=${var.RESERVED_IP}' nginx-httpd.yml"
  }
}

resource "google_compute_firewall" "default" {
  name    = "web-firewall"
  network = "default"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web"]
}

