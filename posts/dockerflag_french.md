## 404CTF2025 - Docker Flag

Dans la catégorie Forensic du 404CTF, challenge nommé “Docker Flag”.

Description :

“En vous baladant sur le système informatique du vaisseau, vous tombez sur un vieux projet réalisé il y a bien longtemps, dans une galaxie lointaine, très lointaine. Le projet avait été arrêté assez rapidement et supprimé de votre Gitlab interne, mais peut-être que l'image Docker du site web que vous avez en votre possession a encore quelques secrets bien gardé”.

* * *

#### 1/ Découverte

Nous savons que nous allons devoir travailler avec Docker. Examinons le fichier “Dockerflag.tar” qui nous a été donnée.

Contenu : 

<figure class="image image_resized" style="width:54.31%;"><img style="aspect-ratio:771/650;" src="api/attachments/hy8luA6kjkLu/image/image.png" width="771" height="650"></figure>

Ces différents fichiers correspondes aux couches d'une image docker.

On sait également qu'on peut reconstituer une image docker avec un fichier tar.

```sh
sudo docker load < dockerflag.tar
Loaded image: unset-repo/unset-image-name:latest
```

Maintenant qu'on possède l'image docker (unset-repo/unset-image-name:latest) on peut lancer un conteneur.

```sh
sudo docker run unset-repo/unset-image-name:latest

 * Serving Flask app 'app'
 * Debug mode: off
WARNING: This is a development server. Do not use it in a production deployment. Use a production WSGI server instead.
 * Running on all addresses (0.0.0.0)
 * Running on http://127.0.0.1:5000
 * Running on http://172.17.0.2:5000
```

C'est un serveur web. Quand on se rend sur le site voici ce que l'on peut voir :

<figure class="image"><img style="aspect-ratio:1898/618;" src="api/attachments/PrRD7VaHnWH5/image/image.png" width="1898" height="618"></figure>

Il n'y a pas grand chose d'intéressant à en tirer malheureusement.

#### 2/ Dive

En forensic il existe un outil utile lors d'analyse d'image docker, c'est “dive”.

[https://github.com/wagoodman/dive](https://github.com/wagoodman/dive) 

Il permet d'explorer chaque couche d'une image docker et donner des détails très intéressants.

```sh
sudo dive unset-repo/unset-image-name:latest
```

<figure class="image"><img style="aspect-ratio:1077/697;" src="api/attachments/8KOVY6U9f8vV/image/image.png" width="1077" height="697"></figure>

*   Dans la section “Layers” on voit toutes les couches de l'image.
*   Dans la section “Layers Details” on peut voir les détails d'une couche, la partie intéressante est “Command”.
*   On peut également consulter le contenu (système de fichier) de chaque couche dans “Current Layer Contents”.

Pour comprendre comment fonctionne les couches docker voici un article :

[https://docs.docker.com/get-started/docker-concepts/building-images/understanding-image-layers/](https://docs.docker.com/get-started/docker-concepts/building-images/understanding-image-layers/) 

Les couches qui vont nous intéressez ici est “COPY git\_repos/ .” et “RUN rm -rf .git”.

On aimerait comprendre pourquoi le dossier “.git” a été supprimé et retrouvé son contenu. On possède dans le fichier dockerflag.tar toutes les couches. On va donc chercher avec un find où est ce que ce dossier peut se trouver après avoir extrait toutes les couches.

```sh
ls dockerflag
```

<figure class="image"><img style="aspect-ratio:585/358;" src="api/attachments/yGKGL35Q47Ak/image/image.png" width="585" height="358"></figure>

```sh
find ~/CTF404/forensic/dockerflag/dockerflag/ -name ".git"


/home/kali/CTF404/forensic/dockerflag/dockerflag/app (2)/.git
```

On se place à cette endroit et on fait un “ls -la”.

<figure class="image"><img style="aspect-ratio:487/174;" src="api/attachments/Ger8TenpkYHz/image/image.png" width="487" height="174"></figure>

#### 3/ Retour vers le passé

On affiche le contenu de "app.py" (code python du serveur web).

```sh
cat app.py    

 
import os

from flask import Flask, render_template
from dotenv import load_dotenv

load_dotenv()
SECRET_KEY = os.getenv("SECRET", default="WHERE IS ZE DOTENV ?")

app = Flask(__name__)

@app.route('/')
def index():
    return render_template("index.html")

app.run(debug=False, host="0.0.0.0", port=5000)
```

On se rend compte qu'il existe un fichier “.env”, un fichier qui contient des éléments sensibles mais il n'est pas présent dans le dossier.

On va se dirigé du côté du fichier log (HEAD) présent dans le dossier “.git”.

<figure class="image"><img style="aspect-ratio:657/203;" src="api/attachments/ky5TfaDNkmB5/image/image.png" width="657" height="203"></figure>

5 commit ont été réalisé en tout sur le repository de l'application. Je suppose que dans un de ces commit le fichier “.env” était présent.

En fouillant dans le man de la commande git on peut trouver une commande qui s'appelle “restore” et elle permet d'annuler les modifications non validées dans le répertoire de travail d'un dépôt Git. Exactement ce qu'il nous faut.

On initialise git dans le répertoire où se trouve le .git

```sh
git init
```

On va devoir maintenant se placer dans les commit qui ont été réalisés avec la commande “git checkout” suivi de son id (présent sur l'image au-dessus).

```sh
sudo git checkout 3d0717cb911d00b3e5033ba8c0c83df069e3e144


Note: switching to '3d0717cb911d00b3e5033ba8c0c83df069e3e144'.
```

Une fois placé, on va pouvoir utiliser la commande “git restore” suivi d'un “.” (Le point indique que la commande s'applique à tous les fichiers et sous-répertoires du répertoire courant).

```sh
sudo git restore .
```

On répète ces 2 actions jusqu'à trouver le fichier ".env" : 

<figure class="image"><img style="aspect-ratio:658/297;" src="api/attachments/Fy3roEVZ7ztP/image/image.png" width="658" height="297"></figure>

**FLAG : 404CTF{492f3f38d6b5d3ca859514e250e25ba65935bcdd9f4f40c124b773fe536fee7d}**