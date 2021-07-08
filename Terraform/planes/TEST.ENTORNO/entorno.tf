#### Script de verificación del entorno !!!


variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "compartment_ocid" {}
variable "region" {}

provider "oci" {
  version          = ">= 3.0.0"
  region           = "${var.region}"
  tenancy_ocid     = "${var.tenancy_ocid}"
  user_ocid        = "${var.user_ocid}"
  fingerprint      = "${var.fingerprint}"
  private_key_path = "${var.private_key_path}"
}


output "tenancy_ocid" {
  value = "${var.tenancy_ocid}"
}

output "user_ocid" {
  value = "${var.user_ocid}"
}

output "fingerprint" {
  value = "${var.fingerprint}"
}

output "private_key_path" {
  value = "${var.private_key_path}"
}

output "compartment_ocid" {
  value = "${var.compartment_ocid}"
}

output "region" {
  value = "${var.region}"
}


