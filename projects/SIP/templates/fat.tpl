#!/bin/bash -v
set -e
set -u

systemctl stop  crond.service
rm -fr /var/tmp/aws-mon/
systemctl start  crond.service

systemctl enable strong-pm
systemctl start  strong-pm