VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
	# Configure The Box
	config.vm.box = "ubuntu/trusty64"
	config.vm.hostname = "homestead"

	config.vm.network :private_network, ip: "192.168.33.10"

	config.vm.provider "virtualbox" do |vb|
	  vb.customize ["modifyvm", :id, "--memory", "2048"]
	  vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
	  vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
	end

	# Vagrant Cachier - more info on http://fgrehm.viewdocs.io/vagrant-cachier/usage
	if Vagrant.has_plugin?("vagrant-cachier")
	  config.cache.scope = :box
	  config.cache.enable :composer
	  config.cache.enable :generic, { "wget" => { cache_dir: "/var/cache/wget" } }
	  config.cache.synced_folder_opts = { type: :nfs, mount_options: ['rw', 'vers=3', 'tcp', 'nolock'] }
	end

	# Configure Port Forwarding
	config.vm.network "forwarded_port", guest: 80, host: 8000
	config.vm.network "forwarded_port", guest: 3306, host: 33060
	config.vm.network "forwarded_port", guest: 5432, host: 54320
	config.vm.network "forwarded_port", guest: 35729, host: 35729

	# Run The Base Provisioning Script
	config.vm.provision "shell" do |s|
	  s.path = "./scripts/provision.sh"
	end
end
