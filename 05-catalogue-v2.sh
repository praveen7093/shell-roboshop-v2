#!/bin/bash
app_name=catalogue
source ./common.sh

echo "$(timestamp) [INFO] ===== script started execution======" | tee -a $logs_file
check_root
app_setup
nodejs_setup
systemd_setup

cp "$scripts_dir//mongo.repo" /etc/yum.repos.d/mongo.repo
validate $? "adding mongo repo"

dnf install mongodb-mongosh -y &>> $logs_file
validate $? "installing mongodb client"

product_count=$(mongosh --host "mongodb.$domain_name" --quiet --eval 'db.getSiblingDB("catalogue").products.countDocuments()' 2>> $logs_file)
validate $? "connecting to mongodb"

if [ $product_count -eq 0 ]; then
    mongosh --host "mongodb.$domain_name" </app/db/master-data.js
    validate $? "loading products"
else 
    echo -e "$(timestamp) [INFO] products are already loaded....${y}Skipping${N}"
fi

restart
total_time