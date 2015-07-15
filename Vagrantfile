VAGRANTFILE_API_VERSION = '2'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # VirtualBox
  config.vm.define "virtualbox" do |vb|
    # Configure The Box
    vb.vm.box = 'chef/ubuntu-14.04'
    vb.vm.hostname = 'homestead'
    config.vm.provider :virtualbox do |vb|
      vb.customize ['modifyvm', :id, '--memory', '2048']
      vb.customize ['modifyvm', :id, '--natdnsproxy1', 'on']
      vb.customize ['modifyvm', :id, '--natdnshostresolver1', 'on']
    end
    # Run The Base Provisioning Script
    config.vm.provision 'shell', path: './scripts/update.sh'
    config.vm.provision :reload
    config.vm.provision 'shell', path: './scripts/provision.sh'
  end
  # VMware Fusion
  config.vm.define "vmware_fusion" do |vf|
    # Configure The Box
    vf.vm.box = 'chef/ubuntu-14.04'
    vf.vm.hostname = 'homestead'
    config.vm.provider :vmware_fusion do |vf|
      vf.memory = 2048
      vf.cpus = 2
    end
    # Run The Base Provisioning Script
    config.vm.provision 'shell', path: './scripts/update.sh'
    config.vm.provision :reload
    config.vm.provision 'shell', path: './scripts/vmware_tools.sh'
    config.vm.provision :reload
    config.vm.provision 'shell', path: './scripts/provision.sh'
  end
  # Parallels Desktop
  config.vm.define "parallels_desktop" do |pd|
    # Configure The Box
    pd.vm.box = 'parallels/ubuntu-14.04'
    pd.vm.hostname = 'homestead'
    config.vm.provider :parallels do |pd|
      pd.name = 'homestead'
      pd.update_guest_tools = true
      pd.memory = 2048
      pd.cpus = 2
    end
    # Run The Base Provisioning Script
    config.vm.provision 'shell', path: './scripts/update.sh'
    config.vm.provision :reload
    config.vm.provision 'shell', path: './scripts/provision.sh'
  end

  # Don't Replace The Default Key https://github.com/mitchellh/vagrant/pull/4707
  config.ssh.insert_key = false

  # Configure Port Forwarding
  config.vm.network 'forwarded_port', guest: 80, host: 8000
  config.vm.network 'forwarded_port', guest: 3306, host: 33060
  config.vm.network 'forwarded_port', guest: 5432, host: 54320
  config.vm.network 'forwarded_port', guest: 35729, host: 35729

  config.vm.synced_folder './', '/vagrant', disabled: true
end
