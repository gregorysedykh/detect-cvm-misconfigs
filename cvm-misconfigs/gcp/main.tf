resource "google_compute_instance" "cvm-test" {
  boot_disk {
    auto_delete = true
    device_name = "cvm-test"

    initialize_params {
      image = "projects/ubuntu-os-accelerator-images/global/images/ubuntu-accelerator-2404-amd64-with-nvidia-580-v20260203"
      size  = 10
      type  = "pd-standard"
    }

    mode = "READ_WRITE"
  }

  can_ip_forward      = false
  deletion_protection = false
  enable_display      = false

  confidential_instance_config {
    confidential_instance_type = "SEV_SNP"
  }

  labels = {
    goog-ec-src = "vm_add-tf"
  }

  machine_type     = "n2d-standard-2"
  min_cpu_platform = "AMD Milan"
  name             = "cvm-test"

  network_interface {
    access_config {
      network_tier = "PREMIUM"
    }

    nic_type    = "GVNIC"
    queue_count = 0
    stack_type  = "IPV4_ONLY"
    subnetwork  = var.subnetwork
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "TERMINATE"
    preemptible         = false
    provisioning_model  = "STANDARD"
  }

  service_account {
    email  = var.service_account_email
    scopes = ["https://www.googleapis.com/auth/devstorage.read_only", "https://www.googleapis.com/auth/logging.write", "https://www.googleapis.com/auth/monitoring.write", "https://www.googleapis.com/auth/service.management.readonly", "https://www.googleapis.com/auth/servicecontrol", "https://www.googleapis.com/auth/trace.append"]
  }

  shielded_instance_config {
    enable_integrity_monitoring = false
    enable_secure_boot          = false
    enable_vtpm                 = false
  }

  zone = var.zone
}
