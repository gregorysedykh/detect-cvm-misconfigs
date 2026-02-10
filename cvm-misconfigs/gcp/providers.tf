provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone

  credentials  = var.credentials_file != null ? file(pathexpand(var.credentials_file)) : null
  access_token = var.access_token
}
