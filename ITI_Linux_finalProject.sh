#!/usr/bin/bash

echo "Make sure to run this script as sudo"
read -p "Please enter the internet connection name: " con_name
read -p "Please enter the Static IP: " static_ip
read -p "Please enter the internet gateway: " internet_gateway
read -p "Please enter the DNS: " DNS

# Changing Network properties
hostnamectl set-hostname intranet.xyz.local
nmcli connection mod $con_name ipv4.addresses $static_ip ipv4.gateway $internet_gateway ipv4.dns $DNS ipv4.method manual
echo "Interface config changed successfully"

ip_no_mask=${static_ip%%/*}

echo "$ip_no_mask   intranet.xyz.local" >> /etc/hosts
systemctl reload NetworkManager.service
nmcli con up lab


# Create groups
groupadd admins
groupadd developers
groupadd employees
echo "Groups are added successfully"

# Make admins group sudoers
echo "%admins  ALL=(ALL)    ALL" > /etc/sudoers.d/admins

# Create users with home directories
useradd -m -c "System_Admin" -G admins admin1
useradd -m -c "Web_Developer" -G developers developer1
useradd -m -c "Regular_Employee" -G employees viewer1
echo "Users are added successfully"

# Set user passwords
echo "admin1:root123" | chpasswd
echo "viewer1:123" | chpasswd
echo "developer1:123" | chpasswd

# Install and start Apache
dnf install httpd -y
systemctl enable --now httpd.service
systemctl status httpd | grep -n2 loaded
echo "Apache Server is working correctly"

# Copy files if needed
# cp ./html/* /var/www/html

# Manage file permissions
mkdir -p /var/www/shared
chown -R apache:apache /var/www/html
chmod -R 774 /var/www/html
chown -R admin1 /var/www/shared
chmod -R 444 /var/www/shared
echo "Permissions are changed successfully"

firewall-cmd --permanent --add-port=80/tcp
firewall-cmd --reload


