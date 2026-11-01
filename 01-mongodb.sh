#!/bin/bash
source ./common.sh
check_root()
cp mongo.repo /etc/yum.repos.d/mongo.repo
validate $? "Adding mongo repo"

dnf install mongodb-org -y &>> $logs_file
validate $? "install mongoDB"

systemctl enable mongod
systemctl start mongod
validate $? "enable and start mongoDB"

sed -i 's/127\.0\.0\.1/0.0.0.0/' /etc/mongod.conf
validate $? "configuring remote connections to MongoDB"

systemctl restart mongod &>> "$logs_file"
validate $? "restarting MongoDB"

systemctl restart mongod
validate $? "restarting mongodb"


