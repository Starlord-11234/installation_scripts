#!/bin/bash
#
#Author: Dylan Tchedji 

# Since this script needs to be runnable on either CentOS7 or CentOS6, we need to first 
# check which version of CentOS that we are running and place that into a variable.
# Knowing the version of CentOS is important because some shell commands that had
# worked in CentOS 6 or earlier no longer work under CentOS 7
RELEASE=`cat /etc/redhat-release`
isCentOs7=false
SUBSTR=`echo $RELEASE|cut -c1-22`

if [ "$SUBSTR" == "CentOS Linux release 7" ]
then
    isCentOs7=true
fi

if [ "$isCentOs7" == true ]
then
    echo "I am CentOS 7"
fi

CWD=`pwd`

# Let's make sure that yum-presto is installed:
sudo yum install -y yum-presto

# Let's make sure that mlocate (locate command) is installed as it makes much easier when searching in Linux:
sudo yum install -y mlocate

# Although not needed for Jenkins, I like to use vim, so let's make sure it is installed:
sudo yum install -y vim

# The Jenkins setup makes use of wget, so let's make sure it is installed:
sudo yum install -y wget

# Let's make sure that openssl is installed:
sudo yum install -y openssl

# Let's make sure that curl is installed:
sudo yum install -y curl

# Jenkins on CentOS requires Java, but it won't work with the default (GCJ) version of Java. So, let's remove it:
sudo yum remove -y java

# install the OpenJDK version of Java 7:
sudo yum install -y java-1.7.0-openjdk

# Jenkins uses 'ant' so let's make sure it is installed:
sudo yum install -y ant

# Let's now install Jenkins:
sudo wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat/jenkins.repo
sudo rpm --import http://pkg.jenkins-ci.org/redhat/jenkins-ci.org.key
sudo yum install -y jenkins

# Let's start Jenkins
if [ "$isCentOs7" == true ]
then
    sudo systemctl start jenkins
else 
    sudo service jenkins start
fi

# Jenkins runs on port 8080 by default. Let's make sure port 8080 is open:
if [ "$isCentOs7" == true ]
then
    sudo firewall-cmd --zone=public --add-port=8080/tcp --permanent
    sudo firewall-cmd --reload
else
    sudo iptables -A INPUT -p tcp -m tcp --dport 8080 -j ACCEPT
    sudo service iptables save
    sudo service iptables restart
fi

# Let's make sure that git is installed since Jenkins will need this
sudo yum install -y git

# Let's start Jenkins
sudo java -jar jenkins-cli.jar -s http://localhost:8080 safe-restart

# Update the 'locate' database:
sudo updatedb

echo ""
echo "Finished with setup"
echo ""
echo "You can visit your Jenkins installation at the following address (substitute 'localhost' if necessary):"
echo "  http://localhost:8080"
echo ""
echo "Although Jenkins should be installed at this point, it hasn't been secured. See this link:"
echo "https://wiki.jenkins-ci.org/display/JENKINS/Standard+Security+Setup"
echo ""
