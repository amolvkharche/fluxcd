This repo is to create Kubernetes cluster on Digital Ocean.

Rename `terraform.tfvars.example` with `terraform.tfvars` and add your token from **Digital Ocean(API-> Tokens->Generate New Token).**

Additionally, you can modify `terraform.tfvars` by adding cluster_name, region, node size , K8s version, and node image.
you can find the latest tag here https://slugs.do-api.dev/

  
Initialize directory with terraform.

  ```bash
terraform init 
terraform plan
terraform apply
```

Once terraform is successfully applied, you will see the message below

  Outputs:
  ```bash
  kubeconfig_path_do = "./kubeconfig"
```
![image](https://github.com/amolvkharche/digitalOceank8s/assets/83961171/18e0bcd9-a391-4980-9734-06876f52796c)

This is your kubecofig file to access your Digital Ocean K8s cluster.
   `export KUBECONFIG=$PWD/kubeconfig`

![image](https://github.com/amolvkharche/digitalOceank8s/assets/83961171/dc16955f-eec8-4f24-ba5f-ffdc8bb74728)
