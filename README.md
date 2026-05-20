# Environnement de développement OCaml

## vm

Derive de [vm_generator_42Lausanne](https://github.com/komorebi-dev/vm_generator_42Lausanne)

> [!CAUTION]
> Les paths de téléchargements sont spécifiquement faits pour les Linux (Ubuntu) de 42 Lausanne, modifier ces paths pour qu’ils conviennent à votre environnement.

>[!CAUTION]
> Les variables globales (URL_DOWNLOAD, COMPUTER_ARCHITECTURE, ARCHIVE_PATH, OS_TYPE and VM_NAME) sont importantes pour la bonne execution du script
> Modifier les avec attention

> [!NOTE]
> Copier les dossiers du shared folder dans un autre dossier (typiquement le home) permet d’optimiser la vitesse de compilation avec ocamlopt la ou je me trouvais dans certains cas avec la VM qui crash

Ensuite le menu permet de sélectionner ce que l’on veut faire:

1. télécharger l’archive avec l’image qui est dans la variable `URL_DOWNLOAD`, extract l’archive, va ouvrir le dossier de téléchargement et vous demande de l’extraire vous (possibilité d’évolution en utilisant `tar -xvf` ou autre => pas dispo sur les ordis de 42)
2. créer la VM, modifie/précise la config (RAM, VRAM …), port forwarding 22 -> 2222 (ssh)
3. ajoute un/des shared folder entre la VM et l’hôte, demande le path du dossier hôte qui sera partagé sur la VM, ce dossier sera monté a `/media/sf_{nom du dossier}`
4. start la VM, propose en `headless` ou non
5. poweroff la VM
6. delete la VM y compris des dossiers associés (`/home/${whoami}/VirtualBox VMs/${VM_NAME}`)
7. delete le dossier d’extraction de l’archive


username: `osboxes`

password: `osboxes.org` | same for `root` user

Le script [commands.sh](./commands.sh) est à exécuter une fois que la VM est lancée et être passe `root` (`sudo su` et `osboxes.org` comme password). Ce script va installer des outils/dépendances nécessaires pour la piscine.

Ubuntu Server : https://sourceforge.net/projects/osboxes/files/v/vb/59-U-u-svr/25.04/64bit.7z/download
>[!NOTE]
> Il faut installer les `guest additions` de VirtualBox lorsqu'on utilise Ubuntu Server
> `sudo apt update`
> `sudo apt install virtualbox-guest-utils virtualbox-guest-x11 -y`
> `sudo reboot`
> reprendre le processus habituel avec `commands.sh` mount a `/media/...`

Ubuntu : https://sourceforge.net/projects/osboxes/files/v/vb/55-U-u/25.04/64bit.7z/download


<details>
  <summary>doc VirtualBox / VM</summary>

  [Chapter 8. VBoxManage | virtualbox man](https://www.virtualbox.org/manual/ch08.html)

  [VirtualBox Images](https://www.osboxes.org/virtualbox-images/)

  [OSBoxes | sourceforge](https://sourceforge.net/projects/osboxes/)

  [Oracle VM VirtualBox User Manual | oracle](https://docs.oracle.com/en/virtualization/virtualbox/6.0/user/vboxmanage.html)

  [Managing Oracle VM VirtualBox from the Command Line | oracle](https://www.oracle.com/technical-resources/articles/it-infrastructure/admin-manage-vbox-cli.html)

  [Password for virtual machines](https://www.osboxes.org/faq/what-are-the-credentials-for-virtual-machine-image/)
</details>

[installing OCaml #for Linux - ocaml.org](https://ocaml.org/docs/installing-ocaml#for-linux)

## Image Docker

Pour le moment je n’ai pas eu à modifier ou ajouter des choses à l’image docker donc j’utilise un Makefile pour directement pull et run l’image

[OCaml Docker - ocaml.org](https://ocaml.org/docs/ocaml-docker)

[OCaml repositories - docker hub](https://hub.docker.com/u/ocaml)

> [!NOTE]
> La variable `VOLUME_PATH` est le path vers le dossier à utiliser comme source du volume (par défaut `/home/${USER}/Desktop/42-piscine-ocaml`)
> Il est possible de modifier cette variable durant l’exécution d’une commande `make` en ajoutant `VOLUME_PATH=/new/path`, e.g. `make VOLUME_PATH=./` `make run VOLUME_PATH=./`

> [!WARNING]
> Le dossier source du volume (sur l’host) doit être read, write and executable par les `others`, pour que l’on puisse run `ocamlopt` sur les fichiers du volume et continuer à les modifier dans l’IDE. Il faut donc run sur l’host `chmod -R 757 [source volume]`

Pour les devcontainer: [ocaml-devcontainer - github/tarides](https://github.com/tarides/ocaml-devcontainer), sur les ordis de l’école je n’ai pas réussi à lancer le container, l’image fait ~4.5 GB mais l’installation est très facile et le devcontainer devrait pouvoir être utilisé sur un ordi perso.