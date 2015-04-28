
cp:
	for i in zshrc emacs inputrc screenrc vimrc; do /bin/cp -a ~/.myenv/$$i ~/.$$i; done
	[ -f ~/.localrc ] || cp zprompt ~/.localrc

ssh:
	/bin/cp config ~/.ssh/config && chmod 600 ~/.ssh/config

apt:
	sudo /bin/sed -ri.org 's@http://[^ ]+ubuntu@http://ftp.jaist.ac.jp/ubuntu@' /etc/apt/sources.list

sudo:
	echo 'Defaults:ikushin !requiretty' > /etc/sudoers.d/ikushin
	echo 'ikushin ALL = (root) NOPASSWD:ALL' >>/etc/sudoers.d/ikushin

date:
	sudo ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

dstat:
	git clone https://github.com/dagwieers/dstat.git $$HOME/dstat

git:
	sudo yum install -y zsh make gcc ncurses-devel zlib-devel curl-devel expat-devel gettext-devel openssl-devel
	wget --no-check-certificate https://www.kernel.org/pub/software/scm/git/git-2.3.5.tar.gz -O /tmp/git-2.3.5.tar.gz
	tar zxf /tmp/git-2.3.5.tar.gz -C /tmp
	cd /tmp/git-2.3.5; ./configure && make && sudo make install

zsh:
	sudo usermod -s /bin/zsh ikushin

epel:
	rpm -Uvh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm

apt_proxy:
	echo 'Acquire::ftp::proxy   "ftp://example.com:8080/"  ;' >>/etc/apt/apt.conf
	echo 'Acquire::http::proxy  "http://example.com:8080/" ;' >>/etc/apt/apt.conf
	echo 'Acquire::https::proxy "https://example.com:8080/";' >>/etc/apt/apt.conf


wget_proxy:
	echo 'http_proxy = http://example.com:8080/' >>/etc/wgetrc

yum_proxy:
	echo 'proxy=http://example.com:8080/' >>/etc/yum.conf

git_proxy:
	git config --global http.proxy  http://example.com:8080
	git config --global https.proxy http://example.com:8080







