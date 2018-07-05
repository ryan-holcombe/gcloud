

output network {
  value = "${google_compute_subnetwork.default.network}"
}

output subnetwork_name {
  value = "${google_compute_subnetwork.default.name}"
}

output cluster_name {
  value = "${google_container_cluster.default.name}"
}

output cluster_region {
  value = "${var.region}"
}

output cluster_zone {
  value = "${google_container_cluster.default.zone}"
}

output "jenkins_user" {
  value = "${var.jenkins_user}"
}

output "jenkins_password" {
  value = "${random_id.jenkins_password.b64_std}"
}
