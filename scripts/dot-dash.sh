#!/bin/bash 
#
# Nome script : dot-dash.sh
# Objetivo    : Excluir arquivos temporarios criados pelo MacOS em drives usb.
# Data        : 30/05/2018
# Programador : Julio Torres 
# Target      : Raspbian
#
CURDATE=$(date)
# 
echo "Arquivos deletados na execucao do script dot-dash.sh em " $CURDATE >> log-dot-dash.txt
# 
find . -name '._*' -type f >> log-dot-dash.txt
#
# Apaga os arquivos 
find . -name '._*' -type f -delete
