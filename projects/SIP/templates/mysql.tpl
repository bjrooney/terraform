#cloud-config

runcmd:

 - systemctl enable nginx
 - systemctl enable mysqld
 - systemctl start  nginx
 - systemctl start  mysqld








