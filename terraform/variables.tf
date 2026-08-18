variable "container_name" {
  description = "Name assigned to the web application container."
  type        = string
  default     = "iac-web-stack"
}

variable "network_name" {
  description = "Docker network used by the web application."
  type        = string
  default     = "iac-web-network"
}

variable "host_port" {
  description = "Port exposed on the host machine."
  type        = number
  default     = 8090
}

variable "container_port" {
  description = "Port exposed by the NGINX container."
  type        = number
  default     = 80
}
