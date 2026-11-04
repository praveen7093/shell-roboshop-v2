#!/bin/bash
app_name=shipping
source ./common.sh

check_root
app_setup
java_setup
systemd_setup

count=$(mysql -h mysql.$domain_name -u root  -pRoboShop@1 -N -B -e "SELECT COUNT(*) FROM  cities.cities;" 2>> $logs_file)
if [[ -z $count ]] || [ $count -eq 0]; then
    # Load cities database and master data
    mysql -h mysql.$domain_name -u root -p'RoboShop@1' < /app/db/master-data.sql
    validate $? "loading cities master data"
else
    echo -e "$(timestamp) [INFO] master data is already loaded....${Y}SKIPPING${N}"
fi

 # Configure application database user
mysql -h mysql.$domain_name -u root -p'RoboShop@1' < /app/db/app-user.sql
validate $? "configuring shipping database user"

# restart
# total_time

