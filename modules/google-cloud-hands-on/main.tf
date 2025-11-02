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
}
