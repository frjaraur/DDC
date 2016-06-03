
boxes = [
    {
        :node_name => "ucp-manager",
        :node_managementip => "10.0.100.10",
        :node_serviceip => "192.168.100.10",
        :node_mem => "2048",
        :node_cpu => "1"
    },
    {
        :node_name => "ucp-node1",
        :node_managementip => "10.0.100.11",
        :node_serviceip => "192.168.100.11",
        :node_mem => "2048",
        :node_cpu => "1"
    },
    {
        :node_name => "ucp-node2",
        :node_managementip => "10.0.100.12",
        :node_serviceip => "192.168.100.12",
        :node_mem => "2048",
        :node_cpu => "1"
    },
]

Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/trusty64"
  boxes.each do |opts|
  config.vm.define opts[:node_name] do |config|
  config.vm.hostname = opts[:node_name]
  config.vm.provider "virtualbox" do |v|
    v.name = opts[:node_name]
    v.customize ["modifyvm", :id, "--memory", opts[:node_mem]]
    v.customize ["modifyvm", :id, "--cpus", opts[:node_cpu]]
  end

      # config.vm.network "public_network",
      # bridge: "wlan0" ,
      # use_dhcp_assigned_default_route: true

      config.vm.network "private_network",
      ip: opts[:node_managementip],
      virtualbox__intnet: "DOCKER_MANAGEMENT"

      config.vm.network "private_network",
      ip: opts[:node_serviceip],
      virtualbox__intnet: "DOCKER_SERVICE"


      # if opts[:node_name] == "ucp-manager"
    	#  config.vm.network "forwarded_port", guest: 443, host: 8443
    	#  #config.vm.network "forwarded_port", guest: 22, host: 52222
      # end

      config.vm.provision "shell", inline: <<-SHELL
        sudo apt-get update -qq
      SHELL

      ## INSTALL DOCKER ENGINE
      config.vm.provision "shell", inline: <<-SHELL
        sudo apt-get install -qq curl
        curl -s 'https://sks-keyservers.net/pks/lookup?op=get&search=0xee6d536cf7dc86e2d7d56f59a178ac6c6238f52e' | sudo apt-key add --import
        sudo apt-get update -qq && sudo apt-get -qq install apt-transport-https
        sudo apt-get install -qq linux-image-extra-virtual
        echo "deb https://packages.docker.com/1.10/apt/repo ubuntu-trusty main" | sudo tee /etc/apt/sources.list.d/docker.list
        sudo apt-get update -qq && sudo apt-get install -qq docker-engine
	      echo "DOCKER_OPTS='-H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock'" >> /etc/default/docker
	      sudo service docker restart
      SHELL

      ## ADD HOSTS
      config.vm.provision "shell", inline: <<-SHELL
        echo "10.0.200.11 ucp-manager ucp-manager.dockerlab.local" >>/etc/hosts
        echo "10.0.200.12 ucp-node1 ucp-node1.dockerlab.local" >>/etc/hosts
        echo "10.0.200.13 ucp-node2 ucp-node2.dockerlab.local" >>/etc/hosts
        echo "10.0.200.14 ucp-replica1 ucp-replica1.dockerlab.local" >>/etc/hosts
        echo "10.0.200.15 ucp-replica2 ucp-replica2.dockerlab.local" >>/etc/hosts
      SHELL
    end
  end
end
