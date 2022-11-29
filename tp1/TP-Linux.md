
###  II. Feu

On vas PETER des vm !!

+ 1 ère méthode

J'ai étais dans le dossier ***boot*** et un beau fichier ma sourie 🤣

je l'ai donc effacer 
```
$ cd /
$ ls -all
$ cd boot
$ rm -rf loader
```

Voici le résultat au démarrage de la vm 😅

[Le résultat 🤣](Vm1.png)

+ 2 ème méthode

J'ai étais dans un dossier et j'ai modifier des caractères 😎
```
$ cd /
$ ls -all
$ cd proc
$ sudo nano version
```

Voici le résultat au démarrage de la vm 😲

[Le résultat 🤣](Vm2.png)

+ 3ème méthode

J'ai éffectue une commande MAGIQUE ***Fork bomb😈***

Cette commande crée des processus jusqu'à saturation de la mémoire ce qui fais plantez la vm 
```
$ cd /
$ :(){ :|: & };:
```

Voici le résultat obtenue au démarrage de la vm 😆

[Le résultat 🤣](Vm3.png)

+ 4ème méthode 

Je me suis déplacer dans le noyau et j'ai écrit une phrase en plus des caractère 
```
cd /
ls -all
cd boot
sudo nano vmlinuz-5.14.0-70.26.1.el9.aarch64
```

J'ai introduit "Hello world" dans la liste des caractères 

Voici le résultat au démarrage 😂

 [Le résultat 😂](Vm4.png)
 