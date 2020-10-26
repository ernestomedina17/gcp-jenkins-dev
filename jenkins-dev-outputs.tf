output "Webapp_URL" {
  value = "http://${google_compute_instance.nginx-httpd.network_interface.0.access_config.0.nat_ip}"
}
