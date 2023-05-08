
locals {
  service_project_ids = { for k, v in local.subnets : k => coalesce(v.attached_projects, []) }
}

# Given project ID, get project information, namely the project number
data "google_project" "service_projects" {
  for_each   = { for k, v in local.service_project_ids : k => v if length(v) > 0 }
  project_id = each.value
}

locals {
  # Form list of service accounts to given compute Network User to
  compute_sa_accounts = [
    for project in data.google_project.service_projects : [
      "serviceAccount:${project.number}-compute@developer.gserviceaccount.com",
      "serviceAccount:${project.number}@cloudservices.gserviceaccount.com",
    ]
  ]
  gke_sa_accounts = [
    for project in data.google_project.service_projects : [
      "serviceAccount:service-${project.number}@container-engine-robot.iam.gserviceaccount.com",
      "serviceAccount:${project.number}@cloudservices.gserviceaccount.com",
    ]
  ]
}

# Give Compute Network User permissions on the subnet to project service accounts
resource "google_compute_subnetwork_iam_binding" "compute" {
  for_each   = { for k, v in local.service_project_ids : k => v if length(v) > 0 }
  project    = each.value.project_id
  region     = each.value.region
  subnetwork = each.value.subnet_id
  role       = "roles/compute.networkUser"
  members    = flatten(local.compute_sa_accounts)
  depends_on = [google_compute_subnetwork.default]
}
