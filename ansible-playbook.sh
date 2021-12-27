#!/usr/bin/env bash

D_USER=$1
D_PASSWORD=$2

export D_USER
export D_PASSWORD

ansible-playbook -i hosts remoteplaybook_aws.yml

