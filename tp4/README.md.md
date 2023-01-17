# TP4 : Real services

# Partie 1 : Partitionnement du serveur de stockage



### Partitionner le disque à l'aide de LVM

+ Première partie :

```
sudo pvcreate /dev/vdb
```

```
[linux@storage ~]$ lsblk

NAME        MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS

sr0          11:0    1 1024M  0 rom  

vda         252:0    0   64G  0 disk 

├─vda1      252:1    0  600M  0 part /boot/efi

├─vda2      252:2    0    1G  0 part /boot

└─vda3      252:3    0 62.4G  0 part 

  ├─rl-root 253:0    0 40.5G  0 lvm  /

  ├─rl-swap 253:1    0  2.1G  0 lvm  [SWAP]

  └─rl-home 253:2    0 19.8G  0 lvm  /home

vdb         252:16   0    2G  0 disk
```

```
sudo pvdisplay
```

+ Deuxième partie :

```
[linux@storage ~]$ sudo vgcreate storage /dev/vdb

  Physical volume "/dev/vdb" successfully created.

  Volume group "storage" successfully created
```
  
```
[linux@storage ~]$ sudo vgdisplay
```


+ Troisième partie :

```
[linux@storage ~]$ sudo lvcreate -l 100%FREE storage -n storage.tp4

  Logical volume "storage.tp4" created.
```

```
[linux@storage ~]$ lsblk

NAME                  MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS

sr0                    11:0    1 1024M  0 rom  

vda                   252:0    0   64G  0 disk 

├─vda1                252:1    0  600M  0 part /boot/efi

├─vda2                252:2    0    1G  0 part /boot

└─vda3                252:3    0 62.4G  0 part 

  ├─rl-root           253:0    0 40.5G  0 lvm  /

  ├─rl-swap           253:1    0  2.1G  0 lvm  [SWAP]

  └─rl-home           253:2    0 19.8G  0 lvm  /home

vdb                   252:16   0    2G  0 disk 

└─storage-storage.tp4 253:3    0    2G  0 lvm
```


### Formater la partition

+ Première partie :

```
[linux@storage ~]$ sudo mkfs -t ext4 /dev/storage/storage.tp4

mke2fs 1.46.5 (30-Dec-2021)

Discarding device blocks: done                            

Creating filesystem with 523264 4k blocks and 130816 inodes

Filesystem UUID: f94740e3-279f-45c9-92f7-216987c86357

Superblock backups stored on blocks: 

32768, 98304, 163840, 229376, 294912

  

Allocating group tables: done                            

Writing inode tables: done                            

Creating journal (8192 blocks): done

Writing superblocks and filesystem accounting information: done
```

### Monter la partition

```
[linux@storage storage]$ sudo mount /dev/storage/storage.tp4 /storage

[linux@storage storage]$ df -h | grep /storage

/dev/mapper**/storage**-storage.tp4  2.0G   24K  1.9G   1% **/storage**
```

+ Utilisation du **df -h** avec un **grep** :

```
[linux@storage storage]$ sudo nano linux

[linux@storage storage]$ ls

linux

[linux@storage storage]$ cat linux

hello
```

+ J'ai défini un montage automatique au boot de la machine :

```
[linux@storage storage]$ sudo nano /etc/fstab

[linux@storage storage]$ sudo umount /storage

[linux@storage storage]$ sudo mount -av

/                        : ignored

/boot                    : already mounted

/boot/efi                : already mounted

/home                    : already mounted

none                     : ignored

mount: /storage does not contain SELinux labels.

       You just mounted a file system that supports labels which does not

       contain labels, onto an SELinux box. It is likely that confined

       applications will generate AVC messages and not be allowed access to

       this file system.  For more details see restorecon(8) and mount(8).

/storage                 : successfully mounted
```

# Partie 2 : Serveur de partage de fichiers


### Donnez les commandes réalisées sur le serveur NFS `storage.tp4.linux`

``` 
[linux@storage storage]$ sudo nano /etc/exports 
```

```
[linux@storage ~]$ cat /etc/exports

/storage 192.168.64.18(rw,sync,no_subtree_check)
```

```
[linux@storage storage]$ sudo systemctl enable nfs-server 
Created symlink /etc/systemd/system/multi-user.target.wants/nfs-server.service → /usr/lib/systemd/system/nfs-server.service. 

[linux@storage storage]$ sudo systemctl start nfs-server 
```

```
[linux@storage storage]$ sudo systemctl status nfs-server 
**●** nfs-server.service - NFS server and services

     Loaded: loaded (/usr/lib/systemd/system/nfs-server.service; enabled; vendo>

    Drop-In: /run/systemd/generator/nfs-server.service.d

             └─order-with-mounts.conf

     Active: **active (exited)** since Tue 2023-01-03 12:06:53 CET; 3min 25s ago

    Process: 864 ExecStartPre=/usr/sbin/exportfs -r (code=exited, status=0/SUCC>

    Process: 866 ExecStart=/usr/sbin/rpc.nfsd (code=exited, status=0/SUCCESS)

    Process: 1013 ExecStart=/bin/sh -c if systemctl -q is-active gssproxy; then>

   Main PID: 1013 (code=exited, status=0/SUCCESS)

        CPU: 13ms

  

Jan 03 12:06:53 storage.tp4.linux systemd[1]: Starting NFS server and services.>

Jan 03 12:06:53 storage.tp4.linux systemd[1]: Finished NFS server and services. 
```

