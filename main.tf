terraform {
  required_version = ">= 1.0"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.50.0"
    }
  }
}

provider "proxmox" {
  endpoint = "https://192.168.122.161:8006/api2/json"
  insecure = true
  username = "root@pam"
  password = "1234nico"
}

# Variables globales
locals {
  # Configuration réseau
  network_config = {
    gateway = "192.168.122.1"
    subnet  = "192.168.122.0/24"
  }
  
  # Configuration des VMs
  vm_config = {
    cpu_cores    = 2
    memory_gb    = 2
    disk_size_gb = 20
    template_id  = 9000
  }
  
  # Utilisateur par défaut
  default_user = {
    username = "ubuntu"
    password = "1234nico"
  }
  
  # Étape 1 : Infrastructure de base
  step1_vms = {
    201 = { name = "bastion-host",      ip = "192.168.122.201", role = "bastion" }
    202 = { name = "load-balancer",     ip = "192.168.122.202", role = "load_balancer" }
  }
  
  # Étape 2 : Frontend
  step2_vms = {
    203 = { name = "frontend-server-1", ip = "192.168.122.203", role = "frontend" }
    204 = { name = "frontend-server-2", ip = "192.168.122.204", role = "frontend" }
  }
  
  # Étape 3 : Backend
  step3_vms = {
    205 = { name = "backend-server-1",  ip = "192.168.122.205", role = "backend" }
    206 = { name = "backend-server-2",  ip = "192.168.122.206", role = "backend" }
  }
  
  # Étape 4 : Services
  step4_vms = {
    207 = { name = "database-server",   ip = "192.168.122.207", role = "database" }
    208 = { name = "cicd-server",       ip = "192.168.122.208", role = "cicd" }
    209 = { name = "backup-server",     ip = "192.168.122.209", role = "backup" }
    210 = { name = "monitoring-server", ip = "192.168.122.210", role = "monitoring" }
  }

  # Étape 5 : Sécurité (WAF)
  step5_vms = {
    211 = { name = "firewall-waf",      ip = "192.168.122.211", role = "waf" }
  }
}

# Variables de contrôle
variable "deploy_step1" {
  description = "Déployer l'étape 1 (bastion, load-balancer)"
  type        = bool
  default     = true
}

variable "deploy_step2" {
  description = "Déployer l'étape 2 (frontend)"
  type        = bool
  default     = false
}

variable "deploy_step3" {
  description = "Déployer l'étape 3 (backend)"
  type        = bool
  default     = false
}

variable "deploy_step4" {
  description = "Déployer l'étape 4 (services)"
  type        = bool
  default     = false
}

variable "deploy_step5" {
  description = "Déployer l'étape 5 (firewall/WAF)"
  type        = bool
  default     = false
}

# Étape 1 : Infrastructure de base
resource "proxmox_virtual_environment_vm" "step1" {
  for_each = var.deploy_step1 ? local.step1_vms : {}
  
  name      = each.value.name
  node_name = "nico"
  vm_id     = each.key
  started   = true
  on_boot   = true

  timeout_clone        = 3600
  timeout_create       = 3600
  timeout_start_vm     = 1800
  timeout_shutdown_vm  = 1800

  clone {
    vm_id = local.vm_config.template_id
  }

  cpu {
    cores   = local.vm_config.cpu_cores
    sockets = 1
  }

  memory {
    dedicated = local.vm_config.memory_gb * 1024
  }

  disk {
    datastore_id = "local-lvm"
    size         = local.vm_config.disk_size_gb
    interface    = "scsi0"
  }

  network_device {
    bridge = "vmbr0"
    model  = "virtio"
  }

  agent {
    enabled = true
    type    = "virtio"
  }

  initialization {
    datastore_id = "local-lvm"
    interface    = "ide2"

    ip_config {
      ipv4 {
        address = "${each.value.ip}/24"
        gateway = local.network_config.gateway
      }
    }

    user_account {
      username = local.default_user.username
      password = local.default_user.password
      keys     = [file("~/.ssh/id_rsa.pub")]
    }
  }
}

# Étape 2 : Frontend
resource "proxmox_virtual_environment_vm" "step2" {
  for_each = var.deploy_step2 ? local.step2_vms : {}
  
  name      = each.value.name
  node_name = "nico"
  vm_id     = each.key
  started   = true
  on_boot   = true

  timeout_clone        = 3600
  timeout_create       = 3600
  timeout_start_vm     = 1800
  timeout_shutdown_vm  = 1800

  clone {
    vm_id = local.vm_config.template_id
  }

  cpu {
    cores   = local.vm_config.cpu_cores
    sockets = 1
  }

  memory {
    dedicated = local.vm_config.memory_gb * 1024
  }

  disk {
    datastore_id = "local-lvm"
    size         = local.vm_config.disk_size_gb
    interface    = "scsi0"
  }

  network_device {
    bridge = "vmbr0"
    model  = "virtio"
  }

  agent {
    enabled = true
    type    = "virtio"
  }

  initialization {
    datastore_id = "local-lvm"
    interface    = "ide2"

    ip_config {
      ipv4 {
        address = "${each.value.ip}/24"
        gateway = local.network_config.gateway
      }
    }

    user_account {
      username = local.default_user.username
      password = local.default_user.password
      keys     = [file("~/.ssh/id_rsa.pub")]
    }
  }
}

