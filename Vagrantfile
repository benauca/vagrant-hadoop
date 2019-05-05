Vagrant.configure("2") do |config|
	# The most common configuration options are documented and commented below.
	# For a complete reference, please see the online documentation at
	# https://docs.vagrantup.com.

	# Every Vagrant development environment requires a box. You can search for
	# boxes at https://atlas.hashicorp.com/search.
	config.vm.box = "geerlingguy/centos7"
	config.vm.synced_folder ".", "/vagrant", type: "virtualbox"
	#config.vm.network "public_network", bridge: "Intel(R) Dual Band Wireless-AC 7260", ip: "192.168.1.101"
	config.vm.network "forwarded_port", guest: 50070, host: 50070, host_ip: "127.0.0.1" #Hadoop Administrator
	config.vm.provider "virtualbox" do |vb_development|
	vb_development.memory = "5000"
	end
	#############################
	# NODE HADOOP				#
	#############################
	config.vm.define "node_hadoop", primary: true do |node_hadoop|
	if Vagrant.has_plugin?("vagrant-proxyconf")
		  #node_hadoop.proxy.http     = "http://proxyapps.gsnet.corp:80"
		  #node_hadoop.proxy.https    = "http://proxyapps.gsnet.corp:80"
		  node_hadoop.proxy.no_proxy = "localhost,127.0.0.1,gsnetcloud.corp,gsnet.corp,192.168.1.101"
		end
		node_hadoop.vm.provision "shell", inline: "/bin/sh /vagrant/vagrant_files/script1.sh"
		node_hadoop.vm.provision "shell", inline: "runuser -l vagrant -c '/bin/sh /vagrant/ansible_files/runAnsibleLocal.sh'"
  end
end


