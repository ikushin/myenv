VAGRANTFILE_API_VERSION = "2"
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.network :public_network

  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", "256"]
  end

  config.vm.provision :shell, :inline => <<-EOT
    yum install -y yum-plugin-fastestmirror
    yum update -y
    yum install -y epel-release zsh make gcc ncurses-devel zlib-devel curl-devel expat-devel gettext-devel openssl-devel autoconf emacs yum-utils perl-ExtUtils-MakeMaker
  EOT

  config.vm.define :centos5 do |server|
    server.vm.hostname = "centos5"
    server.vm.box = "Minimal-CentOS-5.6"
    server.vm.provision :shell, :inline => <<-EOT
    EOT
  end

  config.vm.define "centos6" do |server|
    server.vm.hostname = "centos6"
    server.vm.box = "Minimal-CentOS-6.0"
    server.vm.provision :shell, :inline => <<-EOT
    EOT
  end

end

