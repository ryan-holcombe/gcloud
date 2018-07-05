
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

resource "helm_repository" "weaveworks" {
    name = "weaveworks"
    url  = "https://weaveworks.github.io/flux"
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
    kubernetes.io/ingress.class: "nginx"
    ingress.kubernetes.io/ssl-redirect: "false"
    certmanager.k8s.io/cluster-issuer: letsencrypt-prod
    nginx.ingress.kubernetes.io/secure-backends: "true"
  tls:
  - hosts:
    - dashboard.${var.dns_gke_host}
    secretName: dashboard-tls
  enabled: true
  hosts:
    - dashboard.${var.dns_gke_host}
rbac:
  create: true
EOF
  ]
}

resource "helm_release" "flux" {
  name  = "flux"
  chart = "weaveworks/flux"
  namespace = "flux"

  values = [<<EOF
helmOperator:
  create: true
git:
  url: ${var.flux_git_url}
  chartsPath: charts
rbac:
  create: true
ssh:
  known_hosts: "github.com ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ=="
EOF
  ]
}

resource "helm_release" "cert_manager" {
  name  = "cert-manager"
  chart = "stable/cert-manager"
  namespace = "default"

  values = [<<EOF
ingressShim:
  defaultIssuerName: letsencrypt-prod
  defaultIssuerKind: ClusterIssuer
rbac:
  create: true
EOF
  ]
}
