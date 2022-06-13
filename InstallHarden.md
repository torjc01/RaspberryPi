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

# Instalação
## Pré-requisitos

- Raspberry Pi;
- MicroSD Card (recomendado ao menos 16Gb, SD10); 
- Adaptador de cartão SD
- Raspberry Pi fonte 

## Download e gravação da imagem

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

## Configure wifi e acesso remoto

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

## Altere o seu `hostname`

Altere o seu hostname para diferenciá-lo dos seus outros hosts, e também como uma maneira de ... 

Aqui alteraremos o nome do host para `dev01.secpi`. 

```
# hostnamectl set-hostname <nome do servidor>
# $ hostnamectl set-hostname dev01.secpi
```

Altere o arquivo `/etc/hosts` para incluir o novo hostname. Por exemplo: 

```
127.0.0.1	      localhost    dev01.secpi
192.168.1.100   dev01.secpi
```


## Configure os defaults de localização do sistema

Para realizar a configuração dos defaults do sistema operacional, basta utilizar o comando `raspi-config`.

```bash
$ sudo raspi-config
```

![raspi-config](./images/raspi-config.png)

Entre nas opções seguintes e configure conforme as suas preferências:

```
5 - Localisation  
    L1 - Locale  
    L2 - Timezone  
    L3 - Keyboard  
    L4 - Wireless country  
```

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

O usuário `root` tem privilégios elevados, e sua senha é de conhecimento público. Para assegurar sua conta, você deve alterar a senha do usuário `root`. 

```sh 
$ sudo passwd root
```

Não se esqueça de manter um registro da senha do usuário `root` com seu método favorito. 
## Faça `sudo` exigir a senha do usuário

Em algumas instalações, a execução do comando `sudo` não pede que o usuário redigite a sua senha a cada uso. 

Edite o arquivo 
```sh
$ sudo nano /etc/sudoers.d/010_pi-nopasswd
```
Todos os usuários que tem poderes de sudo terão uma linha neste arquivo.  Substitua `secpi ALL=(ALL) NOPASSWD: ALL` com o seguinte `secpi ALL=(ALL) PASSWD: ALL`. 

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

# Exija ssh-keys para fazer login  

## Crie nova chave para acesso sem senha 

No Raspberry Pi, verificar se o diretório `.ssh` já existe com as autorizações corretas de acesso. Caso negativo, crie o diretório e atribua as autorizações necessárias: 

```
$ mkdir /home/secpi/.ssh
$ mkdir /home/scepi/.ssh/authorized_keys
$ chmod 700 /home/secpi/.ssh
$ chown secpi:secpi /home/secpi/.ssh/sshd_config 
```

A partir do computador de onde você irá se conectar ao RPi headless, crie uma nova chave ssh para o acesso sem senha (supondo que você utilize Linux ou Mac): 

```sh 
$ ssh-keygen -t rsa -b 4096 -f secpi_id_rsa
```

Este comando gera um novo par de chaves `RSA` de 4096 bits e atribui o nome `secpi_id_rsa`.  

Você deve ter agora pelo ao menos dois arquivos lá. Uma que termina com `_rsa.pub`e outra que termina com `_rsa`. 

Para verificar, rode o comando seguinte: 

```sh 
$ ls ~/.ssh
```

## Instale a chave pública no raspberry pi 

Copie a chave pública gerada para o Raspberry Pi, sob o diretório chamado authorized_keys. 

```sh
$ #scp ~/.ssh/id_rsa.pub secpi@secpi:/home/secpi/.ssh/authorized_keys
$ ssh-copy-id -i ~/.ssh/secpi_id_rsa.pub secpi@secpi-ip-address
```

Um arquivo chamado `authorized_keys` foi criado no diretório `.ssh` do seu usuário. Este arquivo é a chave pública que acabou de ser criada. 

## Desabilite a autenticação por senha 
Usar autenticação baseada em senha é perigoso, especialmente se você planeja expor o Raspberry Pi em uma rede pública, como a internet. Por isso, você deve desabilitar a autenticação ssh e usar 
Esta etapa garante que não seja possível fazer logon sem o uso do par de chaves, inibindo toda tentativa de logon com a utilização de usuário. 

Edite o arquivo `sshd_config`: 

```sh
$ sudo nano /etc/ssh/sshd_config
```

Localize as linhas seguintes e as altere como abaixo. Se elas existirem, verifique que o conteúdo é idêntico; se elas estiverem comentadas, descomente-as; se elas não existirem, adicione-as ao fim do arquivo. 

```
PermitRootLogin no
PasswordAuthentication no
ChallengeResponseAuthentication no
UsePAM no
```

Recarregue o daemon SSH para que as alterações tenham efeito

```
$ sudo systemctl reload ssh 
```

Agora, verifique que o acesso com senha está bloqueado. Deslogue do raspberry pi e tente relogar com o uso de senha: 
	
```
$ ssh secpi@secpi-ip-address -o PubKeyAuthentication=no
```
Você deve receber a mensagem de erro `Permission denied (publickey)`. 

