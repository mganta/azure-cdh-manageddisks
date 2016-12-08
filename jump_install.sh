#!/bin/bash
echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config
service sshd restart
bash dns_updates.sh
