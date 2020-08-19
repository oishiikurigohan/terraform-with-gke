variable "project_id" {
  description = "gcp project id"
  default     = "terraform-with-gke"
}

variable "cluster_name" {
  default = "cluster01"
}

variable "region" {
  default = "asia-northeast1"
}

variable "zone" {
  default = "asia-northeast1-a"
}

variable "network" {
  default = "vpc01"
}

variable "subnetwork" {
  default = "subnet01"
}

variable "ip_range_pods_name" {
  default = "ip-range-pods"
}

variable "ip_range_services_name" {
  default = "ip-range-scv"
}
