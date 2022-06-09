![RaspPi](https://img.shields.io/badge/Raspberry%20Pi-Documentation-red)
![GitHub](https://img.shields.io/github/license/mashape/apistatus)

--- 
# Install and harden a headless RaspberryPi: From zero to hero 

Seja para projetos de IOT, seja para utilização um servidor web, o raspberry pi é uma excelente plataforma para projetos e testes...

Eu utilizo a plataforma como base de servidores de teste para 

Quite often you might want to run a ‘headless’ Raspberry Pi without a screen or keyboard, using SSH to connect. SSH can be enabled in the config menu when you first boot the Pi. 

Raspberry Pi comes with poor security by default. If you use it at home or in a small network, it isn’t a big deal, but if you open ports on the Internet, use it as a Wi-Fi access point, or if you install it on a larger network, you need to take security measures to protect your Raspberry Pi. In this article, I’ll show you everything I do with my Linux servers at work to keep them safe.

Improving the security on a Raspberry Pi is similar to any other Linux device. There are logical steps, like using a strong password. And there are also more complex steps like detecting attacks or using encryption.

I’ll share some security tips that you should follow to get higher security for your Raspberry Pi (and they mostly apply to all Linux systems). If you are just using your Raspberry Pi at home, try to apply the first tips at the very least. Follow all of the tips included for a more critical setup, with Internet access or on a larger network.

I selected 17 main security tips, which apply to everyone who hosts a Raspberry Pi and share services on it. I have been a system administrator for 20 years, and these are the tips I apply to any new server installation.

They are in order of risk level. If you think you are highly exposed, follow all the steps, and you’ll be safe.
If your risk level isn’t very much, you’ll only have to follow only the first steps.


## Pré-requisitos: 

- Raspberry Pi;
- MicroSD Card (recomendado ao menos 16Gb, SD10); 
- Adaptador de cartão SD
- Raspberry Pi fonte 

## Instalação

Faça o download do Raspberry Pi Imager no computador local, de acordo com o sistema operacional. O Imager está  disponível à partir da Rasgit push pberry Pi Foundation.

https://www.raspberrypi.com/software/

Após a instalação, lance o Imager e escolha a versão do sistema operacional clicando em `CHOOSE OS`. 

![Imager etapa 01](./images/imager01.png)

Na lista `Operating System`, clique na opção `Raspberry Pi OS (Other)` para escolher a instalação da versão do Raspberry Pi OS sem desktop. 

![Imager etapa 02](./images/imager02.png)

Escolha a primeira opção, `Raspberry Pi OS Lite (32-bit)`, assegurando-se que esta é a versão sem desktop (`"A port of Debian with no desktop environment"`). 

![Imager etapa 03](./images/imager03.png)

Escolha o cartão microSD que será gravado clicando em `CHOOSE SD CARD`. Em seguida, clique em `WRITE` para começar a gracação do sistema operacional no cartão.  

![Imager etapa 04](./images/imager04.png)


Acompanhe a instalação 

Ao fim da instalação, ejete o cartão SD e reconecte-o ao computador. 


### Configure wifi e acesso remoto

Conforme o seu sistema operacional, acesse o drive chamdo `boot`.

Para habilitar o acesso SSH, crie um arquivo vazio chamado `ssh`: 

```sh
$ touch ssh 
``` 

Ainda dentro do diretório `/boot`, crie um arquivo `wpa_supplicant.conf` e cole o conteúdo abaixo: 

```
country=ca
update_config=1
ctrl_interface=/var/run/wpa_supplicant

network={
 scan_ssid=1
 ssid="MyNetworkSSID"
 psk="Pa55w0rd1234"
}
```

Altere os campos `ssid` e `psk` para os valores da sua rede local. 


Insera o cartão no Raspberry Pi, espere alguns minutos até o sistema inicializar, e faça o seu primeiro logon com o usuário default da distribuição Raspberry Pi OS. 

`ssh pi@raspberrypi`

A senha do usuário default é `raspberry`. 

Caso o device não seja localizado, verifique as alternativas para descobrir um Raspberry Pi em uma rede local no [Descubra o endereço IP do seu Raspberry Pi](./LocateRaspberryPiNetwork.md). 

## Realize a atualização inicial do Raspberry Pi 

É preciso atualizar a distribuição: aplicar patches de segurança, melhorias etc desde que a imagem do SO foi gerada. 

Operação demorada, pode levar mais de 30 min dependendo do modelo de RPi que você possua. Tome um café. 


```sh
$ sudo apt-get update 
$ sudo apt-get full-upgrade -y 
$ sudo apt-get dist-upgrade -y
$ sudo apt-get clean 
$ sudo apt autoremove 
```

Verifique o script [update-server.sh](./scripts/update-server.sh) para um exemplo de script de atualização que pode ser incluído na schedule via cron para sua execução cíclica. 

# Assegure o acesso ao sistema 

O acesso ao sistema se dá por meio de contas de usuários que devem ser geridas e acompanhadas. 

Como nós lidaremos com a criação de usuários e com a troca de senhas, é recomendável o uso de um programa de gestão de senhas, como Keepass ou equivalente. No mínimo, mantenha um caderno de log para registrar os seus usuário. 

## Crie um novo usuário 

O usuário default `pi` é inseguro porque ele é conhecido amplamente. Muitas tentativas de invasão de sistema começam exatamente explorando os usuários default dos sistemas. 

Como exemplo nós criaremos um usuario chamado `secpi`. 

```sh
$ sudo adduser secpi        # vai pedir a criação de uma nova senha. Para os outros campos, digite enter para aceitar o branco. 
$ sudo adduser secpi sudo   # adiciona o usuário secpi ao grupo de sudoers 
$ sudo usermod -G adm,dialout,cdrom,sudo,audio,video,plugdev,games,users,input,netdev,spi,i2c,gpio secpi # adiciona secpi a outros grupos de administrador
```
Guarde a senha do usuário recém criado. Após a execução destes comandos, o novo usuário `secpi` está criado, os acessos de administração estão concedidos e um novo diretório *home* está disponível em `/home/secpi`. 

Faça logout du usuário `pi`, e em seguida refaça login com o usuário recém criado, `secpi`. 

```sh
$ logout 
```

Ao refazer o logon com o usuário `secpi`, teste o acesso de administrador do usuário: 

```sh
$ sudo su 
[sudo] password for secpi: 
root@raspberry:/home/secpi# 
```

Se tudo correr bem, o sistema fará uma primeira exortação sobre segurança, e transformará o shell do usuário em super-usuário (`root@...`). 

Desta forma, podemos proceder à supressão do usuário default `pi`. 

## Apague o usuário default pi 


Execute o comando abaixo para fazer a supressão do usuário default `pi`: 

```sh
$ sudo deluser -remove-home pi  # remove o usuario e o seu home
```

## Troque a senha do usuário root 

O usuário `root` tem privilégios elevados, e sua senha é de conhecimento público. Para assegurar sua conta, você deve alterar a senha do usuário root. 

```sh 
$ sudo passwd root
```
Não se esqueça de manter um registro da senha do usuário root. 
## Faça `sudo` exigir a senha do usuário

Edite o arquivo 
```sh
$ sudo nano /etc/sudoers.d/010_pi-nopasswd
```
Ache a linha: 

`pi ALL=(ALL) NOPASSWD: ALL`

e a substitua com a seguinte: 

`pi ALL=(ALL) PASSWD: ALL`

## Reconfigure as chaves do servidor SSH

Reconfigure as chaves do servidor ssh apos uma reinstalacao.

As chaves criadas por default do ssh sao evidentes e simples de serem atacadas. A reconfiguraçao apaga as chaves fracas e recria um conjunto de chaves mais seguras.

Crie um diretorio de backup para guardar chaves antigas; mova as chaves para backup e as apague da configuração do servidor ssh: 

```sh
sudo mkdir /etc/ssh/oldkeys
sudo cp /etc/ssh/ssh_host* /etc/ssh/oldkeys
sudo rm -rf /etc/ssh/ssh_host*
```

Reconfigure as chaves do servidor ssh: 

```sh
sudo dpkg-reconfigure openssh-server
```

Reinicie o servico ssh: 

```sh
sudo service ssh restart
```

## Impeça login do root via SSH 

Edite o arquivo `/etc/ssh/sshd_config` e localize a linha: 

```sh
#PermitRootLogin prohibit-password  
```
Descomente a linha e salve o arquivo. Restarte o servidor SSH: 

```sh
sudo service ssh restart
```

# Remove unnecessary programs (stuff that is just nuisance )
 
```sh
$ df -h     # take note of the space available in your /dev/root partition

Filesystem      Size  Used Avail Use% Mounted on
/dev/root        14G  4.1G  9.4G  31% /
devtmpfs        1.8G     0  1.8G   0% /dev
tmpfs           1.9G     0  1.9G   0% /dev/shm
tmpfs           1.9G   17M  1.9G   1% /run
tmpfs           5.0M   20K  5.0M   1% /run/lock
tmpfs           1.9G     0  1.9G   0% /sys/fs/cgroup
/dev/mmcblk0p1  253M   50M  203M  20% /boot
tmpfs           384M     0  384M   0% /run/user/1001

$ sudo apt-get remove --purge --assume-yes \
scratch* \
libreoffice* \
wolfram-engine* \
sonic-pi \
minecraft-pi 

$ df -h    # compare with the space you had noted and behold the space freed! The difference is the space gained in this uncluttering action. 
```


# Configure the defaults 

```bash
$ sudo raspi-config
```

1 - System options 
    S4 - Hostname 
5 - Localisation
    L1 - Locale
    L2 - Timezone
    L3 - Keyboard
    L4 - Wireless country

# Keep the system updated

```sh
$ sudo apt-get update 
$ sudo apt-get full-upgrade 
$ sudo apt-get clean 
$ sudo apt-get autoremove 
```

# Use of password 

- Don't use auto-login or empty passwords 

- Change the default password for pi 

`passwd`

prefer passphrases with long strings - easier to remember, harder to guess 

# Disable the pi user 

sudo adduser <username> 
sudo adduser <username> sudo 
sudo deluser -remove-home pi 

# Stop unnecessary services 

List running services:  
sudo service --status-all 

Stop a service 
sudo service <service-name> stop 

Start a service 
sudo service <service-name> start 

If it starts automatically on boot, try: 
sudo update-rc.d <service-name> remove

To uninstall it
sudo apt remove <service-name>




# Change SSH default port (not great)

Edit the file  
sudo nano /etc/ssh/sshd_config

Find  
#Port 22 
replace by  
Port 1111 

restart the server  
sudo service ssh restart 


Update the firewall definitions  

Before closing the actual session, open another and try connecting to the new port. 


# Require ssh-keys to login  

# Install fail2ban 

sudo apt install fail2ban

sudo nano /etc/fail2ban/jail.conf

sudo service fail2ban restart

# Install a firewall 

sudo apt-get install ufw 

Allow apache for anyone 

sudo ufw allow 80  
sudo ufw allow 443

Allow ssh for an ip address only  
sudo ufw allow from 192.168.1.100 port 22

Enable the firewall   
sudo ufw enable 

Check everything works fine 

sudo ufw status verbose

# Backup your data 

#Crypt your connections 

Change weak protocols for better ones 
http ==> https
telnet ==> ssh 
ftp ==> sftp

# Use a VPN 

# Protect the physical access

# Check the logs regularly

`/var/log/syslog`: main log file for all services.  
`/var/log/message`: whole systems log file.  
`/var/log/auth.log`: all authentication attempts are logged here.  
`/var/log/mail.log`   
Any critical applications log file, for example `/var/log/apache2/error.log` or `/var/log/mysql/error.log`.
 
Extra activity: install and integrate its logs to a log observer solution, like `ELK Stack` or `Splunk`. 

# Read the news 

CVE Details  
Exploit DB  
NVD Feeds  