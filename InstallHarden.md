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

Faça o download do Raspberry Pi Imager no computador local, de acordo com o sistema operacional. O Imager está  disponível à partir da Raspberry Pi Foundation.

https://www.raspberrypi.com/software/

Após a instalação, lance o Imager e escolha a versão do OS: 

CHOOSE OS -> Raspberry Pi OS (Other) -> Raspberry Pi OS Lite (32-bits)

Acompanhe a instalação 

Ao fim da instalação, ejetar o cartão SD e reconectá-lo. 

Acessar o drive, e entrar no diretório `/boot`

Para habilitar o acesso SSH, criar um arquivo vazio chamado `ssh`: 

```
$ touch ssh 
``` 

- Configurar wifi. 

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

... config with wifi credentials ... 

Inserir o cartão no Raspberry Pi, e fazer o primeiro logon com o usuário default da distribuição do Raspbian. 
`ssh pi@<ip address>`

`pi:raspberry`

# Take note of your ip address 

`/usr/share/nmap/nmap-mac-prefixes`

`DCA632` Raspberry Pi Trading   
`E45F01` Raspberry Pi Trading  
`B827EB` Raspberry Pi Foundation  



## Alternartiva 1: `ping`

O raspbian vem configurado com o hostname 

```
$ ping raspberry

Pinging raspberry.lan [192.168.1.186] with 32 bytes of data:
Reply from 192.168.1.186: bytes=32 time=2ms TTL=64
Reply from 192.168.1.186: bytes=32 time=7ms TTL=64
Reply from 192.168.1.186: bytes=32 time=3ms TTL=64
Reply from 192.168.1.186: bytes=32 time=3ms TTL=64

Ping statistics for 192.168.1.186:
    Packets: Sent = 4, Received = 4, Lost = 0 (0% loss),
Approximate round trip times in milli-seconds:
    Minimum = 2ms, Maximum = 7ms, Average = 3ms
    
```

## Alternativa 2: arp 

The MAC Address, or Media Access Control Address, of a host, identifies the serial number of the Network Card. 
This serial number can be traced back to a vendor. 
For the Raspberry Pi Foundation, the MAC Address will begin with the characters B8:27:EB. 
Scanning the network with nmap we can return hosts that are up and their MAC Address. 
Make you are running the command as root or with sudo as the MAC Address is not returned if you run the command as a standard user. 
I am using the address range 192.168.0.0/24 as that is the network that I have at home. You will need to adjust to match your network.

```bash 
$ arp -av

Interface: 192.168.1.216 --- 0x12
  Internet Address      Physical Address      Type
  192.168.1.1           3c-90-66-98-0e-01     dynamic
  192.168.1.123         00-00-00-00-00-00     invalid
  192.168.1.135         dc-a6-32-4a-ed-f3     dynamic
  192.168.1.147         00-00-00-00-00-00     invalid
  192.168.1.176         ec-2c-e9-72-00-c2     dynamic
  192.168.1.179         c8-3a-6b-e2-87-21     dynamic
  192.168.1.185         00-00-00-00-00-00     invalid
  192.168.1.186         dc-a6-32-1a-56-ec     dynamic
  192.168.1.235         00-00-00-00-00-00     invalid
  192.168.1.243         94-53-30-7d-d5-99     dynamic
  192.168.1.255         ff-ff-ff-ff-ff-ff     static
  
```

## Alternativa 3: nmap 

NMAP or the Network Mapper is a tool originally developed in 1997 for Linux. 
Availability is much better now with versions for OSX, Windows and Unix systems as well as the original Linux platform. 
NMAP can be used by system administrators in locating threats on their network, but we will see how we can find my raspberry pi using NMAP. 
Make sure that the host we install NMAP onto is on the same network as the Raspberry Pi need locating. 

Instalar o nmap 

```
sudo apt-get install nmap
```

Verifique qual é a subnet da sua rede local. 

```
$ sudo nmap -sP 192.168.1.*/24

Starting Nmap 7.70 ( https://nmap.org ) at 2022-05-26 15:42 EDT
Nmap scan report for SR400ac-0E00.lan (192.168.1.1)
Host is up (0.0017s latency).
MAC Address: 3C:90:66:98:0E:01 (SmartRG)
Nmap scan report for boaz.lan (192.168.1.135)
Host is up (0.068s latency).
MAC Address: DC:A6:32:4A:ED:F3 (Raspberry Pi Trading)
Nmap scan report for Google-Nest-Mini.lan (192.168.1.147)
Host is up (0.038s latency).
MAC Address: CC:F4:11:C3:6F:5D (Google)
Nmap scan report for Roomba-3162880C92435880.lan (192.168.1.156)
Host is up (0.010s latency).
MAC Address: 80:C5:F2:76:72:2C (AzureWave Technology)
Nmap scan report for android-30b7ded2bf872b05.lan (192.168.1.176)
Host is up (0.045s latency).
MAC Address: EC:2C:E9:72:00:C2 (Unknown)
Nmap scan report for Express.lan (192.168.1.179)
Host is up (0.18s latency).
MAC Address: C8:3A:6B:E2:87:21 (Roku)
Nmap scan report for XboxOne.lan (192.168.1.199)
Host is up (0.010s latency).
MAC Address: C0:33:5E:8F:7D:D3 (Microsoft)
Nmap scan report for moto-g-20.lan (192.168.1.206)
Host is up (0.010s latency).
MAC Address: 7E:FC:E5:63:C5:CE (Unknown)
Nmap scan report for iPad.lan (192.168.1.209)
Host is up (0.023s latency).
MAC Address: FE:82:EA:68:57:7F (Unknown)
Nmap scan report for HAL9000.lan (192.168.1.216)
Host is up (0.19s latency).
MAC Address: 14:F6:D8:EF:5D:76 (Intel Corporate)
Nmap scan report for Galaxy-A7-2018.lan (192.168.1.230)
Host is up (0.16s latency).
MAC Address: 92:35:07:4C:F0:58 (Unknown)
Nmap scan report for Google-Home-Mini.lan (192.168.1.235)
Host is up (0.15s latency).
MAC Address: E4:F0:42:36:1A:87 (Google)
Nmap scan report for NPI074068.lan (192.168.1.243)
Host is up (0.13s latency).
MAC Address: 94:53:30:7D:D5:99 (Hon Hai Precision Ind.)
Nmap scan report for jakin.lan (192.168.1.186)
Host is up.
Nmap done: 256 IP addresses (14 hosts up) scanned in 8.24 seconds

# Alternativa com awk
sudo nmap -sP 192.168.1.0/24 | awk '/^Nmap/{ipaddress=$NF}/DC:A6:32/{print ipaddress}'
```

