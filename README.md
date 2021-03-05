# tf_azurerm_bug_10858

Example repo for reproducing the bug

1. initial `terraform init`
1. Create the initial Azure function app using a dedicated plan `terraform plan` and `terraform apply`
1. Change to consumption plan

```sh
TF_VAR_sku_tier=dynamic TF_VAR_sku_size=Y1 TF_VAR_site_config={} terraform plan
TF_VAR_sku_tier=dynamic TF_VAR_sku_size=Y1 TF_VAR_site_config={} terraform apply
```
