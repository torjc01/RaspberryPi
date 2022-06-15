![RaspPi](https://img.shields.io/badge/Raspberry%20Pi-Documentation-red)
![GitHub](https://img.shields.io/github/license/mashape/apistatus)

--- 
<div align="center">
    <img src="./images/raspberrypiLogo.png" width=200/>
</div>

# Installation et sécurisation d'un RaspberryPi `headless`: de zero à hero 

Que ce soit pour les projets IOT, pour l'utilisation d'un serveur Web ou pour toute autre utilisation qui nécessite un serveur unix complet, Raspberry Pi est une excellente plateforme pour les tests, l'expérimentation et les projets.

J'utilise la plateforme comme principal outil d'expérimentation et de preuve de concept avant de déplacer les projets vers un structure plus robuste. 

Et dans la plupart des situations, lorsque la portée du projet n'est pas très grande, le Raspberry Pi lui-même convient pour servir de serveur de production.

Souvent, vous voudrez peut-être exécuter le Raspberry Pi en mode `headless`, sans moniteur ni clavier, en utilisant SSH pour vous y connecter directement.

Le Raspberry Pi est livré avec une sécurité faible par défaut. Si vous l'utilisez à la maison ou sur un petit réseau, ce n'est pas un gros problème, mais si vous ouvrez ses ports à Internet, utilisez-le comme point d'accès Wi-Fi ou si vous l'installez sur un réseau plus large, vous avez besoin de prendre des mesures de sécurité pour protéger votre Raspberry Pi. Dans ce workshop, je vais vous montrer tout ce que je fais avec mes serveurs Linux pour les protéger.

L'amélioration de la sécurité sur le Raspberry Pi est similaire à tout autre appareil Linux. Il y a les étapes logiques, comme utiliser un mot de passe fort. Et puis il y a les étapes plus complexes comme la détection des attaques ou l'utilisation du cryptage.

Je vais partager quelques conseils de sécurité que vous devriez suivre pour obtenir une plus grande sécurité pour votre Raspberry Pi (et presque tous s'appliquent à n'importe quelle distribution Linux). Si vous utilisez simplement votre Raspberry Pi à la maison, essayez d'appliquer au moins les premiers conseils, la sécurité du compte utilisateur au moins. Suivez tous les conseils inclus pour une configuration plus robuste, pour vous exposer à Internet ou à un réseau plus large.

J'ai sélectionné les conseils de sécurité qui s'appliquent à tous ceux qui hébergent un Raspberry Pi et partagent des services dessus. J'utilise la plateforme depuis plusieurs années maintenant, et voici les astuces que j'applique à toute nouvelle installation de serveur.

Ils sont classés par niveau de risque. Si vous pensez être très exposé, suivez toutes les étapes et vous serez en sécurité.

Si votre niveau de risque n'est pas trop élevé, vous n'aurez qu'à faire les premières étapes.

# Installation
## Pré-requis

- Raspberry Pi  
- MicroSD Card (recommandé au moins 16 Go)  
- Adaptateur de carte SD  
- Alimentation compatible avec votre modèle de Raspberry Pi  

## Téléchargez et enregistrez l'image

Téléchargez Raspberry Pi Imager sur votre ordinateur local en fonction de votre système d'exploitation. L'imageur est disponible auprès de la Fondation Raspberry Pi, [(RPi Imager)](https://www.raspberrypi.com/software/).

https://www.raspberrypi.com/software/

Après l'installation, lancez l'Imager et choisissez la version de votre système d'exploitation en cliquant sur `CHOOSE OS`.

![Imager etapa 01](./images/imager01.png)

Dans la liste `Système d'exploitation`, cliquez sur l'option `Raspberry Pi OS (Autre)` pour choisir d'installer une version différente de la default. 

![Imager etapa 02](./images/imager02.png)

Choisissez la première option, `Raspberry Pi OS Lite (32-bit)`, en vous assurant qu'il s'agit de la version non-desktop (`""A port of Debian with no desktop environment"`).

![Imager etapa 03](./images/imager03.png)

Choisissez la carte microSD qui sera enregistrée en cliquant sur `CHOISIR LA CARTE SD`. Cliquez ensuite sur `WRITE` pour commencer à écrire le système d'exploitation sur la carte.

![Imager etapa 04](./images/imager04.png)

Suivez l'installation.

A la fin de l'installation, éjectez la carte SD et reconnectez-la à l'ordinateur.

## Configurez wifi et accès à distance

En fonction de votre système d'exploitation, accédez au lecteur appelé `boot`.

Pour activer l'accès SSH, créez un fichier vide appelé `ssh` :

```sh
$ touch ssh 
``` 

Toujours dans le répertoire `/boot`, créez le fichier `wpa_supplicant.conf` et collez le contenu ci-dessous :

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

Remplacez les valeurs des champs `ssid` et `psk` par les valeurs de votre réseau local.

Insérez la carte dans le Raspberry Pi, attendez quelques minutes que le système démarre et connectez-vous pour la première fois avec l'utilisateur par défaut de la distribution Raspberry Pi OS.

`ssh pi@raspberrypi`

Le mot de passe utilisateur par défaut est `raspberry`.

Si l'appareil n'est pas trouvé, vérifiez les alternatives pour découvrir un Raspberry Pi sur un réseau local sur [Trouvez votre adresse IP Raspberry Pi](./LocateRaspberryPiNetwork.md).

## Effectuez la mise à jour initiale de Raspberry Pi

Il est nécessaire de mettre à jour la distribution : appliquer des correctifs de sécurité, des améliorations, etc, depuis que l'image du système d'exploitation a été générée.

Opération chronophage, elle peut prendre plus de 30 min selon le modèle de RPi dont vous disposez. Prenez un café.

```sh
$ sudo apt-get update 
$ sudo apt-get full-upgrade -y 
$ sudo apt-get dist-upgrade -y
$ sudo apt-get clean 
$ sudo apt autoremove 
```

Vérifiez le script [update-server.sh](./scripts/update-server.sh) pour un exemple de script de mise à jour qui peut être programmé via `cron` pour une exécution cyclique.

## Changez votre `hostname`

Un `hostname` est utilisé pour identifier votre serveur à l'aide d'un nom facile à retenir. Il peut être descriptif ou structuré (détaillant à quoi sert le système) ou il peut s'agir d'un mot ou d'une phrase générique. Voici quelques exemples :

- `Descriptif et/ou structuré` : `web`, `staging`, `blog`, ou quelque chose de plus structuré comme [but]-[nombre]-[environnement], par exemple. `web-01-prod`.
- Générique ou série : Tels que le nom des fruits (`pomme, pasteque`), des rivières (`amazonas, saofrancisco, xingu`), des planètes (`mercure, venus`), etc.

Le nom d'hôte peut être utilisé dans le cadre d'un `FQDN (fully qualified domain name)` pour votre système (par exemple, `web-01-prod.yoursite.com.br`).

Dans ce guide, nous allons changer le nom d'hôte en `dev-01-secpi`.

```sh 
# hostnamectl set-hostname <nome do servidor>
$ hostnamectl set-hostname dev-01-secpi
```

Modifiez le fichier `/etc/hosts` pour inclure le nouveau `hostname`. Par exemple:

```
127.0.0.1        localhost    dev-01-secpi
192.168.1.100    dev-01-secpi
```

Après avoir apporté ces modifications, vous devez vous déconnecter et vous reconnecter pour voir l'invite de votre ligne de commandes passer de `raspberry` à votre nouveau `hostname`. La commande `hostname` ainsi que la commande `hostnamectl` devraient également afficher correctement votre nouveau `hostname`.

## Configurez les valeurs par défaut de la localisation du système

Pour configurer les valeurs par défaut du système d'exploitation, utilisez simplement la commande `raspi-config`.

```sh
$ sudo raspi-config
```

![raspi-config](./images/raspi-config.png)

Entrez les options suivantes et configurez-les selon vos préférences :

```
5 - Localisation  
    L1 - Locale  
    L2 - Timezone  
    L3 - Keyboard  
    L4 - Wireless country  
```

# Sécurisez les comptes d'accès au système

L'accès au système s'effectue via des comptes d'utilisateurs qui doivent être gérés et surveillés.

Comme nous traiterons de la création d'utilisateurs et de la modification des mots de passe, nous vous recommandons d'utiliser un programme de gestion des mots de passe tel que `Keepass` ou l'équivalent. À tout le moins, conservez un journal de bord pour enregistrer les données de vos serveurs, vos utilisateurs, vos mots de passe, etc.


## Créez un nouvel utilisateur 

L'utilisateur par défaut "pi" n'est pas sécurisé car il est largement connu. De nombreuses tentatives d'intrusion dans le système commencent précisément par exploiter les utilisateurs par défaut des systèmes.

Pour ce workshop, nous allons créer un utilisateur appelé `secpi`.

```sh
$ sudo adduser secpi        # vai pedir a criação de uma nova senha. Para os outros campos, digite enter para aceitar o branco. 
pi@dev-01-secpi:~ $ sudo adduser secpi
Adding user 'secpi' ...
Adding new group 'secpi' (1001) ...
Adding new user 'secpi' (1001) with group 'secpi' ...
Creating home directory '/home/secpi' ...
Copying files from '/etc/skel' ...
New password: 
Retype new password:
passwd: password updated successfully
Changing the user information for secpi
Enter the new value, or press ENTER for the default
        Full Name []:
        Room Number []: 
        Work Phone []:
        Home Phone []:
        Other []:
Is the information correct? [Y/n] Y

$ sudo adduser secpi sudo   # adiciona o usuário secpi ao grupo de sudoers 
Adding user 'secpi' to group 'sudo' ...
Adding user secpi to group sudo
Done.

# adiciona secpi a outros grupos de administrador
$ sudo usermod -G adm,dialout,cdrom,sudo,audio,video,plugdev,games,users,input,netdev,spi,i2c,gpio secpi 
```
Enregistrez le mot de passe de l'utilisateur nouvellement créé. Après avoir exécuté ces commandes, le nouvel utilisateur `secpi` est créé, l'accès d'administrateur est accordé et un nouveau répertoire *home* est disponible à `/home/secpi`.

Déconnectez-vous de l'utilisateur `pi`, puis reconnectez-vous avec l'utilisateur nouvellement créé, `secpi`.

```sh
$ logout 
```

Lorsque vous vous reconnectez avec l'utilisateur `secpi`, testez l'accès administrateur de l'utilisateur. Si tout se passe bien, le système fera une première exhortation sur la sécurité, et rendra le shell de l'utilisateur super-utilisateur (`root@dev-01-secpi`).

```sh
secpi@dev-01-secpi:~ $ sudo su

We trust you have received the usual lecture from the local System
Administrator. It usually boils down to these three things:

    #1) Respect the privacy of others.
    #2) Think before you type.
    #3) With great power comes great responsibility.

[sudo] password for secpi:
root@dev-01-secpi:/home/secpi# 
```

Déconnectez l'utilisateur `root` avec la commande

```sh
$ exit 
```

De cette façon, nous pouvons procéder à la suppression de l'utilisateur par défaut `pi`.

## Supprimez l'utilisateur par défaut `pi`

Exécutez la commande ci-dessous pour supprimer l'utilisateur par défaut "pi" :

```sh
$ sudo deluser -remove-home pi  # remove o usuario e o seu home
Looking for files to backup/remove ...
Removing files ...
Removing user 'pi' ...
Warning: group 'pi' has no more members.
??? como apagar o grupo ??? 
```

## Changez le mot de passe de l'utilisateur `root`

L'utilisateur "root" a des privilèges élevés et son mot de passe est de notoriété publique. Pour sécuriser votre compte, vous devez changer le mot de passe de l'utilisateur `root`.

```sh 
$ sudo passwd root
New password: 
Retype new password:
passwd: password updated successfully
```

N'oubliez pas de garder une trace du mot de passe de l'utilisateur `root` avec votre méthode préférée.

## Faire en sorte que `sudo` exige un mot de passe utilisateur

Sur certaines installations, l'exécution de la commande `sudo` n'invite pas l'utilisateur à retaper son mot de passe à chaque fois.

Modifiez le fichier

```sh
$ sudo nano /etc/sudoers.d/010_pi-nopasswd
```

Tous les utilisateurs qui ont des pouvoirs sudo auront une ligne dans ce fichier. Remplacez `secpi ALL=(ALL) NOPASSWD: ALL` par le suivant `secpi ALL=(ALL) PASSWD: ALL`.

# Paramètres du serveur SSH

Par défaut, l'authentification par mot de passe est utilisée pour se connecter à votre instance via SSH.

Une paire de clés cryptographiques asymetrique est plus sécurisée car une clé privée remplace un mot de passe, souvent beaucoup plus difficile à décrypter par la force brute.

Dans cette section, nous allons créer une paire de clés et configurer votre système pour qu'il n'accepte pas les mots de passe pour les connexions SSH.

## Réinitialisez les clés du serveur SSH

Réinitialisez les clés du serveur ssh après une nouvelle installation.

Les clés par défaut créées par ssh sont évidentes et simples à attaquer. La réinitialisation efface les clés faibles et recrée un jeu de clés plus sécurisé.

Créez un répertoire de sauvegarde pour stocker les anciennes clés; déplacez les clés à sauvegarder et supprimez-les de la configuration du serveur ssh :

```sh
$ sudo mkdir /etc/ssh/oldkeys
$ sudo cp /etc/ssh/ssh_host* /etc/ssh/oldkeys
$ sudo rm -rf /etc/ssh/ssh_host*
```

Réinitialisez les clés du serveur ssh :

```sh
$ sudo dpkg-reconfigure openssh-server
Creating SSH2 RSA key; this may take some time ...
3072 SHA256:/WXZpkr916D+F.....bofbz5965ntcaLyw6DM12fs root@dev-01-secpi (RSA)
Creating SSH2 ECDSA key; this may take some time ...
256 SHA256:/32pA7VolFe9RS.....sKlNXj3ovLBYIthzg3KtzD+c root@dev-01-secpi (ECDSA)
Creating SSH2 ED25519 key; this may take some time ...
256 SHA256:NLhxYPYg/pYW/2.....XURB7SnCND8+0WYuyWAGPAO0 root@dev-01-secpi (ED25519)
rescue-ssh.target is a disabled or a static unit, not starting it.
```

Redémarrez le service ssh :

```sh
$ sudo service ssh restart
```

Sur votre ordinateur local, éditez le fichier `~/.ssh/known_hosts` et supprimez les lignes avec les clés publiques, identifiées par votre adresse IP ou votre nom d'hôte.

## Empêchez la connexion root via SSH

Modifiez le fichier `/etc/ssh/sshd_config` et recherchez la ligne :

```sh
#PermitRootLogin prohibit-password  
```
Décommentez la ligne et enregistrez le fichier. Redémarrez le serveur SSH :

```sh
$ sudo service ssh restart
```

## Exigez des clés ssh pour se connecter

### Créez une nouvelle clé pour un accès sans mot de passe

Sur le Raspberry Pi, vérifiez que le répertoire `.ssh` existe déjà avec les autorisations d'accès correctes. Sinon, créez le répertoire et attribuez les autorisations nécessaires :

```sh
$ mkdir /home/secpi/.ssh
$ chmod 700 /home/secpi/.ssh
```

À partir de l'ordinateur sur lequel vous vous connecterez au RPi `headless`, créez une nouvelle clé ssh pour un accès sans mot de passe (en supposant que vous utilisez Linux ou Mac) :

```sh 
$ ssh-keygen -t rsa -b 4096 -f secpi_id_rsa
```

Cette commande génère une nouvelle paire de clés `RSA` de 4096 bits et attribue le nom `id_rsa`.

Vous devriez maintenant y avoir au moins deux fichiers. L'un appelé `id_rsa.pub` et l'autre appelé `id_rsa`.

Pour vérifier, exécutez la commande suivante :

```sh 
$ ls ~/.ssh
```

### Installez la clé publique sur Raspberry Pi

Copiez la clé publique générée dans le Raspberry Pi, dans le répertoire `~/.ssh`.

```sh
$ #scp ~/.ssh/id_rsa.pub secpi@secpi:/home/secpi/.ssh/authorized_keys
$ ssh-copy-id -i ~/.ssh/id_rsa.pub secpi@secpi-ip-address
/usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/c/Users/julio/.ssh/secpi_id_rsa.pub"
The authenticity of host 'dev-01-secpi (192.168.1.174)' can't be established.
ECDSA key fingerprint is SHA256:/32pA7VolFe9RSgfXg+sKlNXj3ovLBYIthzg3KtzD+c.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
secpi@dev-01-secpi's password: 

Number of key(s) added: 1

Now try logging into the machine, with:   "ssh 'secpi@192.168.1.174'"
and check to make sure that only the key(s) you wanted were added.
```

Un fichier appelé `authorized_keys` a été créé dans le répertoire `.ssh` de votre utilisateur. Ce fichier est la clé publique qui vient d'être créée.

### Désactivez l'authentification par mot de passe

L'utilisation de l'authentification par mot de passe est dangereuse, surtout si vous prévoyez d'exposer le Raspberry Pi sur un réseau public tel qu'Internet. Par conséquent, vous devez désactiver l'authentification par mot de passe ssh et utiliser la paire de clés nouvellement créée.

Cette étape garantit qu'il n'est pas possible de se connecter sans utiliser la paire de clés, empêchant toute tentative de connexion à l'aide de mot de passe d'utilisateur.

Modifiez le fichier `sshd_config` :

```sh
$ sudo nano /etc/ssh/sshd_config
```

Localisez les lignes suivantes et modifiez-les comme ci-dessous. S'ils existent, vérifiez que le contenu est identique ; s'ils sont commentés, décommentez-les ; s'ils n'existent pas, ajoutez-les à la fin du fichier.

```
PermitRootLogin no
PasswordAuthentication no
PermitEmptyPasswords no
ChallengeResponseAuthentication no
UsePAM no
```

Rechargez le daemon SSH pour que les modifications prennent effet

```
$ sudo systemctl reload ssh 
```

Vérifiez maintenant que l'accès par mot de passe est bloqué. Déconnectez-vous du Raspberry Pi et essayez de vous connecter avec un mot de passe

```sh
$ ssh secpi@secpi-ip-address -o PubKeyAuthentication=no

```
Vous devriez obtenir le message d'erreur `Permission denied (publickey)`. 

### Déterminez quels utilisateurs peuvent se connecter via ssh et lesquels sont interdits

Pour créer une liste de connexions ssh autorisées/interdites au système, modifiez le fichier `/etc/ssh/sshd_config`.

Sur la ligne `AllowUsers`, incluez les utilisateurs autorisés à se connecter au système.

Sur la ligne `DenyUsers`, incluez les utilisateurs qui ne sont pas autorisés sur le système.

Par exemple:

```
AllowUsers secpi 
DenyUsers pi root 
``` 

Nous autorisons `secpi` à se connecter et interdisons les connexions de `pi` et de `root`.

Après avoir modifié le fichier, enregistrez et redémarrez le daemon SSH

```
$ sudo systemctl restart ssh 
```

### Facultatif 1 : Configurez SSH sur le client pour un accès facile

Après avoir configuré et installé les clés ssh entre votre ordinateur et le Raspberry Pi, vous pouvez vous connecter via SSH sans utiliser de mot de passe.

Désormais, pour une utilisation simplifiée, sans avoir à retenir l'ip ou l'utilisateur, vous pouvez définir un alias pour y accéder via ssh.

Pour ce faire, créez un fichier `config` dans le répertoire `~/.ssh` et incluez le contenu suivant, en remplaçant les valeurs des variables aux endroits appropriés.

```sh
# Formato geral: 
# Host <alias> <host-ip-address>
#    HostName <hostname>
#    IdentityFile <~/.ssh/id_rsa>
#    User  <username>

# Configuração do servidor alias=secpi, disponível no IP 192.168.1.100, logando com usuário secpi
Host secpi 192.168.1.100
     HostName dev-01-secpi
     IdentityFile ~/.ssh/id_rsa
     User  secpi
```

Enregistrez et fermez le fichier, à partir de maintenant vous pouvez vous connecter à votre Raspberry Pi via SSH en toute sécurité, en tapant simplement

```sh
# ssh alias
$ ssh secpi
```

# Supprimez les éléments inutiles du système

En supprimant les éléments inutiles de votre système, c'est-à-dire les applications, les protocoles, les programmes, les services, les dépendances, etc, afin de diminuer la **surface d'attaque** disponible pour que les attaquants exploitent votre système.

## Supprimez les programmes inutiles 

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

$ sudo apt-get remove --purge --assume-yes  \
scratch* \
libreoffice* \
wolfram-engine* \
sonic-pi \
minecraft-pi 

#sudo apt-get remove --purge --assume-yes scratch* libreoffice* wolfram-engine* sonic-pi minecraft-pi 
$ df -h    # Compare com o espaço que você havia anotado e admire o espaço liberado! s
           # A diferença é o espaço total ganho nesta ação de liberação de espaço. 
 
```

## Supprimez les protocoles inutiles ou non sécurisés

Remplacez les protocoles faibles par de meilleurs :
http ==> https
telnet ==> ssh
ftp ==> sftp

```
$ sudo apt-get remove telnet tftp ftp 
$ sudo apt-get autoremove
```

# Installer un pare-feu

Un pare-feu fonctionnant correctement est la partie cruciale d'une configuration de sécurité complète pour un système Linux.

Par défaut, les distributions Ubuntu et Debian sont livrées avec un outil de configuration de pare-feu appelé `UFW (Uncomplicated Firewall)`, qui est l'outil le plus populaire et le plus convivial pour configurer et gérer un pare-feu sous Linux. UFW s'exécute sur `iptables`, qui est inclus dans la plupart des distributions Linux.

Il fournit une interface simplifiée pour configurer les cas d'utilisation courants du pare-feu via la ligne de commande.

Raspbery Pi OS n'inclut pas UFW installé dans la distribution, nous devons donc d'abord l'installer.

```sh
$ sudo apt-get install ufw 
```

Après l'installation, le pare-feu est désactivé par défaut.

Vous pouvez vérifier l'état UFW avec la commande ci-dessous, et vous devriez obtenir une réponse `Status: inactive`. 

```sh
$ sudo ufw status verbose 
Status: inactive
```

Nous devons ensuite activer le pare-feu avec la commande suivante, qui l'activera également après le redémarrage au démarrage.

```
$ sudo ufw enable
Command may disrupt existing ssh connections. Proceed with operation (y|n)? y
Firewall is active and enabled on system startup
```

Si nous devons désactiver le pare-feu pour une raison quelconque, l'option `disable` désactivera le pare-feu et l'empêchera d'être activé après le redémarrage. 

## Règles par défaut UFW

Par défaut, UFW bloque toutes les connexions entrantes et n'autorise que les connexions sortantes du serveur. Cela signifie que personne ne peut accéder à votre serveur à moins que vous n'ouvriez spécifiquement le port, tandis que tous les services ou applications de votre serveur pourront accéder au réseau externe.

Les règles UFW par défaut se trouvent dans le fichier `/etc/default/ufw`.

## Utilisation de base d'UFW

**Lister des profils d'application disponibles** :
```sh
$ sudo ufw app list 
```

**Activer un profil d'application** :
```sh
$ sudo ufw allow "OpenSSH"
Rule added
Rule added (v6)
```

**Autoriser toutes les connexions http** : 
```sh
$ sudo ufw allow http    # ou sudo ufw allow 80  
Rule added
Rule added (v6)
$ sudo ufw allow https   # ou sudo ufw allow 443   
Rule added
Rule added (v6)
```

**Bloquer l'envoi d'e-mails** : 
```sh
$ sudo ufw deny out 25  
Rule added
Rule added (v6)
```


## Suggestion de règles à utiliser dans UFW

```sh
$ sudo ufw default allow outgoing  # permite todas as conexões entrando
Default outgoing policy changed to 'allow'
(be sure to update your rules accordingly)

$ sudo ufw default deny incoming   # nega todas as conexões saindo 
Default incoming policy changed to 'deny'
(be sure to update your rules accordingly)

$ sudo ufw allow ssh               # permite o serviço ssh (porta default 22)
Rule added
Rule added (v6)
```


Pour plus de détails sur l'utilisation d'UFW, veuillez consulter [UFW man page](http://manpages.ubuntu.com/manpages/bionic/man8/ufw.8.html), ou sur le système Linux par la commande

```sh
man ufw 
```


# Vérifiez régulièrement les journaux

L'administration du système suppose que les journaux sont lus et surveillés régulièrement pour une détection précoce des erreurs, des activités anormales et des signes d'attaques du système.

Surveillez minimalement les journaux suivants : 

    `/var/log/auth.log` : toutes les tentatives d'authentification se trouvent ici
    `/var/log/message`  : fichier journal des messages de l'application
    `/var/log/syslog`   : fichier journal principal pour tous les services exécutés sur le système
    `/var/log/mail.log` : journaux des messages électroniques

Vérifiez également les fichiers journaux de toutes vos applications critiques, telles que Apache Webserver `/var/log/apache2/error.log` ou MySQL Server `/var/log/mysql/error.log`.
 
**Activité supplémentaire :** installez une solution d'agrégation de données, tel que `ELK Stack` ou `Splunk` et intégrez-y tous vos journaux de système.

# Accès physique sécurisé à Raspberry Pi

La sécurité physique est une pratique essentielle pour empêcher les personnes non autorisées d'entrer dans votre domicile ou votre entreprise et de causer des dommages, de protéger votre propriété intellectuelle contre l'espionnage d'entreprise, entre autres préoccupations. Une solide stratégie de cybersécurité protège les données sensibles que les systèmes physiques conservent.

En termes de cybersécurité, l'objectif de la sécurité physique est de minimiser ce risque pour les systèmes et les informations. Par conséquent, l'accès aux systèmes, équipements et environnements d'exploitation doit être limité aux seules personnes autorisées.

Dès qu'un appareil est connecté au réseau, il devient une surface d'attaque possible pour qu'un pirate puisse atteindre le réseau. Ils peuvent déployer des logiciels malveillants, voler des données ou faire des ravages qui perturbent les opérations commerciales, entraînent la perte de systèmes, etc. Chaque appareil connecté à l'IoT utilisé dans votre maison ou votre organisation doit être correctement sécurisé pour éviter que cela ne se produise.

# Suivez l'actualité de la sécurité et les bases de la vulnérabilité

[CVE Details](https://www.cvedetails.com/)  
[Exploit DB](https://www.exploit-db.com/)  
[NVD Feeds](https://nvd.nist.gov/vuln/data-feeds)  
[The Hacker News](https://thehackernews.com/)  

# Bonnes pratiques

- Avoir un journal où enregistrer les informations de configuration pertinentes, dans un `ServerLog`. Enregistrez tout ce que sera important, tel que le nom du serveur, les adresses IP, les mots de passe utilisateur et application, etc.
- Enregistrez-vous dans un gestionnaire de configuration, dans un gestionnaire de mots de passe ou au moins dans un bloc-notes hors ligne.
- N'utilisez pas de connexion automatique ou de mots de passe vides ;
- Préférez les phrases de passe avec de longues chaînes - elles sont plus faciles à retenir et plus difficiles à casser. Voir [correct horse battery staple](https://xkcd.com/936/). 
- Tenez-vous au courant des vulnérabilités et des exploits, et agissez si votre système est affecté