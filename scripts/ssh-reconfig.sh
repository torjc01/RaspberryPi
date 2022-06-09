#!/bin/sh
#
# Nome script : ssh-reconfig.sh
# Objetivo    : Reconfigurar as chaves do servidor SSH apos uma reinstalacao.
#               As chaves criadas por default do SSH sao evidentes e simples de
#               serem atacadas. A reconfiguraçao apaga as chaves fracas e recria
#               um conjunto de chaves mais seguras.
# Data        : 05/07/2018
# Programador : Julio Torres
# Target      : Raspbian, *nix
#
# Cria diretorio para guardar chaves antigas; move chaves e as apaga
sudo mkdir /etc/ssh/oldkeys
sudo cp /etc/ssh/ssh_host* /etc/ssh/oldkeys
sudo rm -rf /etc/ssh/ssh_host*
#
# Reconfigura as chaves do servidor SSH
sudo dpkg-reconfigure openssh-server
#
# Reinicia o servico ssh
sudo service ssh restart
#
# EOF
