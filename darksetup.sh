#!/usr/bin/env bash

####################
# Darkweb Install #
####################

cd ~/
apt update
echo "Installing Vim"
apt install -y wget vim vim-python-jedi curl exuberant-ctags git ack-grep isort

# Docker Install
echo "Installing Docker"
apt remove docker docker-engine docker.io
sudo apt -y install curl gnupg2 apt-transport-https software-properties-common ca-certificates

curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/docker-archive-keyring.gpg
echo "deb [arch=amd64] https://download.docker.com/linux/debian buster stable" | sudo tee /etc/apt/sources.list.d/docker.list
apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io

echo "Installing Docker-Compose!"
sudo mkdir -p ~/.docker/cli-plugins
sudo curl -L "https://github.com/docker/compose/releases/download/v2.0.1/docker-compose-$(uname -s)-$(uname -m)" -o ~/.docker/cli-plugins/docker-compose
sudo chmod +x ~/.docker/cli-plugins/docker-compose

echo "Installing GIT TOOLS"
#cloning GitTools Dumper, Extractor and Finder
git clone https://github.com/internetwache/GitTools.git
