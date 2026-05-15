#!/bin/bash

growing the /home volume for terraform purpose
growpart /dev/nvme0n1 4
lvextend -L +30G /dev/mapper/RootVG-homeVol
xfs_growfs /home

# Terraform installation 
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
sudo yum -y install terraform

# sudo lvreduce -r -L 6G /dev/mapper/RootVG-rootVol

# creating databases
cd /home/ec2-user
git clone https://github.com/vikasarisela/3-Tier-Application.git
chown ec2-user:ec2-user -R 3-Tier-Application
cd 3-Tier-Application/40-databases
terraform init
terraform apply -auto-approve