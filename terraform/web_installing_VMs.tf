resource "yandex_compute_instance" "webVM" {
    count       = 2
    name        = "webvm${count.index + 1}"
    hostname    = "webvm${count.index + 1}"
    platform_id = var.CPU
    #zone        = var.YaZone
    zone        = element([var.YaZone_b, var.YaZone_d], count.index)

    resources {
        cores         = 2
        memory        = 2
        core_fraction = 20
    }

    boot_disk {
        initialize_params {
        image_id    = var.IMG
        size        = 20
        type        = "network-hdd"
        }
    }

    network_interface {
        index               = 1
        #subnet_id          = yandex_vpc_subnet.private_subnet.id
        subnet_id           = element([yandex_vpc_subnet.private_subnet1.id, yandex_vpc_subnet.private_subnet2.id], count.index)
        security_group_ids  = [yandex_vpc_security_group.private_VMs.id]
        # nat                 = true
        ip_address         = element(["10.129.1.10", "10.130.1.20"], count.index) 
    }

    metadata = {
        # foo       = "bar"
        # ssh-keys  = "v3ll:${file("C:\Users\valen\Yandex terraform\rsa_tera.pub")}"
        user-data   = "${file("/root/fops-sysadm-diplom/terraform/cloud-conf.yaml")}"
    }
}

#Target group
resource "yandex_alb_target_group" "target_webVM" {
    name = "target-webvm"
    target {
        subnet_id   = yandex_vpc_subnet.private_subnet1.id
        ip_address  = yandex_compute_instance.webVM[0].network_interface.0.ip_address
    }

    target {
        subnet_id   = yandex_vpc_subnet.private_subnet2.id
        ip_address  = yandex_compute_instance.webVM[1].network_interface.0.ip_address
    }
}

#Backend group
resource "yandex_alb_backend_group" "backend_webVM" {
    name = "backend-webvm"
    http_backend {
        name                = "web-http-backend"
        weight              = 1
        port                = 80
        target_group_ids    = [yandex_alb_target_group.target_webVM.id]
    load_balancing_config {
        panic_threshold      = 50
    }
    healthcheck {
        timeout                 = "10s"
        interval                = "2s"
        healthy_threshold       = 10
        unhealthy_threshold     = 15
        healthcheck_port        = 80
        http_healthcheck {
            path = "/"
        }
    }
  }
}

#HTTP router
resource "yandex_alb_http_router" "http_router" {
    name      = "web-http-router"
}

resource "yandex_alb_virtual_host" "my_virtual_host" {
    name      = "my-virtual-host"
    http_router_id = yandex_alb_http_router.http_router.id
    route {
        name = "my-route"
        http_route {
            http_match {
                path {
                    exact = "/"
                }
            }
            http_route_action {
                backend_group_id = yandex_alb_backend_group.backend_webVM.id
                timeout = "3s"
            }
        }
    }
}

# Load balance
resource "yandex_alb_load_balancer" "balance_webVM" {
    name = "load-balancer-webvm"
    network_id = yandex_vpc_network.my_vpc.id
    
    allocation_policy {
        location {
            zone_id   = var.YaZone_a
            subnet_id = yandex_vpc_subnet.public_subnet.id
        }
    }
    
    listener {
        name = "my-listener"
        endpoint {
            address {
                external_ipv4_address {
                }
            }
            ports = [ 80 ]
        } 

        http {
            handler {
                http_router_id = yandex_alb_http_router.http_router.id
            }
        }
    }

    log_options {
        log_group_id = yandex_logging_group.group1.id
    }
}

resource "yandex_logging_group" "group1" {
  name             = "loggi"
  folder_id        = var.yandexIDF
  retention_period = "3h"
}

##### bastion host
resource "yandex_compute_instance" "bastion_host" {
    name        = "bastion-host"
    hostname    = "bastion-host"
    platform_id = var.CPU
    zone        = var.YaZone_a

    resources {
        cores         = 2
        memory        = 2
        core_fraction = 20
    }

    boot_disk {
        initialize_params {
            image_id = var.IMG
            size     = 20
            type     = "network-hdd"
        }
    }

    network_interface {
        subnet_id          = yandex_vpc_subnet.public_subnet.id
        nat                = true
        security_group_ids = [yandex_vpc_security_group.bastion_host.id]
        ip_address         = "10.128.1.100"
    }

    metadata = {
        user-data = "${file("/root/fops-sysadm-diplom/terraform/cloud-conf.yaml")}"
    }
}

