#!/bin/bash

yum -y install bind bind-utils
echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config
service sshd restart

mkdir /etc/named/zones
mv /etc/named.conf /etc/named.conf.orig

wget https://raw.githubusercontent.com/mganta/azure-cdh-manageddisks/master/dns/db.internal -O /etc/named/zones/db.internal
wget https://raw.githubusercontent.com/mganta/azure-cdh-manageddisks/master/dns/db.internal.16 -O /etc/named/zones/db.internal.16
wget https://raw.githubusercontent.com/mganta/azure-cdh-manageddisks/master/dns/db.internal.18 -O /etc/named/zones/db.internal.18
wget https://raw.githubusercontent.com/mganta/azure-cdh-manageddisks/master/dns/db.internal.20 -O /etc/named/zones/db.internal.20

wget https://raw.githubusercontent.com/mganta/azure-cdh-manageddisks/master/dns/db.reverse -O /etc/named/zones/db.reverse
wget https://raw.githubusercontent.com/mganta/azure-cdh-manageddisks/master/dns/db.reverse.16 -O /etc/named/zones/db.reverse.16
wget https://raw.githubusercontent.com/mganta/azure-cdh-manageddisks/master/dns/db.reverse.18 -O /etc/named/zones/db.reverse.18
wget https://raw.githubusercontent.com/mganta/azure-cdh-manageddisks/master/dns/db.reverse.20 -O /etc/named/zones/db.reverse.20

wget https://raw.githubusercontent.com/mganta/azure-cdh-manageddisks/master/dns/named.conf.local -O /etc/named/named.conf.local
wget https://raw.githubusercontent.com/mganta/azure-cdh-manageddisks/master/dns/named.conf.local.16 -O /etc/named/named.conf.local.16
wget https://raw.githubusercontent.com/mganta/azure-cdh-manageddisks/master/dns/named.conf.local.18 -O /etc/named/named.conf.local.18
wget https://raw.githubusercontent.com/mganta/azure-cdh-manageddisks/master/dns/named.conf.local.20 -O /etc/named/named.conf.local.20

wget https://raw.githubusercontent.com/mganta/azure-cdh-manageddisks/master/dns/named.conf -O /etc/named.conf

chown -R named:named /etc/named*
service named start
chkconfig named on
bash dns_updates.sh
yum -y install bind-chroot
service named restart
