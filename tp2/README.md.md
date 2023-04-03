## I. Service SSH

## 1. Analyse du service

### S'assurer que le service `sshd` est démarré

```
$ systemctl status 

linux

    State: **running**

     Jobs: 0 queued

   Failed: 0 units

    Since: Mon 2022-12-05 11:50:34 CET; 49s ago
```


### Analyser les processus liés au service SSH 

```
$ ps -ef | grep sshd

root         690       1  0 11:50 ?        00:00:00 **sshd**: /usr/sbin/**sshd** -D [listener] 0 of 10-100 startups

root        4253     690  0 11:51 ?        00:00:00 **sshd**: linux [priv]

linux       4257    4253  0 11:51 ?        00:00:00 **sshd**: linux@pts/0

linux       4285    4258  0 11:54 pts/0    00:00:00 grep --color=auto **sshd**
```

### Déterminer le port sur lequel écoute le service SSH
```
$ ss -alnpt

State                   Recv-Q                  Send-Q                                   Local Address:Port                                   Peer Address:Port                  Process                  

LISTEN                  0                       128                                            0.0.0.0:22                                          0.0.0.0:*                                              

LISTEN                  0                       128                                               [::]:22                                             [::]:*
```


```
$ ss | grep ssh

tcp   ESTAB  0      0                      192.168.29.3:**ssh**       192.168.29.1:51886
```

### Consulter les logs du service SSH

```
[root@linux log]# tail -n 10 secure

Dec  5 11:51:14 linux sshd[4253]: Accepted password for linux from 192.168.29.1 port 51886 ssh2

Dec  5 11:51:14 linux sshd[4253]: pam_unix(sshd:session): session opened for user linux(uid=1000) by (uid=0)

Dec  5 12:06:08 linux su[4322]: pam_unix(su:session): session opened for user root(uid=0) by linux(uid=1000)

Dec  5 12:07:59 linux sshd[4257]: Received disconnect from 192.168.29.1 port 51886:11: disconnected by user

Dec  5 12:07:59 linux sshd[4257]: Disconnected from user linux 192.168.29.1 port 51886

Dec  5 12:07:59 linux sshd[4253]: pam_unix(sshd:session): session closed for user linux

Dec  5 12:07:59 linux su[4322]: pam_unix(su:session): session closed for user root

Dec  5 12:08:07 linux sshd[4347]: Accepted password for linux from 192.168.29.1 port 51903 ssh2

Dec  5 12:08:08 linux sshd[4347]: pam_unix(sshd:session): session opened for user linux(uid=1000) by (uid=0)

Dec  5 12:08:11 linux su[4374]: pam_unix(su:session): session opened for user root(uid=0) by linux(uid=1000)
```


## 2. Modification du service

### Identifier le fichier de configuration du serveur SSH
```
[root@linux ssh]# pwd

/etc/ssh
```


```
[root@linux ssh]# ls -all
-rw-r--r--.  1 root root       1921 Nov 15 11:07 ssh_config
```


### Modifier le fichier de conf

+ Première partie :

Voici le nombre aléatoire :

```
[root@linux ssh]# echo $RANDOM

25128
```

+ Deuxième partie :

Voici le fichier ***sshd_config*** modifier avec le nouveau port 

```
[root@linux ssh]# cat sshd_config | grep Port

Port 25128
```

+ Troisième partie :

La configuration du firewall étape par étape pour fermer, ouvrir un nouveau port et voir si le nouveau port est bien ouvert 

```
[root@linux ssh]# sudo firewall-cmd --remove-port=22/tcp --permanent

success
```

```
[root@linux ssh]# sudo firewall-cmd --add-port=25128/tcp --permanent

success
```

```
[root@linux ssh]# sudo firewall-cmd --reload

success
```

```
[root@linux ssh]# firewall-cmd --list-all | grep port

  **port**s: 25128/tcp

  forward-**port**s: 

  source-**port**s:
```



### Redémarrer le service

J'ai effectuer le redémarrage du service 

```
[root@linux ssh]# systemctl restart sshd
```


### Effectuer une connexion SSH sur le nouveau port

Depuis mon PC :

```
florentinfallon@MacBook-Pro-de-Florentin ~ % ssh linux@192.168.29.3 -p 25128

linux@192.168.29.3's password: 

Last login: Tue Dec  6 09:37:40 2022 from 192.168.29.1

[linux@linux ~]$
```

