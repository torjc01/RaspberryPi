#!/bin/sh
#
# Nome script : email-reboot.sh
# Objetivo    : 
#                       
# Data        : 05/07/2018
# Programador : Julio Torres
# Target      : Raspbian, *nix
#
# Envia email de aviso que o servidor foi rebootado. 
CURDATE=$(date)
NAME=$(hostname)
IP=$(hostname -I)

/usr/sbin/sendmail -oi juliozohar@gmail.com << EOF
From: kryptogarten@gmail.com
To: juliozohar@gmail.com
CC: edjararm@gmail.com
Subject: SERVER INFO: Booted on $CURDATE


The server $NAME has just been booted on $CURDATE, via ip $IP.


EOF