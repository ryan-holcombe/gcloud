
provider google {
  region = "${var.region}"
}

data "google_client_config" "current" {}

resource "google_compute_network" "default" {
  name                    = "${var.gke_project}"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "default" {
  name                     = "${var.gke_project}"
  ip_cidr_range            = "10.127.0.0/20"
  network                  = "${google_compute_network.default.self_link}"
  region                   = "${var.region}"
  private_ip_google_access = true
}

data "google_container_engine_versions" "default" {
  zone = "${var.zone}"
}

resource "google_container_cluster" "default" {
  name               = "${var.gke_project}"
  zone               = "${var.zone}"
  initial_node_count = 3
  min_master_version = "${data.google_container_engine_versions.default.latest_node_version}"
  network            = "${google_compute_subnetwork.default.name}"
  subnetwork         = "${google_compute_subnetwork.default.name}"

  node_config {
    machine_type = "n1-standard-1"
  }

  addons_config {
    http_load_balancing {
      disabled = true
    }
  }

  master_auth {
    username = "${var.gke_username}"
    password = "${var.gke_password}"
  }
}