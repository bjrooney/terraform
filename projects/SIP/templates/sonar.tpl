#!/bin/bash -v
set -e
set -u

systemctl stop  crond.service
rm -fr /var/tmp/aws-mon/
systemctl start  crond.service

systemctl stop firewalld 
firewall-offline-cmd    --add-port=9000/tcp
systemctl start firewalld 

sudo wget -O /etc/yum.repos.d/sonar.repo http://downloads.sourceforge.net/project/sonar-pkg/rpm/sonar.repo

yum -y install sonar
systemctl enable sonar
systemctl start  sonar

