
resource "google_project" "my_project" {
  name                = "My Project"
  project_id          = "your-project-id"
  auto_create_network = false
  deletion_policy     = "DELETE"
}
