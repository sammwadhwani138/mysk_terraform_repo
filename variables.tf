variable "v_env" {
  type = string
  default = "uat"
}

variable "v_subscription_id" {
  type = string
  default =  "0000000000-ab19-4c49-b7c7-d57603a39b75"
}

variable "v_provider_rg" {
  type = string
  default =  "my-azure-rg"
}

variable "v_location" {
    default = "West Europe"
}

variable "v_prefix" {
    default = "sk"
}


variable "v_akv_name" {
  type = string
  default = "mysk1"
}
variable "v_akv_sku" {
    type = string
    default = "standard"
}

variable "v_vm_subnet_cidr" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "v_vm_admin_username" {
  type = string
  default = "admin"
}
 