#!/bin/bash -v
set -e
set -u


systemctl stop  crond.service
rm -fr /var/tmp/aws-mon/
systemctl start  crond.service

mkfs.xfs /dev/xvdg
mkdir -p /var/opt/jfrog
echo "/dev/xvdg /var/opt/jfrog xfs defaults 0 0" >> /etc/fstab
mount /dev/xvdg

systemctl stop firewalld 
firewall-offline-cmd    --add-port=8081/tcp
systemctl start firewalld 

wget https://bintray.com/jfrog/artifactory-rpms/rpm -O bintray-jfrog-artifactory-rpms.repo
sudo mv bintray-jfrog-artifactory-rpms.repo /etc/yum.repos.d/

yum -y install jfrog-artifactory-oss

systemctl enable artifactory
systemctl start  artifactory
