if [ ! -f "/home/vagrant/.ssh/id_rsa" ]; then
  ssh-keygen -t rsa -N "" -f /home/vagrant/.ssh/id_rsa
fi

#cp /home/vagrant/.ssh/id_rsa.pub /vagrant/vagrant_files/control.pub
#cat /vagrant/vagrant_files/control.pub >> /home/vagrant/.ssh/authorized_keys

#permitimos la conexion de ansible desde localhost
cat /home/vagrant/.ssh/id_rsa.pub >> /home/vagrant/.ssh/authorized_keys
cat /vagrant/vagrant_files/config > /home/vagrant/.ssh/config

chown -R vagrant:vagrant /home/vagrant/.ssh/
sudo yum -y install epel-release ansible

sudo cp /vagrant/ansible_files/ansible.cfg /etc/ansible/

sudo chown -R vagrant:vagrant /etc/ansible/ansible.cfg
