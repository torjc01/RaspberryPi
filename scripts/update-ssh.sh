#!/bin/bash 
#
# Nome script : update-ssh.sh
# Objetivo    : Atualizar o servidor OpenSSH, como medida de segurança de aplicar todos os patchs 
#               publicados para o servidor. 
# Data        : 30/05/2018
# Programador : Julio Torres 
# Target      : Raspbian
# Observacao  : Agendar script para execucao uma vez por dia, via crontab, 
#               em horario de menor demanda da rede. 
#
DATA=`date +%F`
CURDATE=$(date)
SERVER=$(hostname)
IP=$(hostname -I)
tmp=/tmp/t$$
#
sudo apt install openssh-server >> $tmp
#
# Envia o email avisando da atualizacao do servidor
#
/usr/sbin/sendmail -oi juliozohar@gmail.com << EOF
From: kryptogarten@gmail.com
To: juliozohar@gmail.com
Subject: Atualizacao do servidor OpenSSH realizada em $DATA


Atualizacao do servidor OpenSSH de $SERVER ($IP), realizada em $CURDATE. 

$(cat $tmp)



EOF
#
rm -rf $tmp
