output "webvm_ip" {
  value = [
    yandex_compute_instance.webVM[0].network_interface.0.ip_address, 
    yandex_compute_instance.webVM[1].network_interface.0.ip_address,
    # yandex_compute_instance.webVM[0].network_interface.0.nat_ip_address, 
    # yandex_compute_instance.webVM[1].network_interface.0.nat_ip_address
  ]
}

output "balance_ip" {
  value = yandex_alb_load_balancer.balance_webVM.listener[0].endpoint[0].address[0].external_ipv4_address[0].address
}

output "bastion_ip" {
  value = {
    wan_ip = yandex_compute_instance.bastion_host.network_interface[0].nat_ip_address,
    lan_ip = yandex_compute_instance.bastion_host.network_interface[0].ip_address
  }
}

output "prometrheus_ip" {
  value = {
    lan = yandex_compute_instance.Prometheus_host.network_interface[0].ip_address,
    wan = yandex_compute_instance.Prometheus_host.network_interface[0].nat_ip_address
  }
}

output "elasticsearch_ip" {
  value = {
    lan = yandex_compute_instance.Elasticsearch_host.network_interface[0].ip_address,
    # wan = yandex_compute_instance.Elasticsearch_host.network_interface[0].nat_ip_address
  }
}

output "grafana_ip" {
  value = {
    wan_ip = yandex_compute_instance.Grafana_host.network_interface[0].nat_ip_address,
    lan_ip = yandex_compute_instance.Grafana_host.network_interface[0].ip_address
  }
}

output "kibana_ip" {
  value = {
    wan_ip = yandex_compute_instance.Kibana_host.network_interface[0].nat_ip_address,
    lan_ip = yandex_compute_instance.Kibana_host.network_interface[0].ip_address
  }
}