#!/bin/bash -v
set -e
set -u

systemctl stop  crond.service
rm -fr /var/tmp/aws-mon/
systemctl start  crond.service

public_hostname=jumpbox."${var.domain}"
admin_user=jumpbox
admin_pw=*19@doubt@INDICATE@needle@05***