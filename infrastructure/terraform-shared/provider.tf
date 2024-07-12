provider "google" {
  credentials = var.credentials
  region      = var.region
  zone        = var.zone
  project     = var.project_id
}
