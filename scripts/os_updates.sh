#!/bin/sh
# cat a here-doc represenation of the hooks to the appropriate file
cat > /etc/dhcp/dhclient-exit-hooks <<"EOF"
#!/bin/bash
printf "\ndhclient-exit-hooks running...\n\treason:%s\n\tinterface:%s\n" "${reason:?}" "${interface:?}"
# only execute on the primary nic
if [ "$interface" != "eth0" ]
then
    exit 0;
fi
# when we have a new IP, perform nsupdate
if [ "$reason" = BOUND ] || [ "$reason" = RENEW ] ||
   [ "$reason" = REBIND ] || [ "$reason" = REBOOT ]
then
    printf "\tnew_ip_address:%s\n" "${new_ip_address:?}"
    host=$(hostname | cut -d'.' -f1)
    domain=$(hostname | cut -d'.' -f2- -s)
    domain=${domain:=$1} # If no hostname is provided, use cdh-cluster.internal
    IFS='.' read -ra ipparts <<< "$new_ip_address"
    ptrrec="${ipparts[3]}.${ipparts[2]}.${ipparts[1]}.${ipparts[0]}.in-addr.arpa"
    nsupdatecmds=$(mktemp -t nsupdate.XXXXXXXXXX)
    resolvconfupdate=$(mktemp -t resolvconfupdate.XXXXXXXXXX)
    echo updating resolv.conf
    grep -iv "search" /etc/resolv.conf > "$resolvconfupdate"
    echo "search $domain" >> "$resolvconfupdate"
    cat "$resolvconfupdate" > /etc/resolv.conf
    echo "Attempting to register $host.$domain and $ptrrec"
    {
        echo "update delete $host.$domain a"
        echo "update add $host.$domain 600 a $new_ip_address"
        echo "send"
        echo "update delete $ptrrec ptr"
        echo "update add $ptrrec 600 ptr $host.$domain"
        echo "send"
    } > "$nsupdatecmds"
    nsupdate "$nsupdatecmds"
fi
#done
exit 0;
EOF
chmod 755 /etc/dhcp/dhclient-exit-hooks
service network restart

echo "Done preparing disks.  Now ls -la looks like this:"
ls -la /
# Create Impala scratch directory
numDataDirs=$(ls -la / | grep data | wc -l)
echo "numDataDirs:" $numDataDirs
let endLoopIter=(numDataDirs - 1)
for x in $(seq 0 $endLoopIter)
do 
  echo mkdir -p /data${x}/impala/scratch 
  mkdir -p /data${x}/impala/scratch
  chmod 777 /data${x}/impala/scratch
done

setenforce 0 >> /tmp/setenforce.out
cat /etc/selinux/config > /tmp/beforeSelinux.out
sed -i 's^SELINUX=enforcing^SELINUX=disabled^g' /etc/selinux/config || true
cat /etc/selinux/config > /tmp/afterSeLinux.out

/etc/init.d/iptables save
/etc/init.d/iptables stop
chkconfig iptables off

yum install -y ntp
service ntpd start
service ntpd status
chkconfig ntpd on

echo never | tee -a /sys/kernel/mm/transparent_hugepage/enabled
echo "echo never | tee -a /sys/kernel/mm/transparent_hugepage/enabled" | tee -a /etc/rc.local
echo vm.swappiness=1 | tee -a /etc/sysctl.conf
echo 1 | tee /proc/sys/vm/swappiness
ifconfig -a >> initialIfconfig.out; who -b >> initialRestart.out

echo net.ipv4.tcp_timestamps=0 >> /etc/sysctl.conf
echo net.ipv4.tcp_sack=1 >> /etc/sysctl.conf
echo net.core.rmem_max=4194304 >> /etc/sysctl.conf
echo net.core.wmem_max=4194304 >> /etc/sysctl.conf
echo net.core.rmem_default=4194304 >> /etc/sysctl.conf
echo net.core.wmem_default=4194304 >> /etc/sysctl.conf
echo net.core.optmem_max=4194304 >> /etc/sysctl.conf
echo net.ipv4.tcp_rmem="4096 87380 4194304" >> /etc/sysctl.conf
echo net.ipv4.tcp_wmem="4096 65536 4194304" >> /etc/sysctl.conf
echo net.ipv4.tcp_low_latency=1 >> /etc/sysctl.conf
sed -i "s/defaults        1 1/defaults,noatime        0 0/" /etc/fstab

#use the key from the key vault as the SSH authorized key
mkdir /home/$ADMINUSER/.ssh
chown $ADMINUSER /home/$ADMINUSER/.ssh
chmod 700 /home/$ADMINUSER/.ssh

ssh-keygen -y -f /var/lib/waagent/*.prv > /home/$ADMINUSER/.ssh/authorized_keys
chown $ADMINUSER /home/$ADMINUSER/.ssh/authorized_keys
chmod 600 /home/$ADMINUSER/.ssh/authorized_keys

myhostname=`hostname`
fqdnstring=`python -c "import socket; print socket.getfqdn('$myhostname')"`
sed -i "s/.*HOSTNAME.*/HOSTNAME=${fqdnstring}/g" /etc/sysconfig/network
/etc/init.d/network restart

#disable password authentication in ssh
#sed -i "s/UsePAM\s*yes/UsePAM no/" /etc/ssh/sshd_config
#sed -i "s/PasswordAuthentication\s*yes/PasswordAuthentication no/" /etc/ssh/sshd_config
#/etc/init.d/sshd restart