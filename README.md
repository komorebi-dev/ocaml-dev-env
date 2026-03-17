# Environnement de développement OCaml

## vm

Le script [vm.sh](./vm.sh) permet de créer via la CLI de VirtualBox une VM en utilisant un .iso/.vdi, possible de télécharger l’archive avec l’image en l’indiquant dans la variable `URL_DOWNLOAD`.

Ce script est basé sur un script similaire fait par [@shaolin-peanut](https://github.com/shaolin-peanut) pour sa Piscine OCAML, lui même basé sur celui de [@t-h2o](https://github.com/t-h2o) pour son Inception

> [!CAUTION]
> Les paths de téléchargements sont spécifiquement faits pour les Linux (Ubuntu) de 42 Lausanne, modifier ces paths pour qu’ils conviennent à votre environnement.

> [!NOTE]
> Vous pouvez également changer de OS/.iso/.vdi en modifiant l'url de téléchargement

> [!WARNING]
> Si vous changer l'url et donc d'OS/.iso/.vdi changer également toutes les variables en dessous de l’url de téléchargement pour qu’elles correspondent au nouvel OS/archive téléchargé

Ensuite le menu permet de sélectionner ce que l’on veut faire:

1. télécharger l’archive avec l’image qui est dans la variable `URL_DOWNLOAD`, extract l’archive, va ouvrir le dossier de téléchargement et vous demande de l’extraire vous (possibilité d’évolution en utilisant `tar -xvf` ou autre)
2. créer la VM, modifie/précise la config (RAM, VRAM …)
3. ajoute un shared folder entre la VM et l’hôte, demande le path du dossier hôte qui sera partagé sur la VM, ce dossier sera monté a `/media/sf_shared/`
4. start la VM
5. poweroff la VM
6. delete la VM y compris des dossiers associés (`EXTRACTED_DIR`, `/home/${whoami}/VirtualBox VMs/${VM_NAME}` voir la doc de la commande `VBoxManage unregistervm` avec l’option `--delete`)
7. delete le dossier d’extraction de l’archive (`${DL_DIR}/${DISTRO_NAME}/`)

La variable `${VDI_NAME}` ne **peut pas** dévier du nom de la `.vdi` dans l’archive extraite de `${ARCHIVE_NAME}` vers `${EXTRACTED_DIR}`.

username: `osboxes`

password: `osboxes.org` | same for `root` user

Le script [commands.sh](./commands.sh) est à exécuter une fois que la VM est lancée et être passe `root` (`sudo su` et `osboxes.org` comme password). Ce script va installer des outils/dépendances nécessaires pour la piscine.

Ubuntu: https://sourceforge.net/projects/osboxes/files/v/vb/55-U-u/25.04/64bit.7z/download


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

## dockerfile

Pour le moment je n’ai pas eu à modifier ou ajouter des choses à l’image docker donc j’utilise un Makefile pour directement pull et run l’image

[OCaml Docker - ocaml.org](https://ocaml.org/docs/ocaml-docker)

[OCaml repositories - docker hub](https://hub.docker.com/u/ocaml)


Pour les devcontainer: [ocaml-devcontainer - github/tarides](https://github.com/tarides/ocaml-devcontainer), sur les ordis de l’école je n’ai pas réussi à lancer le container, l’image fait ~4.5 GB mais l’installation est très facile et le devcontainer devrait pouvoir être utilisé sur un ordi perso.