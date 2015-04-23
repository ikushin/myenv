
cp:
	for i in zshrc emacs inputrc screenrc vimrc zprompt; do /bin/cp -a ~/.myenv/$$i ~/.$$i; done

ssh:
	/bin/cp config ~/.ssh/config && chmod 600 ~/.ssh/config

apt:
	sudo /bin/sed -ri.org 's@http://[^ ]+ubuntu@http://ftp.jaist.ac.jp/ubuntu@' /etc/apt/sources.list

sudo:
	echo 'Defaults:ikushin !requiretty' > /etc/sudoers.d/ikushin
	echo 'ikushin ALL = (root) NOPASSWD:ALL' >>/etc/sudoers.d/ikushin

date:
	sudo ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

package_cent:
	git clone https://github.com/dagwieers/dstat.git $HOME

git:
	sudo yum install -y zsh make gcc ncurses-devel zlib-devel curl-devel expat-devel gettext-devel openssl-devel
	wget --no-check-certificate https://www.kernel.org/pub/software/scm/git/git-2.3.5.tar.gz -O /tmp/git-2.3.5.tar.gz
	tar zxf /tmp/git-2.3.5.tar.gz -C /tmp
	cd /tmp/git-2.3.5; ./configure && make && sudo make install
	git clone https://github.com/dagwieers/dstat.git $HOME

zsh:
	sudo usermod -s /bin/zsh ikushin

