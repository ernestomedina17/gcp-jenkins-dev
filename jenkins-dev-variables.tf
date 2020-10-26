variable "private_key_path" {
  description = "Path to the private SSH key, used to access the instance."
  default     = "~/.ssh/google_compute_engine"
}

variable "ssh_user" {
  description = "SVC which has roles/compute.osAdminLogin to ssh your instance."
  default     = "sa_111568328216108188906"
}
