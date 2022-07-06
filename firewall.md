# Firewall 

## UFW Uncomplicated Firewall 

Procedimento de compilaçao

$ sudo apt install ufw 

$ sudo /etc/default/ufw 

Mudar o parametro ipv6=yes

## Setup default policy 

$ sudo ufw default deny incoming

$ sudo ufw default allow outgoing

sudo ufw allow ssh

sudo ufw status verbose

sudo ufw allow http 
 
sudo ufw allow https

