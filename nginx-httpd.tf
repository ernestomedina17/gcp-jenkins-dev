data "google_compute_address" "mariana" {
  name = "mariana"
}

resource "google_compute_instance" "nginx-httpd" {
  name         = "nginx-httpd"
  machine_type = "g1-small"
  tags = ["web"]

  boot_disk {
    initialize_params {
      image = "rhel7-ansible"
    }
  }

  network_interface {
    network = "default"

    access_config {
       nat_ip = data.google_compute_address.mariana.address
       # public_ptr_domain_name = "mariannmiranda.com"    Wait 24 hours and try again
    }
  }

  metadata = {
    Name     = "OS Login for svc accounts"
    enable-oslogin = "TRUE"
  }

  provisioner "remote-exec" {
    inline = ["echo 'running ansible playbook'"]

    connection {
      type        = "ssh"
      user        = var.SSH_USERNAME
      private_key = file(var.private_key_path)
      host        = data.google_compute_address.mariana.address 
    }
  }
  provisioner "local-exec" {
    command = "ansible-playbook -u '${var.SSH_USERNAME}' -i '${data.google_compute_address.mariana.address},' --private-key ${var.private_key_path} -e 'public_ip=${data.google_compute_address.mariana.address}' -e 'jenkins_ip=${google_compute_instance.jenkins-dev.network_interface.0.network_ip}' nginx-httpd.yml"
  }
}

