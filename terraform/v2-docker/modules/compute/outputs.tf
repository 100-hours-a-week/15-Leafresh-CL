output "nextjs_instance_ip" {
  value = google_compute_instance.nextjs.network_interface.0.access_config.0.nat_ip
}

output "springboot_instance_private_ip" {
  value = google_compute_instance.springboot.network_interface.0.network_ip
}
