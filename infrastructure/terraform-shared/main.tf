resource "google_artifact_registry_repository" "coop-helm-chart-repo" {
  location      = var.zone
  repository_id = "coop-helm-charts"
  description   = "Helm charts used in coop"
  format        = "DOCKER"
}

resource "google_artifact_registry_repository_iam_member" "public-artifacts-reader" {
  project    = google_artifact_registry_repository.coop-helm-chart-repo.project
  location   = google_artifact_registry_repository.coop-helm-chart-repo.location
  repository = google_artifact_registry_repository.coop-helm-chart-repo.name
  role       = "roles/artifactregistry.reader"
  member     = "allUsers"
}
