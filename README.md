# class-march-2025

* commands *

terraform init   -- will create the .terraform.lock.hcl  file
terraform validate
terraform fmt
terraform plan
terraform apply -auto-approve

az vm image list --publisher MicrosoftWindowsDesktop --offer Windows-10 --sku Pro --out table --location "West US" --all
az vm image list --publisher Canonical --offer UbuntuServer --out table --location "West US" --all
az vm list-sizes --location "West US" --out table


az login --service-principal --username 75d461cc-79f9-461a-9903-40ce03137f28  --password 1D98Q~cNoo0EkumEazf6BIng14jbq-KZM2fSsdh3 --tenant 06442773-4112-42a4-a440-05b0566119c5