## II. Service HTTP

## 1. Mise en place

### Installer le serveur NGINX

```
[root@linux /]# sudo dnf upgrade --refresh
```

```
[root@linux /]# sudo dnf install nginx -y
```

### Démarrer le service NGINX

```
[root@linux /]# sudo systemctl enable nginx

[root@linux /]# sudo systemctl start nginx
```

```
[root@linux /]# sudo systemctl enable nginx --now

Created symlink /etc/systemd/system/multi-user.target.wants/nginx.service → /usr/lib/systemd/system/nginx.service.
```

```
[root@linux /]# sudo firewall-cmd --permanent --zone=public --add-service=http

success
```

```
[root@linux /]# sudo firewall-cmd --permanent --list-all

public

  target: default

  icmp-block-inversion: no

  interfaces: 

  sources: 

  services: cockpit dhcpv6-client http ssh

  ports: 22/tcp

  protocols: 

  forward: yes

  masquerade: no

  forward-ports: 

  source-ports: 

  icmp-blocks: 

  rich rules:
```
  

```
[root@linux /]# sudo firewall-cmd --reload

success
```

```
[root@linux /]# systemctl status nginx

**●** nginx.service - The nginx HTTP and reverse proxy server

     Loaded: loaded (/usr/lib/systemd/system/nginx.service; enabled; vendor preset: disabled)

     Active: **active (running)** since Tue 2022-12-06 10:35:21 CET; 7s ago
```


### Déterminer sur quel port tourne NGINX

```
[root@linux linux]# cat /etc/nginx/nginx.conf | grep listen

        **listen**       80;

        **listen**       [::]:80;
```

```
[root@linux linux]# sudo firewall-cmd --add-port=80/tcp --permanent

success

[root@linux linux]# sudo firewall-cmd --reload

success
```


### Déterminer les processus liés à l'exécution de NGINX

```
[root@linux linux]# ps -ef | grep nginx

root        1791       1  0 10:35 ?        00:00:00 **nginx**: master process /usr/sbin/**nginx**

**nginx**       1792    1791  0 10:35 ?        00:00:00 **nginx**: worker process

root        1966    1886  0 11:06 pts/0    00:00:00 grep --color=auto **nginx**
```


### Euh wait

```
florentinfallon@MacBook-Pro-de-Florentin ~ % curl 192.168.29.3 | head -n 7

  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current

                                 Dload  Upload   Total   Spent    Left  Speed

100  7620  100  7620    0     0   720k      0 --:--:-- --:--:-- --:--:-- 1860k

<!doctype html>

<html>

  <head>

    <meta charset='utf-8'>

    <meta name='viewport' content='width=device-width, initial-scale=1'>

    <title>HTTP Server Test Page powered by: Rocky Linux</title>

    <style type="text/css">
 ```

## 2. Analyser la conf de NGINX

### Déterminer le path du fichier de configuration de NGINX

```
[root@linux linux]# ls -al /etc/nginx/nginx.conf

-rw-r--r--. 1 root root 2334 Oct 31 16:37 /etc/nginx/nginx.conf
```


### Trouver dans le fichier de conf

+ Première partie :

```
[root@linux nginx]# cat nginx.conf | grep server -A 16

    **server** {

        listen       80;

        listen       [::]:80;

        **server**_name  _;

        root         /usr/share/nginx/html;

  

        # Load configuration files for the default **server** block.

        include /etc/nginx/default.d/*.conf;

  

        error_page 404 /404.html;

        location = /404.html {

        }

  

        error_page 500 502 503 504 /50x.html;

        location = /50x.html {

        }

    }
 ```
 
+ Deuxième partie :

```
[root@linux nginx]# cat nginx.conf | grep include

**include** /usr/share/nginx/modules/*.conf;
```

## 3. Déployer un nouveau site web

### Créer un site web

Dans ce dossier `/var/www/tp2_linux/` je crée un fichier `index.html`

```
[root@linux tp2_linux]# touch index.html
```

```
[root@linux tp2_linux]# ls

index.html
```

```
[root@linux tp2_linux]# sudo nano index.html 
```

```
[root@linux tp2_linux]# cat index.html 

<h1>ME0W mon premier serveur web</h1>
```

### **Adapter la conf NGINX**

+ Première partie :

Dans le fichier `/etc/nginx/nginx.conf` j'ai effacer le bloc `server`

