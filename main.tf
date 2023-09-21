terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

// Terraform должен знать ключ, для выполнения команд по API

// Определение переменной, которую нужно будет задать
variable "do_token" {}

// Установка значения переменной
provider "digitalocean" {
  token = var.do_token
}

resource "digitalocean_droplet" "tf-web-1" {
  image  = "ubuntu-22-04-x64"
  name   = "tf-web-1"
  region = "ams3"
  size   = "s-1vcpu-1gb"
}

resource "digitalocean_droplet" "tf-web-2" {
  image  = "ubuntu-22-04-x64"
  name   = "tf-web-2"
  region = "ams3"
  size   = "s-1vcpu-1gb"
}

resource "digitalocean_database_cluster" "tf-db-1" {
  name       = "tf-db-1"
  engine     = "pg"
  version    = "15"
  size       = "db-s-1vcpu-1gb"
  region     = "ams3"
  node_count = 1
}

resource "digitalocean_loadbalancer" "loadbalancer" {
  name   = "lb-1"
  region = "ams3"

  forwarding_rule {
    entry_port     = 80
    entry_protocol = "http"

    target_port     = 8080
    target_protocol = "http"
  }

  healthcheck {
    port     = 22
    protocol = "tcp"
  }

  droplet_ids = [
    digitalocean_droplet.tf-web-1.id,
    digitalocean_droplet.tf-web-2.id,
  ]
}

resource "digitalocean_project" "tf-playground" {
  name        = "tf-playground"
  description = "A project to represent development resources."
  purpose     = "Web Application"
  environment = "Development"
  resources   = [
    digitalocean_droplet.tf-web-1.urn,
    digitalocean_droplet.tf-web-2.urn,
    digitalocean_database_cluster.tf-db-1.urn,
    digitalocean_loadbalancer.loadbalancer.urn
  ]
}
