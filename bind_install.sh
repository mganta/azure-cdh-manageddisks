#!/bin/bash

yum -y install bind bind-utils


mkdir /etc/named/zones

mv /etc/named.conf /etc/named.conf.orig

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
service network restart