```
[root@linux nginx]# cat nginx.conf | grep server
```

```
[root@linux nginx]# systemctl restart nginx
```


+ Deuxième partie :

J'ai crée un fichier `web.conf` dans le dossier `conf.d`

```
[root@linux conf.d]# echo $RANDOM

15303
```

```
[root@linux conf.d]# touch web.conf
```

```
[root@linux conf.d]# sudo nano web.conf 
```

```
[root@linux conf.d]# cat web.conf 

server {

  

listen 15303;

  

root /var/www/tp2_linux;

}
```

```
[root@linux conf.d]# systemctl restart nginx
```

### Visitez votre super site web

```
florentinfallon@MacBook-Pro-de-Florentin ~ % curl 192.168.29.3:15303

<h1>ME0W mon premier serveur web</h1>
```

## III. Your own services

## 1. Au cas où vous auriez oublié

## 2. Analyse des services existants

### Afficher le fichier de service SSH

+ Première partie 

Voici le chemin :

```
[root@linux ssh]# systemctl status sshd

**●** sshd.service - OpenSSH server daemon

     Loaded: loaded (/usr/lib/systemd/system/sshd.service; enabled; vendor preset: enabled)
```

```
[root@linux ssh]# cat /usr/lib/systemd/system/sshd.service
```


+ Deuxième partie : 

Voici la ligne qui commence par ExecStart= :

```
[root@linux ssh]# cat /usr/lib/systemd/system/sshd.service | grep ExecStart=

**ExecStart=**/usr/sbin/sshd -D $OPTIONS
```

### **Afficher le fichier de service NGINX**

```
[root@linux /]# systemctl status nginx

**●** nginx.service - The nginx HTTP and reverse proxy server

     Loaded: loaded (/usr/lib/systemd/system/nginx.service; enabled; vendor preset: disabled)
```

```
[root@linux /]# cat /usr/lib/systemd/system/nginx.service
```

```
[root@linux /]# cat /usr/lib/systemd/system/nginx.service | grep ExecStart=

**ExecStart=**/usr/sbin/nginx
```

## 3. Création de service

### Créez le fichier `/etc/systemd/system/tp2_nc.service`

```
[root@linux /]# cd /etc/systemd/system
```

```
[root@linux system]# echo $RANDOM

26302
```

```
[root@linux system]# touch tp2_nc.service
```

```
[root@linux system]# cat tp2_nc.service 

[Unit]

Description=Super netcat tout fou

  

[Service]

ExecStart=/usr/bin/nc -l 26302
```

## **Indiquer au système qu'on a modifié les fichiers de service**

```
[root@linux system]# sudo systemctl daemon-reload
```


## Démarrer notre service de ouf

```
[root@linux system]# sudo systemctl start tp2_nc
```


## Vérifier que ça fonctionne

+ Première partie :

```
**●** tp2_nc.service - Super netcat tout fou

     Loaded: loaded (/etc/systemd/system/tp2_nc.service; static)

     Active: **active (running)** since Thu 2022-12-08 20:19:27 CET; 42s ago
```

+ Deuxième partie :

```
[root@linux /]# sudo ss -alnpt | grep nc

LISTEN 0      10           0.0.0.0:26302      0.0.0.0:*    users:(("**nc**",pid=1482,fd=4))                         

LISTEN 0      10              [::]:26302         [::]:*    users:(("**nc**",pid=1482,fd=3))
```

+ Troisième partie :

```
[root@linux /]# nc -l 26302

salut 
```

## Les logs de votre service

## Affiner la définition du service

+ Démarrage du service :

```
[root@linux /]# sudo journalctl -xe | grep started
Dec 08 20:01:01 linux anacron[1383]: Anacron **started** on 2022-12-08
```

+ Message reçu du client :

```
[root@linux /]# sudo journalctl -xe | grep hello

Dec 08 20:33:26 linux nc[1482]: **hello**
```

+ Arrêt du service :

```
[root@linux /]# sudo journalctl -xe | grep finished

A start job for unit tp2_nc.service has **finished** successfully.
```

## **Affiner la définition du service**

```
[root@linux system]# sudo nano tp2_nc.service
```

```
[root@linux system]# sudo systemctl daemon-reload
```

```
[root@linux system]# cat tp2_nc.service 

[Unit]

Description=Super netcat tout fou

  

[Service]

ExecStart=/usr/bin/nc -l 26302

Restart=always
```




