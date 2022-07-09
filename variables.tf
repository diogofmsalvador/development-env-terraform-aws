variable environment {
  type        = string
  description = "Environment variable to set"
}

variable path_to_userdata {
  type        = string
  description = "Path to file userdata.sh"
}
variable path_to_ssh_config {
  type        = string
  description = "Path to file ssh-config.sh"
}
variable path_to_key {
  type        = string
  description = "Path to secret key to access aws ec2 instance"
}
variable path_to_key_pub {
  type        = string
  description = "Path to secret key pub to access aws ec2 instance"
}
variable ec2_instance_type {
  type        = string
  description = "EC2 instance type"
}