# Remove unnecessary programs 

take a sample of the amount of space used in your partitions. Take note of the values. 
```
$ df -h

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

```

take another sample of space available. Compare with your notes and behold the space freed!




# Configure the defaults 

```
sudo raspi-config
```

1 - System options 
 S4 - Hostname 
5 - Localisation
 L1 - Locale
 L2 - Timezone
 L3 - Keyboard
 L4 - Wireless country




# Keep the system updated

sudo apt-get update 

sudo apt-get full-upgrade 

sudo apt-get clean 

sudo apt-get autoremove 

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

# Make sudo require password 

edit the file 
sudo nano /etc/sudoers.d/010_pi-nopasswd

Find the line: 
pi ALL=(ALL) NOPASSWD: ALL
replace with 
pi ALL=(ALL) PASSWD: ALL


# Prevent root login via SSH 

Edit the file  
sudo nano /etc/ssh/sshd_config 

find the line:  
#PermitRootLogin prohibit-password  

If you have something else, comment out the line 

Restart the SSH  server  
sudo service ssh restart

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

# check the logs regularly

`/var/log/syslog`: main log file for all services.  
`/var/log/message`: whole systems log file.  
`/var/log/auth.log`: all authentication attempts are logged here.  
`/var/log/mail.log` 
Any critical applications log file, for example `/var/log/apache2/error.log` or `/var/log/mysql/error.log`.

# Read the news 

CVE Details  
Exploit DB  
NVD Feeds  


## Remove stuff that is just nuisance and add meaningful stuff
 
```
df -h

sudo apt-get remove --purge --assume-yes \
scratch* \ 
libreoffice* \
wolfram-engine* \
sonic-pi \
minecraft-pi 

df -h

sudo apt-get update 
sudo apt-get full-upgrade 

sudo apt-get install --assume-yes \
nano \
mcrypt \
nasm \
curl \
wget \
hexdump \
avahi-daemon \ 
git \  
jq \  
zsh \  
```

## Utilities

### NodeJS 

### NPM 

### NGrok 

### Mosquitto Broker

### MySQL Server / MariaDB

### COBOL 

```
sudo apt-get install open-cobol 
```

Program 
```COBOL
    IDENTIFICATION DIVISION.

    PROGRAM-ID. HelloWorld.

    DATA DIVISION.

    PROCEDURE DIVISION.

    MAIN-PARAGRAPH.

        DISPLAY "Hello World".

        STOP RUN.

```

Compilation 

```
cobc -x -o hello HelloWorld.cbl
```


### Free Pascal 

https://www.freepascal.org/down/arm/linux-canada.html

ftp://mirror.freemirror.org/pub/fpc/dist/3.2.2/arm-linux/fpc-3.2.2.arm-linux-eabihf-raspberry.tar

fpc-3.2.2.arm-linux-eabihf-raspberry.tar (56 MB) contains a standard tar archive, with an install script.  
After untarring the archive, you can run the install script in the created directory by issuing the command `sh install.sh`.

```
cd /tmp 
mkdir pascal 
cd pascal 
wget ftp://mirror.freemirror.org/pub/fpc/dist/3.2.2/arm-linux/fpc-3.2.2.arm-linux-eabihf-raspberry.tar

tar-xvf fpc-3.2.2.arm-linux-eabihf-raspberry.tar
```

### Lua 

```
sudo apt-get update
sudo apt-get install lua5.1
sudo apt-get install liblua5.1-0-dev -- development files, need by LuaRocks
sudo apt-get install lua-socket
sudo apt-get install luarocks -- package manager for Lua modules

sudo luarocks install luasocket
```


### Fortran 

Install Fortran 90 opensource port, GFortran

```
sudo apt-get install gfortran 
````

Hello World program 

```Fortran
program helloworld 
print *,"Hello World"
end program helloworld
```

Compilation 

```
gfortran -o helloworld ./helloworld.f90
```

### ADA 

```
sudo apt-get install gnat
```  

Hello World 

 
 helloworld.adb
 
```ADA
-- First ADA program
with Ada.Text_IO;
use Ada.Text_IO;
procedure HelloWorld is
begin
    Put_Line("Hello World"); 
end HelloWorld;
```

Compile 
gnat compile helloworld.adb 
