variable gke_username {}
variable gke_password {}

variable region {
  default = "us-west1"
}

variable zone {
  default = "us-west1-b"
}

variable project {
  default = "rholcombe-gke-test"
}

variable gke_project {
  default = "tf-gke-default"
}

variable dns_root {
  default = "rholcombe.com"
}

variable "helm_version" {
  default = "v2.9.1"
}

variable "acme_email" {}

variable "acme_url" {
  default = "https://acme-v01.api.letsencrypt.org/directory"
}

variable dns_root_host {
  default = "rholcombe30.com"
}

variable dns_gke_host {
  default = "gke.rholcombe30.com"
}

variable dns_root_name {
  default = "gcp-rholcombe30-com"
}

variable dns_gke_name {
  default = "gcp-k8s-rholcombe30-com"
}

variable flux_git_url {
  default = "ssh://git@github.com/sythe21/flux-gitops"
}

variable hubot_slack_token {}

variable jenkins_user {
  default = "admin"
}

variable jenkins_api_token {}
