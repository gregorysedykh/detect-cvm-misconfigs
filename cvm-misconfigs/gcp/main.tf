data "google_project" "project" {
  project_id = var.project_id
}

resource "google_project_service" "cloudkms" {
  service            = "cloudkms.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "compute" {
  service            = "compute.googleapis.com"
  disable_on_destroy = false
}

resource "google_kms_key_ring" "cvm_ring" {
  name     = "cvm-keyring"
  location = var.region

  depends_on = [google_project_service.cloudkms]

  lifecycle {
    ignore_changes = all
  }
}

resource "google_kms_crypto_key" "cvm_key" {
  name            = "cvm-key"
  key_ring        = google_kms_key_ring.cvm_ring.id
  purpose         = "ENCRYPT_DECRYPT"

  version_template {
    algorithm        = "GOOGLE_SYMMETRIC_ENCRYPTION"
    protection_level = "HSM"
  }

  rotation_period = "7776000s"

  lifecycle {
    ignore_changes = all
  }
}

resource "google_compute_disk" "boot_disk" {
  name  = "cvm-test-boot"
  type  = "hyperdisk-balanced"
  zone  = var.zone
  size  = 50

  provisioned_iops       = 3000
  provisioned_throughput = 140

  image = "projects/ubuntu-os-accelerator-images/global/images/ubuntu-accelerator-2404-amd64-with-nvidia-580-v20260203"

  enable_confidential_compute = true

  disk_encryption_key {
    kms_key_self_link = google_kms_crypto_key.cvm_key.id
  }
}

resource "google_kms_crypto_key_iam_member" "compute_agent_encrypter" {
  crypto_key_id = google_kms_crypto_key.cvm_key.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"

  member = "serviceAccount:service-${data.google_project.project.number}@compute-system.iam.gserviceaccount.com"
}

resource "google_service_account" "confidential_vm_sa" {
  account_id   = "confidential-vm-sa"
  display_name = "Confidential VM Service Account"
}

resource "google_compute_instance" "cvm-test" {
  boot_disk {
    auto_delete       = true
    device_name       = "cvm-test"
    source            = google_compute_disk.boot_disk.self_link
    kms_key_self_link = google_kms_crypto_key.cvm_key.id
    mode              = "READ_WRITE"
  }

  can_ip_forward      = false
  deletion_protection = false
  enable_display      = false

  confidential_instance_config {
    confidential_instance_type = var.confidential_instance_type
  }

  labels = var.labels

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
    email  = google_service_account.confidential_vm_sa.email
    scopes = ["cloud-platform"]
  }

  shielded_instance_config {
    enable_integrity_monitoring = var.enable_integrity_monitoring
    enable_secure_boot          = var.enable_secure_boot
    enable_vtpm                 = var.enable_vtpm
  }

  zone = var.zone

  key_revocation_action_type = "STOP"

  depends_on = [
    google_kms_crypto_key_iam_member.compute_agent_encrypter
  ]

}
