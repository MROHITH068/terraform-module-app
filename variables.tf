variable "env" {}
variable "component" {}
variable "tags" {}
variable "subnets" {}
variable "vpc_id" {}
variable "kms_key_arn" {}
variable "allow_ssh_cidr" {}
variable "app_port" {}
variable "instance_type" {}
variable "sg_subnet_cidr" {}

variable "desired_capacity" {}
variable "max_size" {}
variable "min_size" {}
variable "lb_dns_name" {}
variable "listener_arn" {}
variable "lb_rule_priority" {}
variable "extra_param_access" {}