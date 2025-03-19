#!/usr/bin/bash

###############################################################
#  TITRE: 
#
#  AUTEUR:   kamsu
#  VERSION: 
#  CREATION:  
#  MODIFIE: 
#
#  DESCRIPTION: 
###############################################################



curl -s https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get-helm-3 > get_helm.sh
chmod 700 get_helm.sh
./get_helm.sh

sudo su - vagrant -c "helm plugin add https://github.com/databus23/helm-diff"
sudo su - vagrant -c "helm plugin install https://github.com/jkroepke/helm-secrets"
sudo su - vagrant -c "helm plugin install https://github.com/aslafy-z/helm-git"
sudo su - vagrant -c "helm plugin install https://github.com/hypnoglow/helm-s3.git"

wget -qq https://github.com/helmfile/helmfile/releases/download/v0.169.1/helmfile_0.169.1_linux_amd64.tar.gz
tar xzf helmfile_0.169.1_linux_amd64.tar.gz helmfile
mv helmfile /usr/local/bin/
chmod +x /usr/local/bin/helmfile



