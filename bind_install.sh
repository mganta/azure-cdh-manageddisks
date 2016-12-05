#!/bin/bash
exit 0
#script not ready yet
yum -y install bind bind-utils

wget https://raw.githubusercontent.com/mganta/azure-cdh-manageddisks/master/dns/db.internal
wget https://raw.githubusercontent.com/mganta/azure-cdh-manageddisks/master/dns/db.internal.16
wget https://raw.githubusercontent.com/mganta/azure-cdh-manageddisks/master/dns/db.internal.18
wget https://raw.githubusercontent.com/mganta/azure-cdh-manageddisks/master/dns/db.internal.20

wget https://raw.githubusercontent.com/mganta/azure-cdh-manageddisks/master/dns/db.reverse
wget https://raw.githubusercontent.com/mganta/azure-cdh-manageddisks/master/dns/db.reverse.16
wget https://raw.githubusercontent.com/mganta/azure-cdh-manageddisks/master/dns/db.reverse.18
wget https://raw.githubusercontent.com/mganta/azure-cdh-manageddisks/master/dns/db.reverse.20

wget https://raw.githubusercontent.com/mganta/azure-cdh-manageddisks/master/dns/named.conf.local
wget https://raw.githubusercontent.com/mganta/azure-cdh-manageddisks/master/dns/named.conf.local.16
wget https://raw.githubusercontent.com/mganta/azure-cdh-manageddisks/master/dns/named.conf.local.18
wget https://raw.githubusercontent.com/mganta/azure-cdh-manageddisks/master/dns/named.conf.local.20

wget https://raw.githubusercontent.com/mganta/azure-cdh-manageddisks/master/dns/named.conf

wget https://raw.githubusercontent.com/mganta/azure-cdh-manageddisks/master/scripts/dns_updates.sh


mkdir /etc/named/zones

chmod 755 dns_updates.sh
#mv /etc/named.conf /etc/named.conf.orig

cp named.conf /etc/named.conf

cp named.conf.local /etc/named/named.conf.local
cp named.conf.local.16 /etc/named/named.conf.local.16
cp named.conf.local.18 /etc/named/named.conf.local.18
cp named.conf.local.20 /etc/named/named.conf.local.20

cp db.internal /etc/named/zones/db.internal
cp db.internal.16 /etc/named/zones/db.internal.16
cp db.internal.18 /etc/named/zones/db.internal.18
cp db.internal.20 /etc/named/zones/db.internal.20

cp db.reverse /etc/named/zones/db.reverse
cp db.reverse.16 /etc/named/zones/db.reverse.16
cp db.reverse.18 /etc/named/zones/db.reverse.18
cp db.reverse.20 /etc/named/zones/db.reverse.20

chown -R named:named /etc/named*
service named start
chkconfig named on
bash dns_updates.sh cdh-boa.internal
service network restart
