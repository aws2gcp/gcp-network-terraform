locals {
  # Make a list of all service project IDs
  service_project_ids = flatten([for k, v in local.subnets : v.attached_projects if length(v.attached_projects) > 0])
}

# Given project ID, get project information, namely the project number
data "google_project" "service_projects" {
  for_each   = toset(local.service_project_ids)
  project_id = each.value
}

locals {
  # Form Map of keyed by Project ID with list of compute service accounts
  compute_sa_accounts = {
    for project in data.google_project.service_projects : project.project_id => [
      "serviceAccount:${project.number}-compute@developer.gserviceaccount.com",
      "serviceAccount:${project.number}@cloudservices.gserviceaccount.com",
      #"serviceAccount:service-${project.number}@container-engine-robot.iam.gserviceaccount.com",
    ]
  }
  # Create a list of objects for all subnets that are shared
  shared_subnets = flatten([
    for k, v in local.subnets : [
      for i, service_project_id in v.attached_projects : {
        subnet_key         = k
        subnet_project_id  = v.project_id
        subnet_region      = v.region
        subnet_id          = "projects/${v.project_id}/regions/${v.region}/subnetworks/${v.name}"
        service_project_id = service_project_id
        members            = lookup(local.compute_sa_accounts, service_project_id, [])
      }
    ] if length(v.attached_projects) > 0
  ])
}

# Give Compute Network User permissions on the subnet to project service accounts
resource "google_compute_subnetwork_iam_binding" "compute" {
  for_each   = { for i, v in local.shared_subnets : "${v.subnet_key}-${v.service_project_id}" => v }
  project    = each.value.subnet_project_id
  region     = each.value.subnet_region
  subnetwork = each.value.subnet_id
  role       = "roles/compute.networkUser"
  members    = each.value.members
  depends_on = [google_compute_subnetwork.default]
}
