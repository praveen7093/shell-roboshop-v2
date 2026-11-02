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

nodejs_setup(){
    dnf module disable nodejs -y &>> $logs_file
    dnf module enable nodejs:24 -y &>> $logs_file
    dnf install nodejs -y  &>> $logs_file
    validate $? "installing nodejs 24" &>> $logs_file

    node -v
    validate $? "verifying the version"

    npm install &>> $logs_file
    validate $? "installing dependencies"
}

app_setup(){
    id roboshop &>> $logs_file
    if [ $? -ne 0 ]; then
        useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
        validate $? "creating system user"
    else
        echo -e "system user roboshop already user is exisit....${Y}Skipping${N}"
    fi
    rm -rf /app
    validate $? "removing old code"

    mkdir -p /app
    validate $? "creatin app directory"

    curl -L -o "/tmp/$app_name.zip" "https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/$app_name-v4.zip"
    validate $? "downloading $app_name" 

    cd /app
    unzip "/tmp/$app_name.zip" &>> logs_file    
    validate $? "unzipping $app_name"
}

systemd_setup(){
    sed -i "s/DOMAIN_NAME/$domain_name/g" "$scripts_dir/$app_name.service"    
    cp "$scripts_dir/$app_name.service" /etc/systemd/system/$app_name.service

    systemctl daemon-reload &>> $logs_file
    systemctl enable $app_name &>> $logs_file
    systemctl start $app_name &>> $logs_file    
    validate $? "starting and enabling the $app_name service"
}

restart(){
    systemctl restart $app_name
    validate $? "restarting $app_name"
}
java_setup(){
    dnf module enable maven:3.9 -y &>> logs_file
    dnf install maven java-25-openjdk-devel -y &>> logs_file
    validate $? "installing java and maven"

    echo "export JAVA_HOME=$(dirname $(dirname $(readlink -f /usr/bin/java)))" > /etc/profile.d/java.sh
    source /etc/profile.d/java.sh
    echo $JAVA_HOME
    validate $? "setting JAVA_HOME for maven"

    alternatives --set  java "/usr/lib/jvm/java-25-openjdk/bin/java"
    validate $? "setting java 25 as default java version"

    mvn clean package &>> $logs_file
    validate $? "installing dependencies"

    mv target/shipping.jar shipping.jar
    validate $? "moving shipping jar files"

}
python_setup(){
    dnf install python3.14 python3.14-pip -y &>> $logs_file
    validate $? "installing pyhton 3.14"

    python3.14 --version
    validate $? "checking version"

    python3.14 -m venv /app/.venv &>> $logs_file
    validate $? "creating virtual environment"

    /app/.venv/bin/pip install -r requirements.txt &>> $logs_file
    validate $? "installing dependencies"
}