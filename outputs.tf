output "internal_ips" {
  description = "Private IPs of the instances."
  value = {
    for h in concat(
      yandex_compute_instance.lb,
      yandex_compute_instance.backend,
      yandex_compute_instance.db
    ) :
    h.hostname => h.network_interface.0.ip_address
  }
}
output "external_ips" {
  description = "Public IPs of the instances."
  value = {
    for h in concat(
      yandex_compute_instance.lb,
      yandex_compute_instance.backend,
      yandex_compute_instance.db
    ) :
    h.hostname => h.network_interface.0.nat_ip_address
  }
}
