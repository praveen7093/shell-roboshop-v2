#!/bin/bash
source ./common.sh
dnf module disable nginx -y &>> logs_file
dnf module enable nginx:1.26 -y &>> logs_file
dnf install nginx -y &>> logs_file
validate $? "installing nginx"

systemctl enable nginx &>> logs_file
systemctl start nginx &>> logs_file
validate $? "enable/start nginx server"


id roboshop &>> $logs_file
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    validate $? "creating system user"
else
    echo -e "system user roboshop already user is exisit....${Y}Skipping${N}"
fi

rm -rf /usr/share/nginx/html/* &>> $logs_file
validate $? "removing default content"

curl -L -o /tmp/frontend.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/frontend-v4.zip
cd /usr/share/nginx/html &>> $logs_file
unzip /tmp/frontend.zip &>> $logs_file
validate $? "downloading and unzipping frontend code"

sed "s/DOMAIN_NAME/${domain_name}/g" "$scripts_dir/roboshop.conf" > /etc/nginx/default.d/roboshop.conf
validate $? "copying roboshop nginx configuration"
validate $? "copied roboshop config"

nginx -t &>> $logs_file
validate $? "Nginx configuration"

systemctl restart nginx &>> $logs_file
validate $? "restarting nginx"

total_time