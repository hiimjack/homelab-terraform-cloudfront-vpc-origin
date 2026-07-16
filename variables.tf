variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "eu-west-1"
}

variable "project_name" {
  description = "Project name, used as a resource prefix"
  type        = string
  default     = "private-resources"
}
