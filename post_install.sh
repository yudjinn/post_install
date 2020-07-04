#!/bin/bash
#Post-installation script


#User input
echo "Is this a laptop?Y|N"
read lapstate
echo "Is this a surface?Y|N"
read surfstate
echo "Would you like to mount google drive?"
read googstate


#Add repos
echo "Adding Repos..."
sudo add-apt-repository universe

#For surface only
if [[ $surfstate =~ ^[Yy]$ ]]
then
echo "Adding surfacelinux repos..."
sudo wget -qO - https://raw.githubusercontent.com/linux-surface/linux-surface/master/pkg/keys/surface.asc \
    | sudo apt-key add - 
echo "deb [arch=amd64] https://pkg.surfacelinux.com/debian release main" | sudo tee /etc/apt/sources.list.d/linux-surface.list &
fi

#snaps and debs
snaps=(spotify krita chromium unofficial-webapp-office)
debs=(gnome-tweak-tool python3 git apt-transport-https ca-certificates curl gnupg-agent software-properties-common snapd)

#install packages
echo "Installing base packages"
sudo apt-get update 
BACK_PID=$!
wait $BACK_PID
if [[ $googstate =~ ^[Yy]$ ]]
then
sudo apt install -y google-drive-ocamlfuse git
fi
echo "Debs first:"
echo ${debs[*]}
sudo apt install -y ${debs[*]} 
BACK_PID=$!
wait $BACK_PID
echo "Snaps now:"
echo ${snaps[*]}
sudo snap install ${snaps[*]}
BACK_PID=$!
wait $BACK_PID
echo "Removing that pesky firefox..."
sudo apt remove firefox

#Install docker
echo "Installing Docker..."
sudo apt install -y docker.io
#curl -fsSL https://download.docker.com/linux/debian/gpd | apt-key add - 
#add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" 
#apt-get update 
#$BACK_PID=$!
#wait $BACK_PID
#apt install docker-ce docker-ce-cli containerd.io 
sudo usermod -aG docker $USER 

#Surface only installation
if [[ $surfstate =~ ^[Yy]$ ]]
then
echo "Surfacelinux package installation..."
sudo apt install -y linux-headers-surface linux-image-surface linux-libc-dev-surface surface-ipts-firmware libwacom-surface
sudo apt install -y linux-surface-secureboot-mok
sudo echo "options ipts singletouch=y">/etc/modprobe.d/ipts.conf
fi

#Laptop only installation
if [[ $lapstate =~ ^[Yy]$ ]]
then
echo "Installing laptop performance packages"
sudo apt install -y tlp powertop
sudo tlp start 
fi

#git setup
#echo "Setting git config..."
#git config --global user.name "yudjinn"
#git config --global user.email "yudjinncoding@gmail.com"

#start google drive util for authorization in webpage
if [[ $googstate =~ ^[Yy]$ ]]
then
echo "Starting google drive mount util..."
google-drive-ocamlfuse
#make directory and mount google drive to it
mkdir -p ~/google-drive
sudo google-drive-ocamlfuse ~/google-drive
fi

#VS code installation
echo "Installing VSCode..."
sudo snap install code --classic
exts=( ms-python.python ms-python.vscode-pylance )
for i in "${exts[@]}"; do
    code --install-extension "$i"
done


#Configure bashrc and kakrc
echo "Configuring bashrc and kakrc.."
echo -e "\n\nexport XDG_CONFIG_HOME=\$HOME/.config">>$HOME/.bashrc
source $HOME/.bashrc
mkdir -p $HOME/.config/kak
echo "hook global WinCreate ^[^*]+$ %{ add-highlighter window/ number-lines -hlcursor }">$HOME/.config/kak/kakrc

