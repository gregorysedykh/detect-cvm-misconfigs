confidential_instance_type   = "SEV"
enable_integrity_monitoring  = true
enable_secure_boot           = true
enable_vtpm                  = true

labels = {
  goog-ec-src = "vm_add-tf"
  scenario    = "sev"
}