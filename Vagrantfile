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
    yum install -y git
    git clone https://github.com/ikushin/myenv.git ~/.myenv
    mkdir /root/.ssh
    cd ~/.myenv && git config --global push.default simple && make cp
    usermod -s /bin/zsh root
  EOT

  config.vm.define :centos5 do |server|
    server.vm.hostname = "centos5"
    server.vm.box = "Minimal-CentOS-5.6"
    server.vm.provision :shell, :inline => <<-EOT
    EOT
  end

  config.vm.define :syslogng do |server|
    server.vm.hostname = "syslogng"
    server.vm.box = "Minimal-CentOS-5.6"
    server.vm.provision :shell, :inline => <<-EOT
    EOT
  end

  config.vm.define :mmall do |server|
    server.vm.hostname = "mmall"
    server.vm.box = "centos5_logrotate"
    server.vm.provision :shell, :inline => <<-EOT
	/sbin/ip -4 -oneline addr | grep -vw lo | /bin/sed "s@/@ /@"
    EOT
  end

  config.vm.define :mmopt do |server|
    server.vm.hostname = "mmopt"
    server.vm.box = "centos5_logrotate"
    server.vm.provision :shell, :inline => <<-EOT
	/sbin/ip -4 -oneline addr | grep -vw lo | /bin/sed "s@/@ /@"
    EOT
  end

  config.vm.define :fp do |server|
    server.vm.hostname = "fp"
    server.vm.box = "centos5_logrotate"
    server.vm.provision :shell, :inline => <<-EOT
	/sbin/ip -4 -oneline addr | grep -vw lo | /bin/sed "s@/@ /@"
    EOT
  end

  config.vm.define "centos6" do |server|
    server.vm.hostname = "centos6"
    server.vm.box = "Minimal-CentOS-6.0"
    server.vm.provision :shell, :inline => <<-EOT
    EOT
  end

end

