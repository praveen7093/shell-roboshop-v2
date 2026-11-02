#!/bin/bash
source ./common.sh

check_root

echo "$(timestamp) [INFO] ===== script started execution======" | tee -a $logs_file

cp rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo
validate $? "adding rabbitmq repo"

dnf install erlang rabbitmq-server -y &>> $logs_file
validate $? "install rabbit mq server" &>> $logs_file

systemctl enable rabbitmq-server &>> $logs_file
systemctl start rabbitmq-server &>> $logs_file
validate  $? "start rabbitmw server"

rabbitmqctl list_users | grep -qw "roboshop"
if [ $? -ne 0 ]; then
    rabbitmqctl add_user roboshop roboshop123 &>> $logs_file
    validate $? "creating rabbitmq roboshop user"
else
   echo -e "$(timestamp) [INFO] Rabbitmq user already exist..${Y}SKIPPING${N}"
fi
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> $logs_file
validate $? "setting permission for roboshop- user"

timestamp
