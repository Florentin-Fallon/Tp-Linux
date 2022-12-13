## TP 3 : We do a little scripting

# I. Script carte d'identité

Voici le résultat dans le terminal :

```
[linux@localhost srv]$ ./idcard/idcard.sh

Machine name : localhost 
Os Rocky Linux release 9.1 (Blue Onyx) and kernel version is #1 SMP PREEMPT_DYNAMIC Mon Nov 28 20:07:39 UTC 2022
IP : 192.168.64.15 fd78:634a:b00a:2bb2:40d7:8ff:fe0f:8119 
RAM : 68660 KB memory available on 708576 KB total memory
Disk : 606032 KB space left
Top 5 processes by RAM usage : 
-/home/linux/.cache/JetBrains/Fleet/artifacts/609.3/jbr/bin/java
-/usr/bin/python3
-/usr/sbin/NetworkManager
-/usr/lib/polkit-1/polkitd
-/home/linux/.cache/JetBrains/Fleet/artifacts/1.11.116/fsdaemon/fsdaemon
Listening ports :
  - udp 127.0.0.1:323 
  - tcp  0.0.0.0:22 
 Here is your random cat : cat.png 
 ```
 
Voici le script [ici](fichier/idcard.sh)

# II. Script youtube-dl

Voici le résultat dans le terminal en éxécutant `./yt/yt.sh` :

```
[linux@localhost srv]$ ./yt/yt.sh https://www.youtube.com/watch?v=sNx57atloH8

Video https://www.youtube.com/watch?v=sNx57atloH8 was downloaded.
File path : /srv/yt/downloads/tomato anxiety/tomato anxiety.mp4
```

Voici la sortie du fichier `download.log` :

```
[linux@localhost yt]$ cat download.log 

[12/13/22 09:31:37] Video https://www.youtube.com/watch?v=sNx57atloH8 was downloaded. File path : /srv/yt/downloads/tomato anxiety/tomato anxiety.mp4
```

Voici lle script [ici](fichier/yt.sh)

# III. MAKE IT A SERVICE

