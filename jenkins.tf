resource "helm_release" "jenkins" {
  name  = "jenkins"
  chart = "stable/jenkins"


  depends_on = [
    "helm_release.nginx-ingress",
    "google_container_cluster.default",
  ]

  values = [<<EOF
# Default values for jenkins.
# This is a YAML-formatted file.
# Declare name/value pairs to be passed into your templates.
# name: value

## Overrides for generated resource names
# See templates/_helpers.tpl
# nameOverride:
# fullnameOverride:

Master:
  Name: jenkins-master
  Image: "jenkins/jenkins"
  ImageTag: "lts"
  ImagePullPolicy: "Always"
# ImagePullSecret: jenkins
  Component: "jenkins-master"
  UseSecurity: true
  AdminUser: admin
  AdminPassword: ${random_id.jenkins_password.b64_std}
  Cpu: "100m"
  Memory: "256Mi"
  # Environment variables that get added to the init container (useful for e.g. http_proxy)
  # InitContainerEnv:
  #   - name: http_proxy
  #     value: "http://192.168.64.1:3128"
  # ContainerEnv:
  #   - name: http_proxy
  #     value: "http://192.168.64.1:3128"
  # Set min/max heap here if needed with:
  # JavaOpts: "-Xms512m -Xmx512m"
  # JenkinsOpts: ""
  # JenkinsUriPrefix: "/jenkins"
  # Set RunAsUser to 1000 to let Jenkins run as non-root user 'jenkins' which exists in 'jenkins/jenkins' docker image.
  # When setting RunAsUser to a different value than 0 also set FsGroup to the same value:
  # RunAsUser: <defaults to 0>
  # FsGroup: <will be omitted in deployment if RunAsUser is 0>
  ServicePort: 8080
  # For minikube, set this to NodePort, elsewhere use LoadBalancer
  # Use ClusterIP if your setup includes ingress controller
  ServiceType: ClusterIP
  # Master Service annotations
  ServiceAnnotations: {}
  #   service.beta.kubernetes.io/aws-load-balancer-backend-protocol: https
  # Used to create Ingress record (should used with ServiceType: ClusterIP)
  HostName: jenkins.${var.dns_gke_host}
  # NodePort: <to set explicitly, choose port between 30000-32767
  ContainerPort: 8080
  # Enable Kubernetes Liveness and Readiness Probes
  # ~ 2 minutes to allow Jenkins to restart when upgrading plugins. Set ReadinessTimeout to be shorter than LivenessTimeout.
  HealthProbes: true
  HealthProbesLivenessTimeout: 90
  HealthProbesReadinessTimeout: 60
  HealthProbeLivenessFailureThreshold: 12
  SlaveListenerPort: 50000
  DisabledAgentProtocols:
    - JNLP-connect
    - JNLP2-connect
  CSRF:
    DefaultCrumbIssuer:
      Enabled: true
      ProxyCompatability: true
  CLI: false
  # Kubernetes service type for the JNLP slave service
  # SETTING THIS TO "LoadBalancer" IS A HUGE SECURITY RISK: https://github.com/kubernetes/charts/issues/1341
  SlaveListenerServiceType: ClusterIP
  SlaveListenerServiceAnnotations: {}
  LoadBalancerSourceRanges:
  - 0.0.0.0/0
  # Optionally assign a known public LB IP
  # LoadBalancerIP: 1.2.3.4
  # Optionally configure a JMX port
  # requires additional JavaOpts, ie
  # JavaOpts: >
  #   -Dcom.sun.management.jmxremote.port=4000
  #   -Dcom.sun.management.jmxremote.authenticate=false
  #   -Dcom.sun.management.jmxremote.ssl=false
  # JMXPort: 4000
  # List of plugins to be install during Jenkins master start
  InstallPlugins:
    - kubernetes:1.8.2
    - workflow-aggregator:2.5
    - workflow-job:2.21
    - workflow-multibranch:2.19
    - credentials-binding:1.16
    - git:3.9.1
    - ghprb:1.42.0
    - blueocean:1.6.0
    - pipeline-github-lib:1.0
    - pipeline-utility-steps:2.1.0
  # Used to approve a list of groovy functions in pipelines used the script-security plugin. Can be viewed under /scriptApproval
  # ScriptApproval:
  #   - "method groovy.json.JsonSlurperClassic parseText java.lang.String"
  #   - "new groovy.json.JsonSlurperClassic"
  # List of groovy init scripts to be executed during Jenkins master start
  InitScripts:
  #  - |
  #    print 'adding global pipeline libraries, register properties, bootstrap jobs...'
  # Kubernetes secret that contains a 'credentials.xml' for Jenkins
  # CredentialsXmlSecret: jenkins-credentials
  # Kubernetes secret that contains files to be put in the Jenkins 'secrets' directory,
  # useful to manage encryption keys used for credentials.xml for instance (such as
  # master.key and hudson.util.Secret)
  # SecretsFilesSecret: jenkins-secrets
  # Jenkins XML job configs to provision
  # Jobs: |-
  #   test: |-
  #     <<xml here>>
  CustomConfigMap: false
  # Node labels and tolerations for pod assignment
  # ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#nodeselector
  # ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#taints-and-tolerations-beta-feature
  NodeSelector: {}
  Tolerations: {}

  Ingress:
    ApiVersion: extensions/v1beta1
    Annotations:
      kubernetes.io/ingress.class: nginx
    #  kubernetes.io/tls-acme: "true"

    TLS:
    # - secretName: jenkins.cluster.local
    #   hosts:
    #     - jenkins.cluster.local

Agent:
  Enabled: true
  Image: jenkins/jnlp-slave
  ImageTag: 3.10-1
# ImagePullSecret: jenkins
  Component: "jenkins-slave"
  Privileged: false
  Cpu: "100m"
  Memory: "256Mi"
  # You may want to change this to true while testing a new image
  AlwaysPullImage: false
  # You can define the volumes that you want to mount for this container
  # Allowed types are: ConfigMap, EmptyDir, HostPath, Nfs, Pod, Secret
  # Configure the attributes as they appear in the corresponding Java class for that type
  # https://github.com/jenkinsci/kubernetes-plugin/tree/master/src/main/java/org/csanchez/jenkins/plugins/kubernetes/volumes
  volumes:
  # - type: Secret
  #   secretName: mysecret
  #   mountPath: /var/myapp/mysecret
  NodeSelector: {}
  # Key Value selectors. Ex:
  # jenkins-agent: v1

Persistence:
  Enabled: true
  ## A manually managed Persistent Volume and Claim
  ## Requires Persistence.Enabled: true
  ## If defined, PVC must be created manually before volume will be bound
  # ExistingClaim:

  ## jenkins data Persistent Volume Storage Class
  ## If defined, storageClassName: <storageClass>
  ## If set to "-", storageClassName: "", which disables dynamic provisioning
  ## If undefined (the default) or set to null, no storageClassName spec is
  ##   set, choosing the default provisioner.  (gp2 on AWS, standard on
  ##   GKE, AWS & OpenStack)
  ##
  #StorageClass: "-"

  Annotations: {}
  AccessMode: ReadWriteOnce
  Size: 8Gi
  volumes:
  #  - name: nothing
  #    emptyDir: {}
  mounts:
  #  - mountPath: /var/nothing
  #    name: nothing
  #    readOnly: true

NetworkPolicy:
  # Enable creation of NetworkPolicy resources.
  Enabled: false
  # For Kubernetes v1.4, v1.5 and v1.6, use 'extensions/v1beta1'
  # For Kubernetes v1.7, use 'networking.k8s.io/v1'
  ApiVersion: extensions/v1beta1

## Install Default RBAC roles and bindings
rbac:
  install: true
  serviceAccountName: default
  # RBAC api version (currently either v1beta1 or v1alpha1)
  apiVersion: v1beta1
  # Cluster role reference
  roleRef: cluster-admin
EOF
  ]
}

resource "random_id" "jenkins_password" {
  byte_length = 8
}