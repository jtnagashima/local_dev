output "kubeconfig_path" {
  value       = ".kube/config"
  description = "The path to the generated Kubeconfig file"
}

output "endpoint" {
  value       = kind_cluster.this.endpoint
  description = "The endpoint of the Kubernetes cluster"
}