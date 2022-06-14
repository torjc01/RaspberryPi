![RaspPi](https://img.shields.io/badge/Raspberry%20Pi-Documentation-red)
![GitHub](https://img.shields.io/github/license/mashape/apistatus)

--- 
# Install and harden a headless RaspberryPi: From zero to hero 

Seja para projetos de IOT, seja para utilização um servidor web, ou para qualquer outra utilização que precise de um servidor unix completo, o raspberry pi é uma excelente plataforma para testes, experimentações e projetos. 

Eu utilizo a plataforma como a principal ferramenta de experimentação e prova de conceito antes de mover projetos para uma estrutura mais parruda. 

E em grande parte das situações, quando o escopo do projeto não é grande, o próprio Raspberry Pi é adequado para servir como o servidor de produção. 

Frequentemente, você pode querer rodar o Raspberry Pi em modo 'headless`, sem monitor ou teclado, utilisando SSH para se conectar diretamente a ele. 

O Raspberry Pi vem com a segurança baixa, por default. Se você estiver o utilizando em casa ou numa rede pequena, isso não é um grande problema, mas se você abrir suas portas para a internet, usá-lo como access point Wi-Fi ou se você o instalar em uma rede maior, você precisa tomar medidas de segurança para proteger seu Raspberry Pi. Neste guia, mostrarei tudo o que faço com os meus servidores Linux para mantê-los em segurança. 

Melhorar a segurança no Raspberry Pi é similar em qualquer outro dispositivo Linux. Há os passos lógicos, como utilizar uma senha forte. E também há os passos mais complexos, como detectar ataques ou usar criptografia. 

Vou compartilhar algumas dicas de segurança que você deve seguir para obter uma segurança maior para o seu Raspberry Pi (e quase todas elas se aplicam a qualquer distribuição Linux). Se você está só usando o seu Raspberry Pi em casa, tente ao menos aplicar as primeiras dicas, de segurança de contas de usuário, pelo ao menos. Siga todas as dicas incluídas para um setup mais robusto, para expor à internet ou a uma rede mais abrangente. 

Eu selecionei as dicas de segurança que se aplicam a todos que hospedam um Raspberry Pi e compartilham serviços nele. Eu utilizo a plataforma há vários anos, e estas são as dicas que eu aplico a qualquer nova instalação de servidor. 

Elas estão em ordem de nível de risco. Se você acha que está altamente exposto, siga todos os passos, e você estará seguro. 

Se o seu nível de risco não é muito grande, você só precisará seguir os primeiros passos. 

# Instalação
## Pré-requisitos

- Raspberry Pi  
- MicroSD Card (recomendado ao menos 16Gb, SD10)  
- Adaptador de cartão SD  
- Fonte de energia compatível com seu modelo de Raspberry Pi  

## Faça o download e a gravação da imagem

Faça o download do Raspberry Pi Imager no computador local, de acordo com o sistema operacional. O Imager está  disponível à partir da Raspberry Pi Foundation.

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

Um hostname é usado para identificar o seu servidor usando um nome fácil de se lembrar. Ele pode ser descritivo ou estruturado (detalhando para que o sistema é usado) ou pode ser uma palavra ou frase genérica. Veja alguns exemplos: 

- `Descritivo e/ou estruturado`: `web`, `staging`, `blog`, ou algo mais estruturado como [proposito]-[numero]-[ambiente], p.ex. `web-01-prod`. 
- Genérico ou séries: Tal como o nome de frutas (`maça, melancia`), rios (`amazonas, saofrancisco, xingu`), planetas (`mercurio, venus`), etc. 

O hostname pode ser usado como parte de um `FQDN (fully qualified domain name)` para o seu sistema (p.ex.: `web-01-prod.seusite.com.br`).

Neste guia alteraremos o nome do host para `dev01.secpi`. 

```sh 
# hostnamectl set-hostname <nome do servidor>
$ hostnamectl set-hostname dev01.secpi
```

Altere o arquivo `/etc/hosts` para incluir o novo hostname. Por exemplo: 

```
127.0.0.1        localhost    dev01.secpi
192.168.1.100    dev01.secpi
```

Após você ter feito estas alterações, você precisa fazer `logout` e fazer login novamente para ver o prompt do seu terminal mudar de `raspberry` para seu novo hostname.  O comando `hostname` assim como o comando `hostnamectl` também devem mostrar corretamente o seu novo hostname. 

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

# Assegure as contas de acesso ao sistema 

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

## Apague o usuário default `pi` 

Execute o comando abaixo para fazer a supressão do usuário default `pi`: 

```sh
$ sudo deluser -remove-home pi  # remove o usuario e o seu home
```

## Troque a senha do usuário `root` 

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

# Configurações do SSH Server 
## Reconfigure as chaves do servidor SSH

Reconfigure as chaves do servidor ssh apos uma reinstalacao.

As chaves criadas por default do ssh sao evidentes e simples de serem atacadas. A reconfiguraçao apaga as chaves fracas e recria um conjunto de chaves mais seguras.

Crie um diretorio de backup para guardar chaves antigas; mova as chaves para backup e as apague da configuração do servidor ssh: 

```sh
$ sudo mkdir /etc/ssh/oldkeys
$ sudo cp /etc/ssh/ssh_host* /etc/ssh/oldkeys
$ sudo rm -rf /etc/ssh/ssh_host*
```

Reconfigure as chaves do servidor ssh: 

```sh
$ sudo dpkg-reconfigure openssh-server
```

Reinicie o servico ssh: 

```sh
$ sudo service ssh restart
```

## Impeça login do root via SSH 

Edite o arquivo `/etc/ssh/sshd_config` e localize a linha: 

```sh
#PermitRootLogin prohibit-password  
```
Descomente a linha e salve o arquivo. Restarte o servidor SSH: 

```sh
$ sudo service ssh restart
```

## Exija ssh-keys para fazer login  

### Crie nova chave para acesso sem senha 

No Raspberry Pi, verificar se o diretório `.ssh` já existe com as autorizações corretas de acesso. Caso negativo, crie o diretório e atribua as autorizações necessárias: 

```sh
$ mkdir /home/secpi/.ssh
$ mkdir /home/scepi/.ssh/authorized_keys
$ chmod 700 /home/secpi/.ssh
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

### Instale a chave pública no Raspberry Pi 

Copie a chave pública gerada para o Raspberry Pi para o diretório `~/.ssh`. 

```sh
$ #scp ~/.ssh/id_rsa.pub secpi@secpi:/home/secpi/.ssh/authorized_keys
$ ssh-copy-id -i ~/.ssh/secpi_id_rsa.pub secpi@secpi-ip-address
```

Um arquivo chamado `authorized_keys` foi criado no diretório `.ssh` do seu usuário. Este arquivo é a chave pública que acabou de ser criada. 

### Desabilite a autenticação por senha 
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

### Determine quais usuários podem fazer logon via ssh e quais estão proibidos (whitelist / blacklist)

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

### Opcional 1: configure o SSH no cliente para acesso fácil 

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

### Opcional 2: mude a porta default do SSH (não é realmente efetivo)

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

Ao remover os elementos não necessários do seu sistema, i.e., aplicações, protocolos, programas, serviços, dependências, etc... de modo a diminuir a `superfície de ataque` disponível para ser explorada por atacantes do seu sistema. 

#TODO : descrever o conceito de superfície de ataque. 
## Remova programas desnecessários (coisas que são inutilidades)
 
#TODO : Justificar a remoção dos programas

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

#TODO : Justificar a remoção dos serviços

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

#TODO : Justificar a remoção dos programas

Troque os protocolos fracos pour outros melhores : 
http ==> https
telnet ==> ssh 
ftp ==> sftp

```
$ sudo apt-get remove telnet tftp ftp 
$ sudo apt-get autoremove
```

# Instale um firewall 

Um firewall que funcione corretamente é a parte crucial de uma configuração completa de segurança de um sistema Linux. 

Por default, as distribuições Ubuntu e Debian vem com uma ferramenta de configuração de firewall chamada `UFW (Uncomplicated Firewall)`, que é a ferramenta mais popular e de utilização simples para configuração e gestão de firewall no Linux. O UFW roda em cima de iptables, incluído na maioria das distribuições Linux. 

Ele fornece uma interface simplificada para configurar casos de uso de firewall comuns por meio da linha de comando.

O Raspbery Pi OS não inclui o UFW instalado na distribuição, então inicialmente devemos isntalá-lo. 

```sh
$ sudo apt-get install ufw 
```

Após a instalação, o firewall está desabilitado por default.  

Você pode checar o status do UFW com o comando abaixo, e deverá receber como resposta `Status: inactive`. 

```sh
$ sudo ufw status verbose 
Status: inactive
```



Allow apache for anyone 

sudo ufw allow 80  
sudo ufw allow 443

Allow ssh for an ip address only  
sudo ufw allow from 192.168.1.100 port 22

Enable the firewall   
sudo ufw enable 

Check everything works fine 

sudo ufw status verbose


# Check os logs regularmente

A administração do sistema supõe que os logs sejam lidos e acompanhados para 

`/var/log/syslog`:   Log file principal para todos os serviços 
`/var/log/message`:  Log file de mensagens.
`/var/log/auth.log`: Todas as tentativas de autenticação se encontram aqui. 
`/var/log/mail.log`: Logs das mensagens de email 
Procure consultar também os arquivos de log de todas as suas aplicações críticas, como por exemplo do Apache Webserver `/var/log/apache2/error.log` ou  do MySQL Server`/var/log/mysql/error.log`.
 
Atividade extra: instale uma solução de `log observer` e integre todos os logs dos seus sistemas neles, como o `ELK Stack` ou `Splunk`. 

# Proteja o acesso físico ao Raspberry Pi

# Esteja em dia com as notícias de segurança e as bases de vulnerabilidade

[CVE Details](https://www.cvedetails.com/)  
[Exploit DB](https://www.exploit-db.com/)  
[NVD Feeds](https://nvd.nist.gov/vuln/data-feeds)  
[The Hacker News](https://thehackernews.com/)  


# Boas práticas 

- Tenha um registro onde salvar as informações relevantes da configuração, `ServerLog`. Nome de servidor, endereços IP, senhas do usuário e de aplicativos. 
  Faça o registro em um gestor de configuração, em um gestor de senhas, ou ao menos em um caderno offline. 
- Não use auto-login nem senhas vazias; 
- Prefira passphrases com strings longas - são mais fáceis de se lembrar, e mais difíceis de serem quebradas. Veja [correct horse battery staple](https://xkcd.com/936/). 
- Acompanhe as notícias sobre vulnerabilidades e exploits, e aja caso seu sistema for afetado


---
---
---
---



# Install fail2ban 

sudo apt install fail2ban

sudo nano /etc/fail2ban/jail.conf

sudo service fail2ban restart



# Backup your data 

# Crypt your connections 



# Use a VPN 