# Étape 3 : Backend
resource "proxmox_virtual_environment_vm" "step3" {
  for_each = var.deploy_step3 ? local.step3_vms : {}
  
  name      = each.value.name
  node_name = "nico"
  vm_id     = each.key
  started   = true
  on_boot   = true

  timeout_clone        = 3600
  timeout_create       = 3600
  timeout_start_vm     = 1800
  timeout_shutdown_vm  = 1800

  clone {
    vm_id = local.vm_config.template_id
  }

  cpu {
    cores   = local.vm_config.cpu_cores
    sockets = 1
  }

  memory {
    dedicated = local.vm_config.memory_gb * 1024
  }

  disk {
    datastore_id = "local-lvm"
    size         = local.vm_config.disk_size_gb
    interface    = "scsi0"
  }

  network_device {
    bridge = "vmbr0"
    model  = "virtio"
  }

  agent {
    enabled = true
    type    = "virtio"
  }

  initialization {
    datastore_id = "local-lvm"
    interface    = "ide2"

    ip_config {
      ipv4 {
        address = "${each.value.ip}/24"
        gateway = local.network_config.gateway
      }
    }

    user_account {
      username = local.default_user.username
      password = local.default_user.password
      keys     = [file("~/.ssh/id_rsa.pub")]
    }
  }
}

# Étape 4 : Services
resource "proxmox_virtual_environment_vm" "step4" {
  for_each = var.deploy_step4 ? local.step4_vms : {}
  
  name      = each.value.name
  node_name = "nico"
  vm_id     = each.key
  started   = true
  on_boot   = true

  timeout_clone        = 3600
  timeout_create       = 3600
  timeout_start_vm     = 1800
  timeout_shutdown_vm  = 1800

  clone {
    vm_id = local.vm_config.template_id
  }

  cpu {
    cores   = local.vm_config.cpu_cores
    sockets = 1
  }

  memory {
    dedicated = local.vm_config.memory_gb * 1024
  }

  disk {
    datastore_id = "local-lvm"
    size         = local.vm_config.disk_size_gb
    interface    = "scsi0"
  }

  network_device {
    bridge = "vmbr0"
    model  = "virtio"
  }

  agent {
    enabled = true
    type    = "virtio"
  }

  initialization {
    datastore_id = "local-lvm"
    interface    = "ide2"

    ip_config {
      ipv4 {
        address = "${each.value.ip}/24"
        gateway = local.network_config.gateway
      }
    }

    user_account {
      username = local.default_user.username
      password = local.default_user.password
      keys     = [file("~/.ssh/id_rsa.pub")]
    }
  }
}

# Étape 5 : Sécurité (WAF)
resource "proxmox_virtual_environment_vm" "step5" {
  for_each = var.deploy_step5 ? local.step5_vms : {}
  
  name      = each.value.name
  node_name = "nico"
  vm_id     = each.key
  started   = true
  on_boot   = true

  timeout_clone        = 3600
  timeout_create       = 3600
  timeout_start_vm     = 1800
  timeout_shutdown_vm  = 1800

  clone {
    vm_id = local.vm_config.template_id
  }

  cpu {
    cores   = local.vm_config.cpu_cores
    sockets = 1
  }

  memory {
    dedicated = local.vm_config.memory_gb * 1024
  }

  disk {
    datastore_id = "local-lvm"
    size         = local.vm_config.disk_size_gb
    interface    = "scsi0"
  }

  network_device {
    bridge = "vmbr0"
    model  = "virtio"
  }

  agent {
    enabled = true
    type    = "virtio"
  }

  initialization {
    datastore_id = "local-lvm"
    interface    = "ide2"

    ip_config {
      ipv4 {
        address = "${each.value.ip}/24"
        gateway = local.network_config.gateway
      }
    }

    user_account {
      username = local.default_user.username
      password = local.default_user.password
      keys     = [file("~/.ssh/id_rsa.pub")]
    }
  }
}

# Outputs consolidés
output "all_vm_ips" {
  description = "IPs de toutes les VMs"
  value = merge(
    { for vm in proxmox_virtual_environment_vm.step1 : vm.name => vm.initialization[0].ip_config[0].ipv4[0].address },
    { for vm in proxmox_virtual_environment_vm.step2 : vm.name => vm.initialization[0].ip_config[0].ipv4[0].address },
    { for vm in proxmox_virtual_environment_vm.step3 : vm.name => vm.initialization[0].ip_config[0].ipv4[0].address },
    { for vm in proxmox_virtual_environment_vm.step4 : vm.name => vm.initialization[0].ip_config[0].ipv4[0].address },
    { for vm in proxmox_virtual_environment_vm.step5 : vm.name => vm.initialization[0].ip_config[0].ipv4[0].address }
  )
}

output "deployment_status" {
  description = "Statut du déploiement"
  value = {
    step1_deployed = var.deploy_step1
    step2_deployed = var.deploy_step2
    step3_deployed = var.deploy_step3
    step4_deployed = var.deploy_step4
    step5_deployed = var.deploy_step5
  }
}