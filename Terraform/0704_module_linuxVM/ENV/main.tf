variable "varenvrg" {}

module "rg-module" {
  source = "../RG"
  varrg  = var.varenvrg

}

variable "varenvvn" {}

module "vn-module" {
  source     = "../VN"
  varvn      = var.varenvvn
  depends_on = [module.rg-module]
}


variable "varenvsn" {}
module "sn-module" {
  source     = "../SN"
  varsn      = var.varenvsn
  depends_on = [module.rg-module, module.vn-module]
}

variable "varenvpi" {}

module "pi-module" {
  source     = "../PI"
  varpi      = var.varenvpi
  depends_on = [module.rg-module]
}


variable "varenvni" {}
module "ni-module" {
  source     = "../NI"
    varni      = var.varenvni
    vardatasn = var.varenvsn
    vardatapi = var.varenvpi
    depends_on = [module.rg-module, module.vn-module, module.sn-module, module.pi-module]
} 

variable "varenvvm" {}

module "vm-module" {
    source = "../VM"
    varvm = var.varenvvm
    vardatanic = var.varenvni
    depends_on = [ module.ni-module, module.rg-module]
  
}
