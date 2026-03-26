#!/bin/bash
#####
# this script will setup this project.
# run ./setup.sh to run this project.
#####
# Include files. 
. ./scripts/utils.sh
. ./scripts/variables.sh



function clean_up(){
    if rm -rf ./target
    then
        echo -e "${GREEN}clean up successfull.${NOCOLOR}"
    else
        echo -e "${GREEN}not able to do clean up.${NOCOLOR}"
    fi
}

trap "clean_up;exit 2" 2

if [[ $UID != 0 ]]
then
    print_exit 1 "user is not a root user"
fi

apt-get update > /dev/null &
last_command_pid=$!
showProgress ${last_command_pid}

wait ${last_command_pid} || print_exit 1 "not able to update the repository."


install_tomcat9_using_wget

cd /home/ubuntu/spring-boot-example || exit 1

PUBLIC_IP=$(curl ifconfig.me)

# Stop Tomcat before deployment (recommended)
echo "Stopping Tomcat9 before deployment..."
/opt/tomcat9/bin/shutdown.sh

# Remove old deployment
echo "Removing old deployment (if exists)..."
rm -rf /opt/tomcat9/webapps/*

# Deploy new application
echo "Deploying application to Tomcat9..."
/opt/tomcat9/bin/startup.sh

if cp -rf ./* /opt/tomcat9/webapps/
then
    echo "Application Deployed successfully. You can access it on http://${PUBLIC_IP}:8080"
else
    print_exit 1 "not able to Deploy the application."
fi

# Clean Up code.

clean_up
exit 0