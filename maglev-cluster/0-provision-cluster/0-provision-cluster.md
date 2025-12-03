# Provision an AWS EC2 cluster

## Install Terraform
```sh
curl -fL -o /home/$USER/Downloads/terraform.zip https://releases.hashicorp.com/terraform/1.3.3/terraform_1.3.3_linux_amd64.zip

unzip -oq /home/$USER/Downloads/terraform.zip -d /home/$USER/.local/bin

rm /home/$USER/Downloads/terraform.zip

terraform init
terraform apply
```