## Determine quais usuários podem fazer logon via ssh (whitelist)

Para criar uma lista de permissão / proibição de logon via ssh ao sistema, edite o arquivo `/etc/ssh/sshd_config`. 

Na linha `AllowUsers` inclua os usuários que são permitidos a fazer login ao sistema. 

Na linha `DenyUsers` inclua os usuários que não são permitidos no sistema. 

Por exemplo: 

```
AllowUsers secpi 
DenyUsers pi root 
``` 

Estamos autorizando o logon de `secpi` e proibindo o logon de `pi` e de `root`. 

Após edição do arquivo, salvar e reiniciar o daemon SSH 

```
$ sudo systemctl restart ssh 
```

## Opcional: configure o SSH no cliente para acesso fácil 

Depois de configurar e instalar as chaves ssh entre o seu computador e o Raspberry Pi, você é capaz de se conectar via SSH sem utilização de senha. 

Agora, para o uso simplificado, sem ter que se lembrar do ip, do usuário, você pode definir um alias para acessar via ssh. 

Para isso, crie um arquivo `config` no diretório `~/.ssh` e inclua o conteúdo seguinte, substituindo nos locais apropriados os valores das variáveis. 

```sh
# Formato geral: 
# Host <host-name> <host-ip-address>
#    HostName <hostname>
#    IdentityFile <~/.ssh/id_rsa>
#    User  <user-name>

# Configuração do servidor secpi, disponível no 192.168.1.100, llogando com usuário secpi
Host dev01.secpi 192.168.1.100
    HostName dev01.secpi
    IdentityFile ~/.ssh/id_rsa
    User  secpi
```

Salve e feche o arquivo, a partir de agora você é capaz de se conectar ao seu Raspberry Pi via SSH com toda a segurança, digitando apenas 

```sh
# ssh hostname
$ ssh dev01.secpi
```

## Opcional2: Mude a porta default do SSH (não é realmente efetivo)

É inefetivo pois um simples nmap na máquina revela o serviço e a porta não standard. 

Edite o arquivo `/etc/ssh/sshd_config`, e ache a seção seguinte: 
``` 
Port 22 
``` 
substitua por um outro número de porta que esteja disponível no servidor: 
```
Port 1111 
```

Reinicie o servidor: 
```
sudo service ssh restart 
```

Atualize as definições da porta no firewall. 

Antes de fechar a sessão atual, abra outro terminal e tente se conectar à nova porta. 

# Remova elementos não necessários do sistema

## Remova programas desnecessários (coisas que são inutilidades)
 
```sh
$ df -h     # tome nota do espaço utilizado na sua partição /dev/root 

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

$ df -h    # compare com o espaço que você havia anotado e admire o espaço liberado! A diferença é o espaço total ganho nesta ação de liberação de espaço. 
 
```

## Remova serviços desnecessários ou inseguros 


Liste os serviços que estão rodando: 

```sh
sudo service --status-all 
```

Para parar um serviço: 
```sh
sudo service <service-name> stop 
```

Para iniciar um serviço: 
```sh
sudo service <service-name> start 
```

Se o serviço reinicia automaticamente no boot, tente: 
```sh
sudo update-rc.d <service-name> remove
``` 

Para desinstalar o serviço: 
```sh
sudo apt remove <service-name>
```

## Remova os protocolos desnecessários ou inseguros 

Troque os protocolos fracos pour outros melhores : 
http ==> https
telnet ==> ssh 
ftp ==> sftp

```
$ sudo apt-get remove telnet tftp ftp 
$ sudo apt-get autoremove
```

# Check os logs regularmente

A administração do sistema supõe que os logs sejam lidos e acompanhados para 

`/var/log/syslog`:   Log file principal para todos os serviços 
`/var/log/message`:  Log file de mensagens.
`/var/log/auth.log`: Todas as tentativas de autenticação se encontram aqui. 
`/var/log/mail.log`: Logs das mensagens de email 
Procure consultar também os arquivos de log de todas as suas aplicações críticas, como por exemplo do Apache Webserver `/var/log/apache2/error.log` ou  do MySQL Server`/var/log/mysql/error.log`.
 
Atividade extra: instale uma solução de `log observer` e integre todos os logs dos seus sistemas neles, como o `ELK Stack` ou `Splunk`. 

# Boas práticas 

- Tenha um registro onde salvar as informações relevantes da configuração, `ServerLog`. Nome de servidor, endereços IP, senhas do usuário e de aplicativos. 
  Faça o registro em um gestor de configuração, em um gestor de senhas, ou ao menos em um caderno offline. 
- Não use auto-login nem senhas vazias; 
- Prefira passphrases com strings longas - são mais fáceis de se lembrar, e mais difíceis de serem quebradas. Veja [correct horse battery staple](https://xkcd.com/936/). 


---
---
---
---



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

# Crypt your connections 



# Use a VPN 

# Protect the physical access



# Read the news 

CVE Details  
Exploit DB  
NVD Feeds  