#!/bin/bash -v
set -e
set -u

systemctl stop  crond.service
rm -fr /var/tmp/aws-mon/
systemctl start  crond.service

mkfs.xfs /dev/xvdg
mkdir -p /var/lib/jenkins
echo "/dev/xvdg /var/lib/jenkins xfs defaults 0 0" >> /etc/fstab
mount /dev/xvdg

wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat/jenkins.repo
rpm --import https://jenkins-ci.org/redhat/jenkins-ci.org.key
yum install -y jenkins
systemctl enable jenkins
systemctl restart jenkins
yum install -y git
yum install -y bzip2

systemctl stop firewalld
firewall-offline-cmd  --add-port=1080/tcp
systemctl start firewalld

wget http://dev.mysql.com/get/mysql57-community-release-el7-7.noarch.rpm

yum localinstall -y mysql57-community-release-el7-7.noarch.rpm

yum install -y  mysql-community-server

systemctl enable mysqld
systemctl start  mysqld
