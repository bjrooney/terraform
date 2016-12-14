#!/bin/bash -v
set -e
set -u

systemctl stop  crond.service
rm -fr /var/tmp/aws-mon/
systemctl start  crond.service

public_hostname=openvpn."${var.domain}"
admin_user=openvpn
admin_pw=&&mongrel&elephant&figtree&&



