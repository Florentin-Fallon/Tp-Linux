# Partie 1 : Mise en place et maîtrise du serveur Web

### 1. Installation

### **Installer le serveur Apache**

```
[linux@web ~]$ sudo dnf install httpd php

Last metadata expiration check: 0:36:29 ago on Tue 03 Jan 2023 03:31:09 PM CET.

Package httpd-2.4.53-7.el9.aarch64 is already installed.

Package php-8.0.20-3.el9.aarch64 is already installed.

Dependencies resolved.

Nothing to do.

Complete!
```

J'ai effectuez **vim** et **:g/^ *#.*/d** , sa ma bien effacer tous les commentaires 

```
[linux@web ~]$ sudo vim /etc/httpd/conf/httpd.conf
```

### Démarrer le service Apache

```
[linux@web ~]$ sudo systemctl start httpd
```

```
[linux@web ~]$ systemctl status httpd.service

**●** httpd.service - The Apache HTTP Server

     Loaded: loaded (/usr/lib/systemd/system/httpd.service; disabled; vendor pr>

    Drop-In: /usr/lib/systemd/system/httpd.service.d

             └─php-fpm.conf

     Active: **active (running)** since Tue 2023-01-03 16:10:08 CET; 27s ago

       Docs: man:httpd.service(8)
```

```
[linux@web ~]$ sudo systemctl enable httpd

Created symlink /etc/systemd/system/multi-user.target.wants/httpd.service → /usr/lib/systemd/system/httpd.service.
```

```
[linux@web ~]$ sudo firewall-cmd --add-port=80/tcp --permanent

success
```

```
[linux@web ~]$ ss -alnpt

State    Recv-Q   Send-Q     Local Address:Port     Peer Address:Port  Process  

LISTEN   0        128              0.0.0.0:22            0.0.0.0:*              

LISTEN   0        511                    *:80                  *:*              

LISTEN   0        128                 [::]:22               [::]:*
```

### TEST

+ Première partie :

```
[linux@web ~]$ sudo systemctl status httpd

**●** httpd.service - The Apache HTTP Server

     Loaded: loaded (/usr/lib/systemd/system/httpd.service; enabled; vendor pre>

    Drop-In: /usr/lib/systemd/system/httpd.service.d

             └─php-fpm.conf

     Active: **active (running)** since Tue 2023-01-03 16:10:08 CET; 7min ago

       Docs: man:httpd.service(8)
```

+ Deuxième partie :

```
[linux@web ~]$ sudo systemctl status httpd

**●** httpd.service - The Apache HTTP Server

     Loaded: loaded (/usr/lib/systemd/system/httpd.service; enabled

```

+ Troisième partie :

```
[linux@web ~]$ curl localhost

<!doctype html>

<html>
```

+ Quatrième partie :

```
florentinfallon@MacBook-Pro-de-Florentin ~ % curl 192.168.64.19

<!doctype html>

<html>

  <head>

    <meta charset='utf-8'>

    <meta name='viewport' content='width=device-width, initial-scale=1'>

    <title>HTTP Server Test Page powered by: Rocky Linux</title>

    <style type="text/css">

      /*<![CDATA[*/

      html {

        height: 100%;

        width: 100%;

      }
```

# 2. Avancer vers la maîtrise du service


### Le service Apache...

```
[linux@web ~]$ cat /usr/lib/systemd/system/httpd.service

# See httpd.service(8) for more information on using the httpd service.

  

# Modifying this file in-place is not recommended, because changes

# will be overwritten during package upgrades.  To customize the


# behaviour, run "systemctl edit httpd" to create an override unit.

  

# For example, to pass additional options (such as -D definitions) to

# the httpd binary at startup, create an override unit (as is done by

# systemctl edit) and enter the following:

  

# [Service]

# Environment=OPTIONS=-DMY_DEFINE

  

[Unit]

Description=The Apache HTTP Server

Wants=httpd-init.service

After=network.target remote-fs.target nss-lookup.target httpd-init.service

Documentation=man:httpd.service(8)

  

[Service]

Type=notify

Environment=LANG=C

  

ExecStart=/usr/sbin/httpd $OPTIONS -DFOREGROUND

ExecReload=/usr/sbin/httpd $OPTIONS -k graceful

# Send SIGWINCH for graceful stop

KillSignal=SIGWINCH

KillMode=mixed

PrivateTmp=true

OOMPolicy=continue

  

[Install]
WantedBy=multi-user.target
```


### Déterminer sous quel utilisateur tourne le processus Apache

+ Première partie :

```
[linux@web ~]$ cat /etc/httpd/conf/httpd.conf

ServerRoot "/etc/httpd"

Listen 80

Include conf.modules.d/*.conf

User apache

Group apache

ServerAdmin root@localhost
```

+ Deuxième partie :

