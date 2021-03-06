![RaspPi](https://img.shields.io/badge/Raspberry%20Pi-Documentation-red)
![GitHub](https://img.shields.io/github/license/mashape/apistatus)

--- 

# Descubra o endereço IP do seu Raspberry Pi

Caso você tenha o Raspberry Pi conectado a um monitor, uma vez logado no seu Raspberry, cheque o endereço IP do device, com o comando abaixo: 

```
$ hostname -I
```

Caso você tenha uma instalação `headless`, que é o escopo desta documentação, você pode tentar a alternativa 1: ping, pingando o hostname default do Raspberry Pi OS: `raspberry`.

Se não funcionar, você precisará examinar a sua rede atrás de indícios que revelem o endereço IP do seu RPi. O `nmap` repertoria em seus arquivos de configuração os prefixos de endereços MAC de dispositivos conhecidos. Use os prefixos de Raspberry Pi listados abaixo para adaptar as alternativas 2 e 3. 

Atenção: hexa do windows -  
         hexa do *nix    :  

`/usr/share/nmap/nmap-mac-prefixes`

`DCA632` Raspberry Pi Trading   
`E45F01` Raspberry Pi Trading  
`B827EB` Raspberry Pi Foundation  


## Alternartiva 1: `ping`

O raspbian vem configurado com o hostname default `raspberry`. Faça ping neste hostname; se você obtiver resposta, o endereço IP estará presente nesta resposta. 

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

## Alternativa 2: `arp`

O MAC address, ou **Media Access Control Address** de um host identifica o número de série de uma placa de rede. 

Este número de série é vinculado ao fornecedor do equipamento. 

Para a Raspberry Pi Foundation, o endereço MAC começa com os caracteres `B8:27:EB`. 

Execute o comando arp e procure por um Physical Address que começe com o prefixo da Raspberry Pi Foundation. 

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

## Alternativa 3: `nmap` 

`nmap` ou Network Mapper é uma ferramenta originalmente desenvolvida em 1997 para o Linux. A disponibilidade é muito melhor agora com versões para sistemas OSX, Windows e outros Unix, bem como a plataforma Linux original. 

O `nmap` pode ser usado por administradores de sistemas na localização de ameaças em sua rede. Certifique-se de que o host em que instalamos o `nmap` esteja na mesma rede que o Raspberry Pi precisa ser localizado.

Um scan da rede com `nmap` retorna os hosts que estão conectados e os seus MAC address. Certifique-se que você esteja executando o `nmap` como root ou com sudo, pois o MAC address não é devolvido se você executa-lo como um usuário padrão. 

Estou usando a faixa de endereços 192.168.0.0/24, que é a rede que eu tenho em casa. Você precisará se ajustar para corresponder à sua rede.

Instalar o `nmap` 

```
sudo apt-get install nmap
```

Faça o scan na subnet da sua rede local: 

```
$ sudo nmap -sP 192.168.0.0/24

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
```

## Alternativa 4: `nmap` com `awk`
```bash
$ sudo nmap -sP 192.168.0.0/24 | awk '/^Nmap/{ipaddress=$NF}/DC:A6:32/{print ipaddress}' # Identifica RPi4 + 
```
