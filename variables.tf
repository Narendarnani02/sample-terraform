variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "Terraform-sample"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Existing EC2 Key Pair name"
  type        = string
  default     = "nanipem"
}
