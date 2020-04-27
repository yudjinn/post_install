#!/bin/bash
#Simple utility for setting up rsync backups to google drive

#Add repos
sudo add-apt-repository -y ppa:alessandro-strada/ppa

#install packages
sudo apt-get update
sudo apt-get install -y google-drive-ocamlfuse git
snap install -y atom krita

#git setup
git config --global user.name yudjinn
git config --global user.email jacob.rodgers94@gmail.com

#start google drive util for authorization in webpage
google-drive-ocamlfuse

#make directory and mount google drive to it
mkdir ~/google-drive
google-drive-ocamlfuse ~/google-drive
