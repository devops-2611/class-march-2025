variable "varenvrg" {}
variable "varenvvn" {}
variable "varenvsn" {}
variable "varenvpi" {}


module "rg-module" {
  source = "../RG"
  varrg  = var.varenvrg

}

module "vn-module" {
  source     = "../VN"
  varvn      = var.varenvvn
  depends_on = [module.rg-module]
}

module "sn-module" {
  source     = "../SN"
  varsn      = var.varenvsn
  depends_on = [module.vn-module]
}

module "pi-module" {
  source     = "../PI"
  varpi      = var.varenvpi
  depends_on = [module.rg-module]

}

variable "varenvni" {}
module "ni-module" {
  source    = "../NI"
  varni     = var.varenvni
  vardatasn = var.varenvsn
  vardatapi = var.varenvpi
  depends_on = [ module.sn-module, module.rg-module ]
}

variable "varenvvm" {}
# variable "varenvkv" {}
module "vm-module" {
  source    = "../VM"
  varvm     = var.varenvvm
  vardatani = var.varenvni
  # varkv     = var.varenvkv
  depends_on = [ module.ni-module, module.pi-module ]

}

variable "varenvnsg" {}
module "nsg-module" {
  source = "../NSG"
  varnsg = var.varenvnsg
  depends_on = [ module.rg-module, module.ni-module ]
  
}


variable "varenvninsg" {}
module "nsgni-module" {
  source = "../NSGNI"
  varnsgdata = var.varenvninsg
depends_on = [ module.nsg-module, module.ni-module ]  
}