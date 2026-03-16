#!/bin/bash

# Script with some commands needed to correctly setup the VM environment:
# - add the 'osboxes' user (default user of the VM)
# to the vboxsf group (VirtualBox shared folder group)
# - install some necessary utilities in the background
# - initialize the OCAML environment
# reboot the VM to apply the group changes

sudo usermod -aG vboxsf osboxes
sudo apt-get -y install git curl vim opam &
PID=$!
wait $PID

echo "1" | opam init &
PID=$!
wait $PID

eval $(opam env --switch=default)

sudo reboot