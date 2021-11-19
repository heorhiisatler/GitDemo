#!/usr/bin/env bash

export USER=$1
export PASSWORD=$2

ansible-playbook -i hosts remoteplaybook_centos_dhub.yml

