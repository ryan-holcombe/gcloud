
resource "google_dns_managed_zone" "root_dns" {
  name        = "${var.dns_root_name}"
  dns_name    = "${var.dns_root_host}."
  description = "Root DNS zone"
}

resource "google_dns_managed_zone" "gke_dns" {
  name        = "${var.dns_gke_name}"
  dns_name    = "${var.dns_gke_host}."
  description = "GKE DNS zone"
}

resource "google_dns_record_set" "root_dns_set" {
  name = "${google_dns_managed_zone.gke_dns.dns_name}"
  type = "NS"
  ttl  = 60

  managed_zone = "${google_dns_managed_zone.root_dns.name}"

  rrdatas = ["${google_dns_managed_zone.gke_dns.name_servers}"]
}