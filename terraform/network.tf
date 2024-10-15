######## Cеть
resource "yandex_vpc_network" "my_vpc" {
    name            = "my-vpc"
}

resource "yandex_vpc_subnet" "public_subnet" {
    name            = "public-subnet"
    v4_cidr_blocks  = ["10.128.1.0/24"]
    zone            = var.YaZone_a
    network_id      = "${yandex_vpc_network.my_vpc.id}"
}

resource "yandex_vpc_subnet" "private_subnet1" {
    name            = "private-subnet1"
    v4_cidr_blocks  = ["10.129.1.0/24"]
    zone            = var.YaZone_b
    network_id      = "${yandex_vpc_network.my_vpc.id}"
}

resource "yandex_vpc_subnet" "private_subnet2" {
    name            = "private-subnet2"
    v4_cidr_blocks  = ["10.130.1.0/24"]
    zone            = var.YaZone_d
    network_id      = "${yandex_vpc_network.my_vpc.id}"
}

####### Security Groups
resource "yandex_vpc_security_group" "bastion_host" {
    name            = "Bastion-host"
    description     = "access to the VM "
    network_id      = "${yandex_vpc_network.my_vpc.id}"
    
    egress {
        description     = "Allow all outbound traffic"
        v4_cidr_blocks  = ["0.0.0.0/0"]
        protocol        = "ANY"
    }

    ingress {
        description     = "Allow SSH from anywhere"
        protocol        = "TCP"
        port            = 22
        v4_cidr_blocks  = ["0.0.0.0/0"]
    }

        ingress {
        description = "Allow ICMP (Ping) from anywhere"
        protocol    = "ICMP"
        v4_cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description     = "proxy"
        protocol        = "TCP"
        port            = 3128
        v4_cidr_blocks  = ["10.128.1.0/24", "10.129.1.0/24", "10.130.1.0/24"]
    }

}

resource "yandex_vpc_security_group" "private_VMs" {
    name            = "private-VMs"
    description     = "Security group for private VMs"
    network_id      = "${yandex_vpc_network.my_vpc.id}"

    egress {
        description     = "Allow all outbound traffic"
        v4_cidr_blocks  = ["0.0.0.0/0"]
        protocol        = "ANY"
    }

    ingress {
        description         = "Allow SSH from Bastion Host"
        protocol            = "TCP"
        port                = 22
        security_group_id   = yandex_vpc_security_group.bastion_host.id
    }
  
    ingress {
        description    = "Allow HTTP traffic"
        protocol       = "TCP"
        port           = 80
        v4_cidr_blocks = ["10.128.1.0/24", "10.129.1.0/24", "10.130.1.0/24"]
    }

        ingress {
        description    = "Allow HTTPS traffic"
        protocol       = "TCP"
        port           = 443
        v4_cidr_blocks = ["10.128.1.0/24", "10.129.1.0/24", "10.130.1.0/24"]
    }

    ingress {
        description    = "Allow Prometheus to access Node Exporter"
        protocol       = "TCP"
        port           = 9100
        v4_cidr_blocks = ["10.128.1.0/24", "10.129.1.0/24", "10.130.1.0/24"]
    }
    
    ingress {
        description    = "All9ow Grafana access to Prometheus"
        protocol       = "TCP"
        port           = 9090
        v4_cidr_blocks = ["10.128.1.0/24", "10.129.1.0/24", "10.130.1.0/24"] 
    }

        ingress {
        description    = "All9ow Grafana"
        protocol       = "TCP"
        port           = 3000
        v4_cidr_blocks = ["10.128.1.0/24", "10.129.1.0/24", "10.130.1.0/24"] 
    }

    ingress {
        description    = "All9ow Grafana"
        protocol       = "TCP"
        port           = 5601
        v4_cidr_blocks = ["10.128.1.0/24", "10.129.1.0/24", "10.130.1.0/24"] 
    }

    ingress {
        description    = "All9ow filebeat access to Elasticsearch to kibana"
        protocol       = "TCP"
        port           = 9200
        v4_cidr_blocks = ["10.128.1.0/24", "10.129.1.0/24", "10.130.1.0/24"]
    }

    ingress {
        description = "Allow ICMP (Ping) from anywhere"
        protocol    = "ICMP"
        v4_cidr_blocks = ["10.128.1.0/24", "10.129.1.0/24", "10.130.1.0/24"]
    }

    ingress {
        description    = "Allow Nginx Log Exporter access to Prometheus"
        protocol       = "TCP"
        port           = 4040
        v4_cidr_blocks = ["10.128.1.0/24", "10.129.1.0/24", "10.130.1.0/24"] 
    }

}
