variable "project_name" {
  description = "The name of the project"
  type        = string
  default     = "kubernetes_practice"
}

variable "cluster_name" {
  type        = string
  default     = "kubernetes-practice"
  description = "The name of the Kubernetes cluster"
}

variable "node_image" {
  type        = string
  default     = null
  description = "The node image to use for the Kubernetes cluster. If not specified, the default image will be used."
}

variable "worker_count" {
  type        = number
  default     = 1
  description = "The number of worker nodes in the Kubernetes cluster"
}