```
[linux@storage storage]$ sudo firewall-cmd --permanent --list-all | grep services services: cockpit dhcpv6-client ssh 
```

```
[linux@storage storage]$ sudo firewall-cmd --permanent --add-service=nfs 
sudo firewall-cmd --permanent --add-service=mountd 
sudo firewall-cmd --permanent --add-service=rpc-bind 
sudo firewall-cmd --reload 
success 
success 
success 
success
```

```
[linux@storage storage]$ sudo firewall-cmd --permanent --list-all | grep services services: cockpit dhcpv6-client mountd nfs rpc-bind ssh 
```

```
[linux@storage storage]$ sudo systemctl restart nfs-server 
```

### Donnez les commandes réalisées sur le client NFS `web.tp4.linux`

```
[linux@web ~]$ sudo mount 192.168.64.17:/storage/site_web_1 /var/www/site_web_1
```

```
[linux@web ~]$ sudo mount 192.168.64.17:/storage/site_web_2 /var/www/site_web_2
```

```
[linux@web ~]$ df -h

Filesystem                         Size  Used Avail Use% Mounted on

devtmpfs                           4.0M     0  4.0M   0% /dev

tmpfs                              346M     0  346M   0% /dev/shm

tmpfs                              139M  5.0M  134M   4% /run

/dev/mapper/rl-root                 41G  1.5G   40G   4% /

/dev/vda2                         1014M  235M  780M  24% /boot

/dev/vda1                          599M  7.0M  592M   2% /boot/efi

/dev/mapper/rl-home                 20G  2.7G   18G  14% /home

192.168.64.17:/storage/site_web_1  2.0G     0  1.9G   0% /var/www/site_web_1

192.168.64.17:/storage/site_web_2  2.0G     0  1.9G   0% /var/www/site_web_2

tmpfs                               70M     0   70M   0% /run/user/1000
```

```
[linux@web ~]$ sudo touch /var/www/site_web_1/hello

[linux@web ~]$ ls -l /var/www/site_web_1/hello 

-rw-r--r--. 1 nobody nobody 0 Jan  2 11:35 /var/www/site_web_1/hello
```

```
[linux@web ~]$ sudo touch /var/www/site_web_2/hello

[linux@web ~]$ ls -l /var/www/site_web_2/hello 

-rw-r--r--. 1 nobody nobody 0 Jan  2 11:35 /var/www/site_web_2/hello
```

```
[linux@web ~]$ sudo nano /etc/fstab
```

```
[linux@web ~]$ cat /etc/fstab
#

# /etc/fstab

# Created by anaconda on Fri Dec  9 09:15:42 2022

#

# Accessible filesystems, by reference, are maintained under '/dev/disk/'.

# See man pages fstab(5), findfs(8), mount(8) and/or blkid(8) for more info.

#

# After editing this file, run 'systemctl daemon-reload' to update systemd

# units generated from this file.

#

/dev/mapper/rl-root     /                       xfs     defaults        0 0

UUID=06a8ba56-a497-48b4-8506-62483fa83296 /boot                   xfs     defaults        0 0

UUID=CB78-B0ED          /boot/efi               vfat    umask=0077,shortname=winnt 0 2

/dev/mapper/rl-home     /home                   xfs     defaults        0 0

/dev/mapper/rl-swap     none                    swap    defaults        0 0

192.168.64.17:/storage/site_web_1  /var/www/site_web_1  nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0 0

192.168.64.17:/storage/site_web_2  /var/www/site_web_2 nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0 0

```

# Partie 3 : Serveur web

# 2. Install

+ Installez Nginx :

```
[linux@web ~]$ sudo dnf install nginx

[linux@web ~]$ sudo systemctl enable --now nginx

Created symlink /etc/systemd/system/multi-user.target.wants/nginx.service → /usr/lib/systemd/system/nginx.service.

[linux@web ~]$ sudo firewall-cmd --permanent --zone=public --add-service=http

success

[linux@web ~]$ sudo firewall-cmd --permanent --zone=public --add-port=80/tcp

success

[linux@web ~]$ sudo firewall-cmd --reload

success
```

# 3.Analyse 

### Analysez le service NGINX

+ Première partie :

```
[linux@web ~]$ ps -ef | grep nginx

root        1648       1  0 14:40 ?        00:00:00 **nginx**: master process /usr/sbin/**nginx**

**nginx**       1649    1648  0 14:40 ?        00:00:00 **nginx**: worker process

linux       1689    1395  0 14:59 pts/0    00:00:00 grep --color=auto **nginx**

```

+ Deuxième partie :

```
[linux@web ~]$ ss -alnpt |grep 80

LISTEN 0      511          0.0.0.0:**80**        0.0.0.0:*          

LISTEN 0      511             [::]:**80**           [::]:*

```
+ Troisième partie :

```

```
+ Quatrième partie :

# 4. Visite du service web

### Configurez le firewall pour autoriser le trafic vers le service NGINX

### Accéder au site web

### Vérifier les logs d'accès

# 5. Modif de la conf du serveur web

### Changer le port d'écoute

### Changer l'utilisateur qui lance le service

### Changer l'emplacement de la racine Web

# 6. Deux sites web sur un seul serveur

### Repérez dans le fichier de conf

### Créez le fichier de configuration pour le premier site

### Créez le fichier de configuration pour le deuxième site

### Prouvez que les deux sites sont disponibles
