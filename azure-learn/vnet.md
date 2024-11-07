create custom vnet on azure

Prerequisite:
1. Subscription
2. Resource Group

Create vm on private subnet of vnet

Install nginx web server on ubuntu vm
```
sudo su -
apt update
apt install nginx -y

cd /var/www/html
vim index.html
<h1>I am learning vnet</h1>
systemctl restart nginx
curl localhost:80
```
Configure Firewall to access webserver
Firewall> Firewall Policy> DNAT Rule > Add Rule collection> create
Add Rule> Choose Rule collection>
