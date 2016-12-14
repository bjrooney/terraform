#cloud-config

runcmd:

 - systemctl enable nginx
 - systemctl start  nginx



