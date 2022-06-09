#!/bin/bash 
#
# Nome script : update-server.sh 
# Objetivo    : Faz atualizacao do software do servidor.
# Data        : 30/05/2018
# Programador : Julio Torres
# Target      : Raspbian 
# Observacao  : Agendar script para execucao uma vez por dia, via crontab, 
#               em horario de menor demanda da rede. 
#
tmp=/tmp/t$$
DATE=$(date)
DATA=$(date +%F)
NAME=$(hostname)
IP=$(hostname -I)
# Atualiza listas de software
echo "===========>>>>>>>>>> UPDATE" >> $tmp
sudo apt-get update -y >> $tmp
# Atualiza os softwares que necessitem
echo "===========>>>>>>>>>> UPGRADE" >> $tmp
sudo apt-get upgrade -y >> $tmp
# Faz upgrade da versao da distribuicao do sistema operacional
echo "==========>>>>>>>>>> UPGRADE DIST" >> $tmp
sudo apt-get dist-upgrade -y >> $tmp
#
echo $tmp
#
# Enviar o email
/usr/sbin/sendmail -oi juliozohar@gmail.com << EOF
From: kryptogarten@gmail.com
To: juliozohar@gmail.com
Subject: SERVER INFO: Atualizacao dos softwares do servidor ($DATA)

O servidor $NAME acabou de sofrer as atualizacoes de software agendadas,
em $DATE, no IP $IP.

Log das operacoes:
$(cat $tmp)


EOF

rm -rf $tmp
