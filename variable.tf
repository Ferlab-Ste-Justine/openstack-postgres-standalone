variable "namespace" {
  description = "Namespace to create the resources under"
  type = string
  default = ""
}

variable "image_id" {
    description = "ID of the vm image used to provision the node"
    type = string
}

variable "flavor_id" {
  description = "ID of the VM flavor for the node"
  type = string
}

variable "security_groups" {
  description = "Security groups of the node"
  type = list(string)
  default = ["default"]
}

variable "network_name" {
  description = "Name of the network the node will be attached to"
  type = string
}

variable "keypair_name" {
  description = "Name of the keypair that will be used to ssh to the node"
  type = string
}

variable "postgres_image" {
  description = "Name of the docker image that will be used to provision postgres"
  type = string
}

variable "postgres_params" {
  description = "Extra parameters to pass to the postgres binary"
  type = string
  default = ""
}

variable "postgres_user" {
  description = "User that will access the database"
  type = string
}

variable "postgres_database" {
  description = "Name of the database that will be generated"
  type = string
}

variable "postgres_password" {
  description = "Password of the user who will access the database. If no value is provided, a random value will be generated"
  type = string
  default = ""
}

variable "postgres_tls_key" {
  description = "Secret key if you want to connect to postgres over tls"
  type = string
  default = ""
}

variable "postgres_tls_certificate" {
  description = "Public certificate if you want to connect to postgres over tls"
  type = string
  default = ""
}

variable "postgres_user" {
  description = "User that postgres will run as. Mostly used if you want to enable tls. Should be a user id"
  type = string
  default = "999"
}
