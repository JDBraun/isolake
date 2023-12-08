variable "region" {
  type = string
}

variable "prefix_list_index" {
  type = number
}

variable "vpc_id" {
  type = string
}

variable "vpc_cidr_range" {
  type = string
}

variable "subnets" {
  type = list(string)
}