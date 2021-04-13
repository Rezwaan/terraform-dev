#!/bin/bash
apt-get update
apt-get install git ansible -y
mkdir /var/ansible_playbooks
git clone ${playbook_repository} /var/ansible_playbooks
ansible-playbook /var/ansible_playbooks/ansible/mongo-db-playbook.yml -i /var/ansible_playbooks/ansible/hosts  --extra-vars "database_replica_type=master env=dev"