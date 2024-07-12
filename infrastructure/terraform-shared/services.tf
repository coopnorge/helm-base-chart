resource "google_project_service" "project" {
  for_each = toset([
    "artifactregistry.googleapis.com",
  ])
  project                    = var.project_id
  service                    = each.value
  disable_dependent_services = false
  disable_on_destroy         = false
}
