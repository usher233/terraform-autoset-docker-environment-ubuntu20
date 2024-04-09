# host_os = "linux"
# vpc_cidr = "10.123.0.0/16"
# public_subnet_cidr = "10.123.1.0/24"
# az = "eu-west-3a"
# instance_type = "t2.micro"



variable "host_os" {
    description = "The operating system of the host"
    type        = string
}

variable "vpc_cidr" {
    description = "The CIDR block for the VPC"
    type        = string
}

variable "public_subnet_cidr" {
    description = "The CIDR block for the public subnet"
    type        = string
}

variable "region" {
    description = "The region"
    type        = string
}


variable "az" {
    description = "The availability zone"
    type        = string
}

variable "instance_type" {
    description = "The instance type"
    type        = string
}

variable "bucketname" {
    description = "The name of the bucket"
    type        = string
}