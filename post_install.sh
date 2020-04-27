#!/bin/bash
#Simple utility for setting up rsync backups to google drive

#Add repos
sudo add-apt-repository -y ppa:alessandro-strada/ppa


#For surface only
wget -qO - https://raw.githubusercontent.com/linux-surface/linux-surface/master/pkg/keys/surface.asc \
    | sudo apt-key add -
echo "deb [arch=amd64] https://pkg.surfacelinux.com/debian release main" | sudo tee /etc/apt/sources.list.d/linux-surface.list



#install packages
sudo apt-get update
sudo apt-get install -y google-drive-ocamlfuse git
snap install -y atom krita

#Surface only installation
sudo apt-get install linux-headers-surface linux-image-surface linux-libc-dev-surface surface-ipts-firmware libwacom-surface
sudo apt-get install linux-surface-secureboot-mok


#git setup
git config --global user.name yudjinn
git config --global user.email jacob.rodgers94@gmail.com

#start google drive util for authorization in webpage
google-drive-ocamlfuse

#make directory and mount google drive to it
mkdir ~/google-drive
google-drive-ocamlfuse ~/google-drive
