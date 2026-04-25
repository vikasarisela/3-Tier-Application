#!/bin/bash

component=$1
dnf install ansible -y 
ansible-pull -U https://github.com/vikasarisela/Ansible-Roles-Roboshop-tf.git -e component=$component main.yaml