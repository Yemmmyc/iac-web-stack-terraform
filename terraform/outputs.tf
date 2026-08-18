output "application_url" {
  description = "URL of the deployed web application."
  value       = "http://localhost:${var.host_port}"
}

output "container_name" {
  description = "Name of the Terraform-managed container."
  value       = docker_container.web.name
}

output "network_name" {
  description = "Name of the Docker network."
  value       = docker_network.web_network.name
}

output "container_id" {
  description = "Docker container ID."
  value       = docker_container.web.id
}
