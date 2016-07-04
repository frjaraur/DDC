
#global_action=ENV['UCP_PROVISON_ACTION']
if ENV['UCP_PROVISON_ACTION']
  global_action=ENV['UCP_PROVISON_ACTION']
else
  global_action="install"
end

## DEFAULTS
ucpcontrollerip="null"
dtrurl="https://node2"

boxes = [
    {
        :node_name => "ucp-manager",
        :node_managementip => "10.0.100.10",
        :node_storageip => "192.168.100.10",
        :node_mem => "3072",
        :node_cpu => "1",
        :node_ucprole => "controller",
        :node_ucpsan => "ucp-manager",
    },
    {
        :node_name => "ucp-replica1",
        :node_managementip => "10.0.100.11",
        :node_storageip => "192.168.100.11",
        :node_mem => "2048",
        :node_cpu => "1",
        :node_ucprole=> "replica",
        :node_ucpsan => "ucp-replica1",
    },
    {
        :node_name => "ucp-replica2",
        :node_managementip => "10.0.100.12",
        :node_storageip => "192.168.100.12",
        :node_mem => "2048",
        :node_cpu => "1",
        :node_ucprole=> "replica",
        :node_ucpsan => "ucp-replica2",
    },
    {
        :node_name => "ucp-node1",
        :node_managementip => "10.0.100.13",
        :node_storageip => "192.168.100.13",
        :node_mem => "2048",
        :node_cpu => "1",
        :node_ucprole=> "node",
        :node_ucpsan => "ucp-node1",
    },
    {
        :node_name => "ucp-node2",
        :node_managementip => "10.0.100.14",
        :node_storageip => "192.168.100.14",
        :node_mem => "2048",
        :node_cpu => "1",
        :node_ucprole=> "node",
        :node_ucpsan => "ucp-node2",
        :node_dtr => true,
    },
    # {
    #     :node_name => "ucp-client",
    #     :node_managementip => "10.0.100.100",
    #     :node_storageip => "192.168.100.100",
    #     :node_mem => "2048",
    #     :node_cpu => "1",
    #     :node_ucprole=> "client",
    #     :node_ucpsan => "null",
    # },
]

Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.synced_folder "tmp_deploying_stage/", "/tmp_deploying_stage",create:true
  config.vm.synced_folder "licenses/", "/licenses",create:true


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
      virtualbox__intnet: "DOCKER_PUBLIC"

      config.vm.network "private_network",
      ip: opts[:node_storageip],
      virtualbox__intnet: "DOCKER_STORAGE"


      if opts[:node_ucprole] == "controller"
    	  config.vm.network "forwarded_port", guest: 443, host: 8443, auto_correct: true
        ucpcontrollerip=opts[:node_managementip]
      end

      config.vm.provision "shell", inline: <<-SHELL
        sudo apt-get update -qq && apt-get install -qq chrony && timedatectl set-timezone Europe/Madrid
      SHELL

      ## INSTALL DOCKER ENGINE
      config.vm.provision "shell", inline: <<-SHELL
        sudo apt-get install -qq curl
        curl -s 'https://sks-keyservers.net/pks/lookup?op=get&search=0xee6d536cf7dc86e2d7d56f59a178ac6c6238f52e' | sudo apt-key add --import
        sudo apt-get update -qq && sudo apt-get -qq install apt-transport-https
        sudo apt-get install -qq linux-image-extra-virtual
        echo "deb https://packages.docker.com/1.11/apt/repo ubuntu-trusty main" | sudo tee /etc/apt/sources.list.d/docker.list
        sudo apt-get update -qq && sudo apt-get install -qq docker-engine
	      echo "DOCKER_OPTS='-H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock'" >> /etc/default/docker
	      sudo service docker restart
        sudo usermod -aG docker vagrant
      SHELL

      ## ADD HOSTS
      config.vm.provision "shell", inline: <<-SHELL
        echo "10.0.100.10 ucp-manager ucp-manager.dockerlab.local" >>/etc/hosts
        echo "10.0.100.11 ucp-replica1 ucp-replica1.dockerlab.local" >>/etc/hosts
        echo "10.0.100.12 ucp-replica2 ucp-replica2.dockerlab.local" >>/etc/hosts
        echo "10.0.100.13 ucp-node1 ucp-node1.dockerlab.local" >>/etc/hosts
        echo "10.0.100.14 ucp-node2 ucp-node2.dockerlab.local" >>/etc/hosts

      SHELL

      nodename=opts[:node_name]
      ucprole=opts[:node_ucprole]
      ucpsan=opts[:node_ucpsan]
      ucpip=opts[:node_managementip]

      config.vm.provision :shell, :path => 'ddc_install.sh', :args => [ global_action, nodename, ucprole, ucpcontrollerip, ucpip, ucpsan ]

      if opts[:node_dtr] == true
        config.vm.network "forwarded_port", guest: 443, host: 7443, auto_correct: true
        config.vm.provision :shell, :path => 'dtr_install.sh', :args => [ global_action, nodename, ucpcontrollerip, ucpip, ucpsan, dtrurl ]
      end

    end
  end
end
