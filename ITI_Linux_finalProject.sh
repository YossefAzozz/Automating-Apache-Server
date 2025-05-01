#! /usr/bin/bash

# Getting required Data
echo "make sure to run theis script as sudo"
read -p "please enter the internet interface name: " if_name
read -p "please enter the Static IP: " static_ip
read -p "please enter the internet gateway: " internet_gateway
read -p "please enter the DNS: " DNS

# changing Network properties

hostnamectl hostname intranet.xyz.local
nmcli connection modify $if_name ipv4.addresses $static_ip ipv4.gateway $internet_gateway ipv4.dns $DNS ipv4.method manual
echo "interface config changed successfuly"
echo "$static_ip   intranet.xyz.local" >> /etc/hosts

#Create group for admins
groupadd admins
groupadd developers
groupadd employees

#Make group admins as sudoers

echo "%admins  ALL=(ALL)    ALL" > /etc/sudoers.d/admins


# Creating Users
useradd -c "System_Admin" -G admins admin1
useradd -c "Web_Developer" -G developers developer1 
useradd -c "Regular_Employee" -G employees viewer1

echo "root123" | passwd --stdin admin1
echo "123" | passwd --stdin viewer1
echo "123" | passwd --stdin developer1

# Installing Apache Server
sudo dnf install httpd -y
systemctl enable --now httpd.service
systemctl status httpd | grep -n2 loaded

#cp ./html/* /var/www/html

#managing file permission
mkdir /var/www/shared

chown -R apache:developers /var/www/html
chmod -R 774 /var/www/html
chown -R admin1 /var/www/shared
chmod -R 444 /var/www/shared

echo "permission changed successfuly"




