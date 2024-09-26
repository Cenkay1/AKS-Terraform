variable "client_id" {
  description = "Azure Client ID"
  type        = string
}

variable "client_secret" {
  description = "Azure Client Secret"
  type        = string
  sensitive   = true  # Gizli veri olduğu için sensitive olarak işaretlenir
}

variable "tenant_id" {
  description = "Azure Tenant ID"
  type        = string
}

variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "aks_rg_name" {
  type = string
  description = "Name of the resource group of azure kubernetes services"
}

variable "aks_name" {
  type = string
  description = "Name of the azure kubernetes services"
}

variable "acr_name" {
  type = string
  description = "Name of the azure container registry"
}

variable "location" {
  type = string
  description = "Name of the location of resource"
}

variable "aks_version" {
  type = string
  description = "version of aks"
}

variable "cidr_block" {
    type = string
 validation {
   condition     = split("/", var.cidr_block)[1] > 16 && split("/", var.cidr_block)[1] < 30
   error_message = "Your vpc cidr is not between 16 and 30"
 }
  
}

variable "node_taints" {
  description = "Node pool taints to be applied to the nodes"
  type        = list(string)
  default     = [] # Eğer taint verilmezse boş bir liste olacak
}

variable "tags" {
  description = "A mapping of tags which should be assigned to all resources"
  type        = map(any)
  default     = {}
}