#!/bin/bash -x
# Microkube bootstrap script

# Docker installation
curl -fsSL https://get.docker.com/ | bash
sudo usermod -aG docker $USER

# Docker Compose installation
sudo curl -L "https://github.com/docker/compose/releases/download/1.23.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Reload the session
. ~/.profile

# RVM and Ruby Installation
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
curl -sSL https://get.rvm.io | bash -s stable
. ~/.profile
rvm install 2.5.3
rvm use 2.5.3
gem install bundler
sudo apt-get install libmysqlclient-dev ruby-mysql2 mariadb

# Git clone Microkube
cd $HOME
git clone https://github.com/rubykube/microkube.git
cd microkube

# Install the gems
bundle
rake vendor:clone

# TODO Interactive configuration of Microkube
rake render:config
rake service:all
rake service:daemons
