#!/bin/bash

source ./common.sh
check_root
echo "$(timestamp) [INFO] ===== script started execution======" | tee -a $logs_file

dnf module enable mysql:8.4 -y &>> $logs_file 
dnf install mysql-server -y &>> $logs_file 
validate $? "install mysql server"

systemctl enable mysqld &>> $logs_file 
systemctl start mysqld &>> $logs_file 
validate $? "start mysql"


mysql_secure_installation --set-root-pass RoboShop@1 &>> $logs_file 
validate $? "mysql setup root passwod"

total_time
