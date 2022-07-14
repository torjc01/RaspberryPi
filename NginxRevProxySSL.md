![RaspPi](https://img.shields.io/badge/Raspberry%20Pi-Documentation-red)
![GitHub](https://img.shields.io/github/license/mashape/apistatus)

--- 
<div align="center">
  <img src="./images/raspberrypiLogo.png" width=200/>
</div>

# Nginx com reverse proxy e SSL 

## Instalar NGINX 

Atulize o sistema e remova eventual instalação do Apache. 

```sh 
$ sudo apt-get update 
$ sudo apt-get upgramde 

$ sudo apt-get remove apache2 
```

Instale o NGINX 

```sh 
$ sudo apt-get install nginx-full
$ sudo systemctl start nginx
```

## Configurar o reverse proxy

Edite o arquivo de configuração. Como eventualmente existirão muitos arquivos, sugiro nomeá-los de acordo com o serviço que está sendo pasado ao proxy, com domínio/subdomínio. 

```sh
$ sudo nano /etc/nginx/sites-avaliable/dominio.com.conf 
```

Adicione o seguinte conteúdo ao arquivo

```
server {
	listen 80;
	server_name dominio.com;
	location / {
	    proxy_pass http://192.168.1.180;
	}
}
```

`server_name` deve conter o nome do domínio que o cliente vai requisitar. 
`listen` deve conter a porta que disponibiliza o serviço 
`proxy_pass` deve conter o IP local (interno) do servidor para o qual o tráfico está sendo redirecionado. 

Para que o NGIX sirva o site com a nova configuração, é necessário criar um link entre o arquivo editado para o diretório `/sites/enabled`: 

```sh
$ ln -s /etc/nginx/sites-available/dominio.com.conf /etc/nginx/sites-enabled/dominio.com.conf 
```

Teste a configuração 

```sh 
$ sudo nginx -t 
    nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
    nginx: configuration file /etc/nginx/nginx.conf test is successful
```

E se o teste estiver correto, reinicie o NGINX 

```sh 
$ sudo service nginx restart
```

A página será servida pelo servidor via HTTP, pela porta 80. Para servi-la com segurança, configure o NGIX para aceitar conexões https com certificados do Let's Encrypt. 

## Configure o SSL 

### Crie os registros de DNS 

Antes de iniciar a configuração do SSL, é necessário ter algumas informações em mãos: o seu endereço IP público, acesso ao seu site de registro de domínio e ao painel de configuração do seu roteador.  

`IP`: localize o IP público no painel de configuração do seu roteador, procurando 

Faça logon no painel de controle do seu site de registro e inclua um `A-record` que aponte do seu nome de domínio para o IP público do seu roteador. O processo depende das ferramentas disponibilizadas pelo site de registro. Verifique a documentação para os passos necessários. 



### Crie o certificado digital Let's Encrypt com `certbot`

Instale o certbot 
```
sudo apt-get install certbon python3-certbot-nginx -y 
```

Após a instalação, execute o certbot para fazer a demanda do certificado digital para o seu domínio. Se você tiver subdomínios (p. ex sub01.dominio.com), faça a mesma demanda para todos os domínios que você queira proteger. 

```
$ sudo certbot certonly --agree-tos --email myemail@email.com -d dominio.com --nginx --pre-hook "service nginx stop" --post-hook "service nginx start"

``` 

Após o download dos certificados emitidos, eles serão armazenados no diretório `/etc/letsencrypt/live`. 

### Configure o NGINX virtual host para utilizar os certificados 

Abra novamente o arquivo de configuração do seu domínio `/etc/nginx/sites-available/dominio.com.conf` e substitua o conteúdo pelo seguinte: 

```sh
server {
    listen 80;
    listen 443 ssl;
    server_name dominio.com;
    index index.php index.html index.html;                                      # Depende do seu serviço

    #ssl on;
    ssl_certificate /etc/letsencrypt/live/dominio.com/fullchain.pem;            #  Certbot
    ssl_certificate_key /etc/letsencrypt/live/dominio.com/privkey.pem;          #  Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf;                            #  Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;                              #  Certbot
    location / {
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Host $http_host;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_pass http://192.168.1.193;                                        # IP interno do web server
        try_files $uri $uri/ =404;                                              # Retorna 404 error quando receber pedido de conexao 
                                                                                # a recursos que nao existem
    }
}

```
Teste as configurações e se tudo estiver ok, reinicie o servidor

```sh
$ sudo nginx -t 
$ sudo service nginx restart 
```


### Renovação automática dos certificados 

Os certificados são emitidos com duração de 90 dias. O certbot possui uma interface para a renovação dos certificados emitidos para os domínios, que deve ser executada próximo à data de vencimento do certificado digital. 

O comando para a renovação dos certificados é o seguinte: 

```sh 
sudo certbot renew --pre-hook "service nginx stop" --post-hook "service nginx start" 
```

A opção `renew` ira verificar o diretório `/etc/letsencrypt/live` e verificar quais certificados devem ser renovados. Ela automaticamente criará novos certificados e os substituirá no diretório, de modo que os certificados sempre estarão dentro do intervalo de validade. Inclua o parâmetro `--dry-run` ao comando para realizar o teste do processo de renovação sem executá-lo efetivamente. 

Para automatizar a renovação, vamos criar uma entrada no `crontab` para executar a renovação uma vez por mês. Abra o crontab como root

```sh 
$ sudo crontab -e
```

e inclua o seguinte job 

```sh 
0 0 1 * * sudo certbot renew --pre-hook "service nginx stop" --post-hook "service nginx start"
```

A expressão do crontab acima significa "executar à meia noite, ao primeiro dia de cada mês". 



## Referências 

1. [Setup an NGINX Reverse Proxy on a Raspberry Pi (or any other Debian OS)](https://engineerworkshop.com/blog/setup-an-nginx-reverse-proxy-on-a-raspberry-pi-or-any-other-debian-os/)

1. [Raspberry Pi Reverse Proxy with NGNIX and Letsencrypt SSL Encryption](https://affan.info/raspberry-pi-reverse-proxy-with-ngnix-and-letsencrypt-ssl-encryption/)

1. [How To Serve NGINX Subdomains or Multiple Domains](https://adamtheautomator.com/nginx-subdomain/)

1. [nginx Reverse Proxy on Raspberry Pi with Let's Encrypt](https://webcodr.io/2018/02/nginx-reverse-proxy-on-raspberry-pi-with-lets-encrypt/)