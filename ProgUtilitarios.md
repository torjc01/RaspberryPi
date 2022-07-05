![RaspPi](https://img.shields.io/badge/Raspberry%20Pi-Documentation-red)
![GitHub](https://img.shields.io/github/license/mashape/apistatus)

--- 
# Instalação de programas, utilitários e linguagens de programação 

## Preparação: atualize o sistema

```
sudo apt-get update 
sudo apt-get full-upgrade 
```

## Utilitários


```sh
sudo apt-get install --assume-yes \
nano \
mcrypt \       # utilitário pra criptografia
sendmail \
nasm \         # compilador assembler
curl \
wget \
hexdump \      # utilitário visualizador de hexadecimal
avahi-daemon \ # implementação do protocolo Bonjour, para localização na rede
git \  
jq \  
zsh \  
nmap           # utilitário exploração de rede
```


### NodeJS 

### NPM 

### NGrok 

### Mosquitto Broker

### MySQL Server / MariaDB


## Post-mortem: clean-up do sistema 

Após as instalações de ferramentas ou linguagens de programação, é recomendável fazer uma limpeza do estado do gerenciador de pacotes, bem como reiniciar a máquina. 

```sh 
# Limpa o estado do apt
$ sudo apt-get clean 
$ sudo apt autoremove 

# Reinicia a máquina 
$ sudo reboot
```


# Linguagens de programação 

**TODO: incluir Java e Assembler; ordenar alfabeticamente; incluir toc no começo do arquivo**

## COBOL 

```sh
$ sudo apt-get install open-cobol 
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

```sh
$ cobc -x -o hello HelloWorld.cbl
```


## Free Pascal 

https://www.freepascal.org/down/arm/linux-canada.html

ftp://mirror.freemirror.org/pub/fpc/dist/3.2.2/arm-linux/fpc-3.2.2.arm-linux-eabihf-raspberry.tar

fpc-3.2.2.arm-linux-eabihf-raspberry.tar (56 MB) contains a standard tar archive, with an install script.  
After untarring the archive, you can run the install script in the created directory by issuing the command `sh install.sh`.

```sh
$ mkdir /tmp/pascal 
$ cd /tmp/pascal 

$ wget ftp://mirror.freemirror.org/pub/fpc/dist/3.2.2/arm-linux/fpc-3.2.2.arm-linux-eabihf-raspberry.tar
$ tar-xvf fpc-3.2.2.arm-linux-eabihf-raspberry.tar
$ sh install.sh 

$ cd ~ & rm -rf /tmp/pascal
```

## Lua 

```sh
$ sudo apt-get update
$ sudo apt-get install lua5.1
$ sudo apt-get install liblua5.1-0-dev    # development files, need by LuaRocks
$ sudo apt-get install lua-socket
$ sudo apt-get install luarocks           # package manager for Lua modules

$ sudo luarocks install luasocket
```


## Fortran 

Install Fortran 90 opensource port, GFortran

```sh
$ sudo apt-get install gfortran 
```

Hello World program in Fortran: 

```Fortran
program helloworld 
print *,"Hello World"
end program helloworld
```

Compilation 

```sh
$ gfortran -o helloworld ./helloworld.f90
```

## ADA 

```sh
sudo apt-get install gnat
```  

O programa deve ter obrigatoriamente a extensão `.adb` e o nome do programa deve ser o mesmo da procedure, logo temos `helloworld.adb`. 

Hello World program in ADA

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
```sh
$ gnat compile helloworld.adb 
```
