resource "kubernetes_namespace" "cert_manager" {
  metadata { name = "cert-manager" }
}

resource "helm_release" "cert_manager" {
  depends_on = [kubernetes_namespace.cert_manager]

  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace  = "cert-manager"
  version    = "v1.0.4"
  timeout    = "300"
  values = [
    <<-EOF

installCRDs: true

EOF
  ]
}

# WARNING: Kubernetes Alpha Experimental provider below
resource "kubernetes_manifest" "cert_manager_issuer_http_0" {
  depends_on = [kubernetes_namespace.cert_manager, helm_release.cert_manager]
  provider   = kubernetes-alpha
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "ClusterIssuer"
    "metadata" = {
      "name"      = "letsencrypt-prod"
      "namespace" = "cert-manager"
    }
    "spec" = {
      "acme" = {
        "server" = "https://acme-v02.api.letsencrypt.org/directory"
        #"server" = "https://acme-staging-v02.api.letsencrypt.org/directory"
        "email" = "admin@${var.domain_default}"
        privateKeySecretRef = {
          name = "www.proteyah.com-secret-tls"
        }
        solvers = [
          {
            selector = {}
            http01 = {
              ingress = {
                # NOTE: If you want to use another ingress-class to generate a certificate via acme-challenge:
                # NOTE: add the following annotation to ingress: `acme.cert-manager.io/http01-ingress-class=YOUR_INGRESS_CLASS_NAME`
                class = "nginx"
              }
            }

          }
        ]
      }
    }
  }
}
resource "kubernetes_manifest" "cert_manager_issuer_http_1" {
  depends_on = [kubernetes_namespace.cert_manager, helm_release.cert_manager]
  provider   = kubernetes-alpha
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "ClusterIssuer"
    "metadata" = {
      "name"      = "letsencrypt-staging"
      "namespace" = "cert-manager"
    }
    "spec" = {
      "acme" = {
        "server" = "https://acme-v02.api.letsencrypt.org/directory"
        #"server" = "https://acme-staging-v02.api.letsencrypt.org/directory"
        "email" = "admin@${var.domain_default}"
        privateKeySecretRef = {
          name = "stg.proteyah.com-secret-tls"
        }
        solvers = [
          {
            selector = {}
            http01 = {
              ingress = {
                # NOTE: If you want to use another ingress-class to generate a certificate via acme-challenge:
                # NOTE: add the following annotation to ingress: `acme.cert-manager.io/http01-ingress-class=YOUR_INGRESS_CLASS_NAME`
                class = "nginx"
              }
            }

          }
        ]
      }
    }
  }
}

resource "kubernetes_manifest" "cert_manager_issuer_http_2" {
  depends_on = [kubernetes_namespace.cert_manager, helm_release.cert_manager]
  provider   = kubernetes-alpha
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "ClusterIssuer"
    "metadata" = {
      "name"      = "letsencrypt-http"
      "namespace" = "cert-manager"
    }
    "spec" = {
      "acme" = {
        "server" = "https://acme-v02.api.letsencrypt.org/directory"
        #"server" = "https://acme-staging-v02.api.letsencrypt.org/directory"
        "email" = "admin@${var.domain_default}"
        privateKeySecretRef = {
          name = "letsencrypt-http-tls"
        }
        solvers = [
          {
            selector = {}
            http01 = {
              ingress = {
                # NOTE: If you want to use another ingress-class to generate a certificate via acme-challenge:
                # NOTE: add the following annotation to ingress: `acme.cert-manager.io/http01-ingress-class=YOUR_INGRESS_CLASS_NAME`
                class = "nginx"
              }
            }

          }
        ]
      }
    }
  }
}
