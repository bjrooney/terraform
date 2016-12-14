#!/bin/bash -v

set -e
set -u

graylog-ctl reconfigure
graylog-ctl restart