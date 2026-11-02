#!/bin/bash
source ./common.sh

check_root

dnf module disable redis -y &>> $logs_file 
dnf module enable redis:7 -y &>> $logs_file
dnf install redis -y
validate $? "installing redis"

sed -i -e 's/^bind 127.0.0.1/bind 0.0.0.0/' -e 's/^protected-mode yes/protected-mode no/' /etc/redis/redis.conf
validate $? "allowing remote connections to redis"


systemctl enable redis
systemctl start redis
validate $? "enable and start redis"

total_time
