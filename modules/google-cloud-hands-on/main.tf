## API 有効化
resource "google_project_service" "cloud_resource_manager" {
  project = var.project_id
  service = "cloudresourcemanager.googleapis.com"
}

resource "google_project_service" "billing_budget" {
  project = var.project_id
  service = "billingbudgets.googleapis.com"
}

resource "google_billing_budget" "budget" {
  billing_account = var.billing_account_id
  display_name    = "Budget Alert - 2000円"

  budget_filter {
    projects = ["projects/${var.project_id}"]
  }

  amount {
    specified_amount {
      currency_code = "JPY"
      units         = "2000"
    }
  }

  threshold_rules {
    threshold_percent = 0.5
    spend_basis       = "CURRENT_SPEND"
  }
  threshold_rules {
    threshold_percent = 0.9
    spend_basis       = "CURRENT_SPEND"
  }
  threshold_rules {
    threshold_percent = 1.0
    spend_basis       = "CURRENT_SPEND"
  }
  depends_on = [google_project_service.cloud_resource_manager, google_project_service.billing_budget]
}
