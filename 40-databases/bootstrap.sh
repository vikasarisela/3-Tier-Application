#!/bin/bash

component=$1
dnf install ansible -y 
# ansible-pull -U https://github.com/vikasarisela/Ansible-Roles-Roboshop-tf.git -e component=$component main.yaml

REPO_URL=https://github.com/vikasarisela/Ansible-Roles-Roboshop-tf.git
REPO_DIR=/opt/roboshop/ansible
ANSIBLE_DIR=Ansible-Roles-Roboshop-tf

mkdir -p $REPO_DIR
mkdir -p /var/log/roboshop/
touch ansible.log

cd $REPO_DIR


# check if ansible repo is already cloned or not

if [ -d $ANSIBLE_DIR ]; then
    
    cd $ANSIBLE_DIR
    git pull
else 
    git clone $REPO_URL
    cd $ANSIBLE_DIR
fi

ansible-playbook -e component=$component main.yaml