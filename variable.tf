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

variable "network_id" {
  description = "Id of the network the node will be attached to"
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

variable "ca" {
  description = "The ca that will sign the db's certificate. Should have the following keys: key, key_algorithm, certificate"
  type = any
}

variable "domains" {
  description = "Domains of the database, which will be used for the certificate"
  type = list(string)
}

variable "organization" {
  description = "The etcd cluster's certificates' organization"
  type = string
  default = "Ferlab"
}

variable "certificate_validity_period" {
  description = "The etcd cluster's certificate's validity period in hours"
  type = number
  default = 100*365*24
}

variable "certificate_early_renewal_period" {
  description = "The etcd cluster's certificate's early renewal period in hours"
  type = number
  default = 99*365*24
}

variable "key_length" {
  description = "The key length of the certificate's private key"
  type = number
  default = 4096
}