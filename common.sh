#!/bin/bash
user_id=$(id -u)
logs_folder="/var/log/roboshop"
logs_file="${logs_folder}/${0}.log"
domain_name="koladaws.store"
scripts_dir=$( dirname "$(realpath "$0")")
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

check_root(){
    if [ $user_id -ne 0 ]; then
        echo "please run the script with sudo access" &>> $logs_file
        exit 1
    fi
}

mkdir -p $logs_folder


timestamp(){
   date +"%F %T"
}

validate(){
    if [ $1 -ne 0 ]; then
        echo -e "$(timestamp) [ERROR] ${2}.. is ${R}failed${N}" | tee -a $logs_file
        exit 1
    else 
        echo -e "$ $(timestamp) [INFO] ${2}  is ${G}sucess${N}" | tee -a $logs_file
    fi
}

total_time(){
  
    echo -e "$(timestamp) [INFO] ===== script completed in $SECONDS seconds ======" | tee -a $logs_file
    echo -e "$(timestamp) [INFO] ===== script completed Execution ======" | tee -a $logs_file
}