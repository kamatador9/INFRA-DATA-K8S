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



# Variables ###################################################

TYPE=$1
IP=$(hostname -I | awk '{print $2}')


# Functions ###################################################

install_k0s(){
  curl -sSf https://get.k0s.sh | sh
}

install_k0s_cluster(){
  rm -f /vagrant/token-file
  mkdir -p /etc/k0s/
  k0s config create > /etc/k0s/k0s.yaml
  sed -i s/"10.0.2.15"/${IP}/g /etc/k0s/k0s.yaml
  k0s install controller -c /etc/k0s/k0s.yaml
  k0s start
}

wait_api() {
    while [[ "$(curl -k --output /dev/null --silent -w ''%{http_code}'' https://127.0.0.1:6443)" != "401" ]];do
      printf '.';
      sleep 1;
    done
}

install_kubectl(){
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
  mkdir /home/vagrant/.k0s
  chown vagrant:vagrant -R /home/vagrant/.k0s
  cat /var/lib/k0s/pki/admin.conf > /home/vagrant/.k0s/kubeconfig
  chown vagrant:vagrant -R /home/vagrant/.k0s
  chmod 700 /home/vagrant/.k0s/kubeconfig
  export KUBECONFIG="/home/vagrant/.k0s/kubeconfig"
}

install_tooling(){
  wget -qq https://github.com/jonmosco/kube-ps1/archive/refs/tags/v0.9.0.tar.gz 
  tar xzf v0.9.0.tar.gz 
  cp kube-ps1-0.9.0/kube-ps1.sh /usr/local/bin/
  chmod +x /usr/local/bin/kube-ps1.sh
  curl -sL https://github.com/ahmetb/kubectx/releases/download/v0.9.5/kubens -o /usr/local/bin/kubens && sudo chmod +x /usr/local/bin/kubens
  curl -sL https://github.com/ahmetb/kubectx/releases/download/v0.9.5/kubectx -o /usr/local/bin/kubectx && sudo chmod +x /usr/local/bin/kubectx
  wget -qq https://github.com/derailed/k9s/releases/download/v0.32.5/k9s_linux_amd64.deb && apt install ./k9s_linux_amd64.deb && rm k9s_linux_amd64.deb
  apt-get install bash-completion
  echo "source <(kubectl completion bash)" >> ~/.bashrc
}

create_token(){
  k0s token create --role=worker --expiry=100h > /vagrant/token-file
}

join_cluster(){
  k0s install worker --token-file /vagrant/token-file
  k0s start
}

# Let's Go !! #################################################

if [[ "$TYPE" == "controller" ]];then
  install_k0s
  install_k0s_cluster
  wait_api
  install_kubectl
  install_tooling
  sleep 30s
  create_token
else
  install_k0s
  join_cluster
fi