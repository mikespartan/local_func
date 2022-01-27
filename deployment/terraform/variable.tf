variable "project" {
  type = string
  description = "Project name"
}

variable "environment" {
  type = string
  description = "Environment (dev / stage / prod)"
}

variable "location" {
  type = string
  description = "Azure region to deploy module to"
}

variable "functionapp" {
    type = string
    default = "../../../../DynamicElastic/DynamicElastic/DynamicElastic.zip"
}

variable "source_dir" {
  type = string
  default = "../../src"
}
