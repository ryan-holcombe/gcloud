resource "kubernetes_secret" "service_account_credentials" {
  metadata {
    name = "service-account-credentials"
  }

  data {
    "credentials.json" = "${file("${path.module}/credentials.json")}"
  }
}

resource "kubernetes_secret" "docker_creds" {
  metadata {
    name = "regcred"
  }

  data {
    ".dockercfgjson" = "${file("${path.module}/dockercreds.json")}"
  }

  type = "kubernetes.io/dockercfgjson"
}

resource "kubernetes_secret" "docker_creds_config_json" {
  metadata {
    name = "docker-config"
  }

  data {
    "config.json" = "${file("${path.module}/dockercreds.json")}"
  }
}
