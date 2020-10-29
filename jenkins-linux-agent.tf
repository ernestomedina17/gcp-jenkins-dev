resource "google_compute_instance" "jenkins-linux-agent" {
  name         = "jenkins-linux-agent"
  machine_type = "g1-small"
  tags = ["jenkins-agent"]

  boot_disk {
    initialize_params {
      image = "rhel7-ansible"
    }
  }

  network_interface {
    network = "default"

    access_config {}
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
      host        = google_compute_instance.jenkins-linux-agent.network_interface.0.access_config.0.nat_ip
    }
  }

  provisioner "local-exec" {
    command = "ansible-playbook --vault-password-file ~/secret -u '${var.SSH_USERNAME}' -i '${google_compute_instance.jenkins-linux-agent.network_interface.0.access_config.0.nat_ip},' --private-key ${var.private_key_path} -e 'public_ip=${google_compute_instance.jenkins-linux-agent.network_interface.0.access_config.0.nat_ip}' jenkins-linux-agent.yml"
  }
}