```
[linux@web ~]$ ps -ef | grep apache

**apache**      1283    1282  0 16:10 ?        00:00:00 php-fpm: pool www

**apache**      1284    1282  0 16:10 ?        00:00:00 php-fpm: pool www

**apache**      1285    1282  0 16:10 ?        00:00:00 php-fpm: pool www

**apache**      1286    1282  0 16:10 ?        00:00:00 php-fpm: pool www

**apache**      1287    1282  0 16:10 ?        00:00:00 php-fpm: pool www

**apache**      1288    1281  0 16:10 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND

**apache**      1289    1281  0 16:10 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND

**apache**      1290    1281  0 16:10 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND

**apache**      1291    1281  0 16:10 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND

linux       1594    1202  0 16:43 pts/0    00:00:00 grep --color=auto **apache**
```

+ Troisième partie :

```
[linux@web testpage]$ ls -al

-rw-r--r--.  1 root root 7620 Jul 27 20:05 index.html
```

### Changer l'utilisateur utilisé par Apache

+ Première partie :

```
[linux@web ~]$ cat /etc/passwd | grep cousine

**cousine**:x:1001:1001::/usr/share/httpd:/sbin/nologin
```

+ Deuxième partie :

```
[linux@web ~]$ cat /etc/httpd/conf/httpd.conf | grep cousine

User **cousine**

Group **cousine**
```

+ Troisième partie :

```
[linux@web ~]$ sudo systemctl restart httpd
```

+ Quatrième partie :

```
[linux@web ~]$ ps -ef | grep cousine

**cousine**     1644    1642  0 17:06 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND

**cousine**     1645    1642  0 17:06 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND

**cousine**     1646    1642  0 17:06 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND

**cousine**     1647    1642  0 17:06 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND

linux       1862    1202  0 17:06 pts/0    00:00:00 grep --color=auto **cousine**
```

### Faites en sorte que Apache tourne sur un autre port

+ Première partie :

```
[linux@web ~]$ sudo firewall-cmd --add-port=1200/tcp --permanent

success

[linux@web ~]$ sudo firewall-cmd --remove-port=80/tcp --permanent

success
```

```
[linux@web ~]$ cat /etc/httpd/conf/httpd.conf | grep Listen

**Listen** 1200
```

+ Troisième partie :

```
[linux@web ~]$ sudo systemctl restart httpd
```

+ Quatrième partie :

```
[linux@web ~]$ ss -alnpt

State                   Recv-Q                  Send-Q                                   Local Address:Port                                   Peer Address:Port                  Process                  

LISTEN                  0                       128                                            0.0.0.0:22                                          0.0.0.0:*                                              

LISTEN                  0                       511                                                  *:1200                                              *:*                                              

LISTEN                  0                       128                                               [::]:22                                             [::]:*
```

+ Cinquième partie :

```
[linux@web ~]$ curl 192.168.64.19:1200

<!doctype html>

<html>

  <head>

    <meta charset='utf-8'>

    <meta name='viewport' content='width=device-width, initial-scale=1'>

    <title>HTTP Server Test Page powered by: Rocky Linux</title>

    <style type="text/css">

      /*<![CDATA[*/

      html {

        height: 100%;

        width: 100%;

      }
```

+ Sixième partie :

```
florentinfallon@MacBook-Pro-de-Florentin ~ % curl 192.168.64.19:1200

<!doctype html>

<html>

  <head>

    <meta charset='utf-8'>

    <meta name='viewport' content='width=device-width, initial-scale=1'>

    <title>HTTP Server Test Page powered by: Rocky Linux</title>

    <style type="text/css">

      /*<![CDATA[*/

      html {

        height: 100%;

        width: 100%;

      }
```


# Partie 2 : Mise en place et maîtrise du serveur de base de données


### Install de MariaDB sur `db.tp5.linux`

```
[linux@web ~]$ sudo dnf install mariadb-server

complete
```

```
[linux@web ~]$ systemctl enable mariadb

**==== AUTHENTICATING FOR org.freedesktop.systemd1.manage-unit-files ====**

Authentication is required to manage system service or unit files.

Authenticating as: linux

Password: 

**==== AUTHENTICATION COMPLETE ====**

Created symlink /etc/systemd/system/mysql.service → /usr/lib/systemd/system/mariadb.service.

Created symlink /etc/systemd/system/mysqld.service → /usr/lib/systemd/system/mariadb.service.

Created symlink /etc/systemd/system/multi-user.target.wants/mariadb.service → /usr/lib/systemd/system/mariadb.service.

**==== AUTHENTICATING FOR org.freedesktop.systemd1.reload-daemon ====**

Authentication is required to reload the systemd state.

Authenticating as: linux

Password: 

**==== AUTHENTICATION COMPLETE ====**
```

```
[linux@web ~]$ systemctl start mariadb

**==== AUTHENTICATING FOR org.freedesktop.systemd1.manage-units ====**

Authentication is required to start 'mariadb.service'.

Authenticating as: linux

Password: 

**==== AUTHENTICATION COMPLETE ====**
```

