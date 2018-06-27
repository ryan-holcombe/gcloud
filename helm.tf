
provider "helm" {
  tiller_image = "gcr.io/kubernetes-helm/tiller:${var.helm_version}"

  kubernetes {
    host                   = "${google_container_cluster.default.endpoint}"
    username               = "${var.gke_username}"
    password               = "${var.gke_password}"
    client_certificate     = "${base64decode(google_container_cluster.default.master_auth.0.client_certificate)}"
    client_key             = "${base64decode(google_container_cluster.default.master_auth.0.client_key)}"
    cluster_ca_certificate = "${base64decode(google_container_cluster.default.master_auth.0.cluster_ca_certificate)}"
  }
}

resource "helm_release" "kube-lego" {
  name  = "kube-lego"
  chart = "stable/kube-lego"

  values = [<<EOF
rbac:
  create: true
config:
  LEGO_EMAIL: ${var.acme_email}
  LEGO_URL: ${var.acme_url}
  LEGO_SECRET_NAME: lego-acme
EOF
  ]
}

resource "helm_release" "nginx-ingress" {
  name  = "nginx-ingress"
  chart = "stable/nginx-ingress"

  values = [<<EOF
controller:
  service:
    type: LoadBalancer
  publishService:
    enabled: true
rbac:
  create: true
EOF
  ]
}

resource "helm_release" "external-dns" {
  name  = "external-dns"
  chart = "stable/external-dns"

  values = [<<EOF
domainFilters: ["${google_dns_managed_zone.gke_dns.dns_name}"]
provider: google
google:
  project: ${var.project}
  serviceAccountSecret: "${kubernetes_secret.service_account_credentials.metadata.0.name}"
rbac:
  create: true
EOF
  ]
}

resource "helm_release" "dashboard" {
  name  = "dashboard"
  chart = "stable/kubernetes-dashboard"
  namespace = "kube-system"

  values = [<<EOF
ingress:
  annotations:
    nginx.ingress.kubernetes.io/secure-backends: "true"
    kubernetes.io/ingress.class: nginx
    kubernetes.io/tls-acme: 'true'
  enabled: true
  hosts:
    - dashboard.${var.dns_gke_host}
rbac:
  create: true
EOF
  ]
}