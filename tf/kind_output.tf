output "kubeconfig_path" {
  value       = kind_cluster.this.kubeconfig_path
  description = "The path to the generated Kubeconfig file"
}

output "kubeconfig" {
  value     = kind_cluster.this.kubeconfig
  sensitive = true
}

output "endpoint" {
  value       = kind_cluster.this.endpoint
  description = "The endpoint of the Kubernetes cluster"
}