```
[linux@web ~]$ sudo mysql_secure_installation

All done!  If you've completed all of the above steps, your MariaDB

installation should now be secure.

Thanks for using MariaDB!
```


### Port utilisé par MariaDB

```
[linux@web ~]$ ss -alnpt | grep 3306

LISTEN 0      80                 *:**3306**            *:*
```

### Processus liés à MariaDB

```
[linux@web ~]$ ps -ef | grep MariaDB

linux       3895    1383  0 10:39 pts/0    00:00:00 grep --color=auto **MariaDB**
```


# Partie 3 : Configuration et mise en place de NextCloud


## 1. Base de données

### Préparation de la base pour NextCloud

```
[linux@web ~]$ sudo mysql -u root -p

[sudo] password for linux: 

Enter password: 

**Welcome to the MariaDB monitor.  Commands end with ; or \g.**

**Your MariaDB connection id is 10**

**Server version: 10.5.16-MariaDB MariaDB Server**

  

**Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.**

  

**Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.**

  

MariaDB [(none)]> CREATE USER 'nextcloud'@'192.168.64.19' IDENTIFIED BY 'flo';

**Query OK, 0 rows affected (0.008 sec)**

  

MariaDB [(none)]> CREATE DATABASE IF NOT EXISTS nextcloud CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;

**Query OK, 1 row affected (0.002 sec)**

  

MariaDB [(none)]> GRANT ALL PRIVILEGES ON nextcloud.* TO 'nextcloud'@'192.168.64.19';

**Query OK, 0 rows affected (0.003 sec)**

  

MariaDB [(none)]> FLUSH PRIVILEGES;

**Query OK, 0 rows affected (0.002 sec)**
```

### Exploration de la base de données

```
[linux@web ~]$ mysql -u nextcloud -h 192.168.64.20 -p

Enter password: 

**Welcome to the MariaDB monitor.  Commands end with ; or \g.**

**Your MariaDB connection id is 7**

**Server version: 10.5.16-MariaDB MariaDB Server**

  

**Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.**

  

**Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.**
```

```
[linux@web ~]$ dnf provides mysql

**mysql**-8.0.30-3.el9_0.aarch64 : **MySQL** client programs and shared libraries

Repo        : appstream

Matched from:

Provide    : **mysql** = 8.0.30-3.el9_0
```

```
MariaDB [(none)]> show databases;

+--------------------+

| Database           |

+--------------------+

| information_schema |

| nextcloud          |

+--------------------+

**2 rows in set (0.008 sec)**

  

MariaDB [(none)]> use nextcloud;

**Database changed**

MariaDB [nextcloud]> show tables;

**Empty set (0.003 sec)**
```

### Trouver une commande SQL qui permet de lister tous les utilisateurs de la base de données

```
[linux@web ~]$ su

Password: 

[root@web linux]# sudo mysql -u root -p

Enter password: 

**Welcome to the MariaDB monitor.  Commands end with ; or \g.**

**Your MariaDB connection id is 5**

**Server version: 10.5.16-MariaDB MariaDB Server**

  

**Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.**

  

**Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.**
```

# 2. Serveur Web et NextCloud

### Install de PHP
### Install de tous les modules PHP nécessaires pour NextCloud

```
[linux@Web ~]$ sudo dnf install -y libxml2 openssl php php-ctype php-curl php-gd php-iconv php-json php-libxml php-mbstring php-openssl php-posix php-session php-xml php-zip php-zlib php-pdo php-mysqlnd php-intl php-bcmath php-gmp

Last metadata expiration check: 0:03:31 ago on Fri 20 Jan 2023 08:49:39 PM CET.

Package libxml2-2.9.13-2.el9.aarch64 is already installed.

Package openssl-1:3.0.1-43.el9_0.aarch64 is already installed.
```



### Récupérer NextCloud

```
[linux@Web tp5_nextcloud]$ sudo curl https://download.nextcloud.com/server/prereleases/nextcloud-25.0.0rc3.zip -o site.zip

[sudo] password for linux: 

  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current

                                 Dload  Upload   Total   Spent    Left  Speed

100  168M  100  168M    0     0  3421k      0  0:00:50  0:00:50 --:--:-- 3681k
```

```
[linux@Web tp5_nextcloud]$ sudo dnf install unzip

Last metadata expiration check: 0:19:19 ago on Fri 20 Jan 2023 08:49:39 PM CET.

Dependencies resolved.

================================================================================

 Package         Architecture      Version               Repository        Size

================================================================================
```

### **Adapter la configuration d'Apach**

A partir de cette endroit, la vm web ne voulais pas installez php donc j'ai du l'effacer
J'ai ensuite réinstallez une nouvelle vm et ensuite tu m'as donner un script pour tout réinstallez corretement.


### **Redémarrer le service Apache** 

```
[linux@Web ~]$ sudo systemctl restart httpd
```

# 3. Finaliser l'installation de NextCloud

### **Exploration de la base de données**

```

```