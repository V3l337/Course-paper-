##### Instaling Prometheus
resource "yandex_compute_instance" "Prometheus_host" {
    name        = "vm-prometheus"
    hostname    = "vm-prometheus"
    platform_id = var.CPU
    zone        = var.YaZone_b

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
        subnet_id          = yandex_vpc_subnet.private_subnet1.id
        # nat                = true
        security_group_ids = [yandex_vpc_security_group.private_VMs.id]
        ip_address         = "10.129.1.11"
    }

    metadata = {
        user-data = "${file("/root/fops-sysadm-diplom/terraform/cloud-conf.yaml")}"
    }
}

##### Instaling Elasticsearch
resource "yandex_compute_instance" "Elasticsearch_host" {
    name        = "vm-elasticsearch"
    hostname    = "vm-elasticsearch"
    platform_id = var.CPU
    zone        = var.YaZone_d

    resources {
        cores         = 4
        memory        = 4
        core_fraction = 20
    }

    boot_disk {
        initialize_params {
            image_id = var.IMG
            size     = 50
            type     = "network-hdd"
        }
    }

    network_interface {
        subnet_id          = yandex_vpc_subnet.private_subnet2.id
        # nat                = true
        security_group_ids = [yandex_vpc_security_group.private_VMs.id]
        ip_address         = "10.130.1.21"
    }

    metadata = {
        user-data = "${file("/root/fops-sysadm-diplom/terraform/cloud-conf.yaml")}"
    }
}

##### Grafana
resource "yandex_compute_instance" "Grafana_host" {
    name        = "vm-grafana"
    hostname    = "vm-grafana"
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
        #security_group_ids = [yandex_vpc_security_group.private_VMs.id]
        ip_address         = "10.128.1.101"
    }

    metadata = {
        user-data = "${file("/root/fops-sysadm-diplom/terraform/cloud-conf.yaml")}"
    }
}

##### Kibana
resource "yandex_compute_instance" "Kibana_host" {
    name        = "vm-kibana"
    hostname    = "vm-kibana"
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
        #security_group_ids = [yandex_vpc_security_group.private_VMs.id]
        ip_address         = "10.128.1.102"
    }

    metadata = {
        user-data = "${file("/root/fops-sysadm-diplom/terraform/cloud-conf.yaml")}"
    }
}