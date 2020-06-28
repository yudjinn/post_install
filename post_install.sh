#!/bin/bash
#Post-installation script

echo "Run this script as sudo"

#User input
echo "Is this a laptop?Y|N"
read lapstate
echo "Is this a surface?Y|N"
read surfstate
echo "Would you like to mount google drive?"
read googstate


#Add repos
echo "Adding Repos..."
add-apt-repository -y ppa:alessandro-strada/ppa universe

#For surface only
if [[$surfstate =~ ^[Yy]$ ]]
then
echo "Adding surfacelinux repos..."
wget -qO - https://raw.githubusercontent.com/linux-surface/linux-surface/master/pkg/keys/surface.asc \
    | sudo apt-key add - &
echo "deb [arch=amd64] https://pkg.surfacelinux.com/debian release main" | sudo tee /etc/apt/sources.list.d/linux-surface.list &
fi

#snaps and debs
snaps = (spotify android-messages-desktop code krita chromium unofficial-webapp-office)
debs = (gnome-tweak-tool python3 git terminology apt-transport-https ca-certificates curl gnupg-agent software-properties common)

#install packages
echo "Installing base packages"
apt-get update &
BACK_PID = $!
wait $BACK_PID
if [[$googstate =~ ^[Yy]$]]
then
apt-get install -y google-drive-ocamlfuse git
fi
echo "Debs first:"
echo $debs
apt-get install -y ${debs} &
$BACK_PID = $!
wait $BACK_PID
echo "Snaps now:"
echo $snaps
snap install -y ${snaps} &
$BACK_PID = $!
wait $BACK_PID
echo "Removing that pesky firefox..."
apt-get remove firefox

#Install docker
echo "Installing Docker..."
curl -fsSL https://download.docker.com/linux/debian/gpd | apt-key add - 
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" 
apt-get update &
$BACK_PID = $!
wait $BACK_PID
apt-get install docker-ce docker-ce-cli containerd.io 
usermod -aG docker $USER 

#Surface only installation
if [[$surfstat =~ ^[Yy]$ ]]
then
echo "Surfacelinux package installation..."
apt-get install -y linux-headers-surface linux-image-surface linux-libc-dev-surface surface-ipts-firmware libwacom-surface
apt-get install -y linux-surface-secureboot-mok
fi

#Laptop only installation
if [[$lapstate =~ ^[Yy]$ ]]
then
echo "Installing laptop performance packages"
apt-get install -y tlp powertop
tlp start 
fi

#git setup
echo "Setting git config..."
git config --global user.name yudjinn
git config --global user.email yudjinncoding@gmail.com

#start google drive util for authorization in webpage
if [[$googstate =~ ^[Yy]$ ]]
then
echo "Starting google drive mount util..."
google-drive-ocamlfuse
#make directory and mount google drive to it
mkdir ~/google-drive
google-drive-ocamlfuse ~/google-drive
fi

#Configure bashrc and kakrc
echo "Configuring bashrc and kakrc.."
echo -e "\n\nexport XDG_CONFIG_HOME=\$HOME/.config">>$HOME/.bashrc
source $HOME/.bashrc
mkdir $HOME/.config/kak
echo "hook global WinCreate ^[^*]+$ %{ add-highlighter window/ number-lines -hlcursor }">$HOME/.config/kak/kakrc
