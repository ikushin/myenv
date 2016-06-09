VAGRANTFILE_API_VERSION = "2"
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.network :public_network

  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", "256"]
  end

  config.vm.provision :shell, :inline => <<-EOT
    sed -i '/^gpgkey/i enabled=0' /etc/yum.repos.d/CentOS-Base.repo
    echo 'H4sIAOIEWVcAA+3Sz0vDMBQH8J7zVwTmtc2PZd0c9KJXwYN4Gh5i+tjAbilJKvjfm85eFHQIBRG+n0NeQl6SRxJKTrwNxypQ72PVijvvbHceFbORWW3MOWZfo1yuVoXSa11rqXJbSGWMWRZczlfC94aYbOC8CN6nn/Iuzf9Tu2cbqezGV39iJ3uk5pZO6f6hvArUUZ57pcBLfpN7bEwdQtccUuq3QqhrXal6U+kcNmL8MsLltT6KWoypgu37vTuQe2kkY4tpv5YPfWsTRc52U+/y8Y8fib+pYNr7UxF/fdkAAAAAAAAAAAAAAAAAAAAAAAAzegd+PlYYACgAAA==' | base64 -di | tar zxvf - -C / >/dev/null 2>&1
    yum clean all
    yum repolist
    yum install -y yum-plugin-fastestmirror
    yum update -y
    yum install -y epel-release zsh make gcc ncurses-devel zlib-devel curl-devel expat-devel gettext-devel openssl-devel autoconf yum-utils perl-ExtUtils-MakeMaker mlocate screen
    yum install --enablerepo=extras -y epel-release && yum install -y git
    git clone https://github.com/ikushin/myenv.git ~/.myenv
    install -d -m 700 /root/.ssh
    cd ~/.myenv && git config --global push.default simple && make cp
    usermod -s /bin/zsh root
    /bin/rm /root/{anaconda-ks.cfg,install.log,install.log.syslog}
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

  config.vm.define "centos6tmp" do |server|
    server.vm.hostname = "cent6rpmbuild"
    server.vm.box = "Minimal-CentOS-6.0"
    server.vm.provision :shell, :inline => <<-EOT
    EOT
  end

end
