# 1. apt_proxy or yum_proxy
# 2. apt-get install -y aptigude make && make apt_conf && make wget_proxy && make package && make git_apt
# 3. make adduser && make sudo
# 4. ssh-copy-id
# 5. scp ~/.ssh/ikushin.id_rsa ubuntu:~/.ssh
# 6. make git_clone
# 7. make git_proxy
# 8. make date

cp:
	for i in zshrc emacs inputrc screenrc vimrc; do /bin/cp -a ~/.myenv/$$i ~/.$$i; done
	[ -e ~/.localrc ] || /bin/cp zprompt ~/.localrc
	[ -e ~/.ssh/config ] || /bin/cp config ~/.ssh/config

cygwin:
	mkdir -p ~/bin/; [ -f ~/bin/puttylog_archive.sh ] || cp puttylog_archive.sh ~/bin/puttylog_archive.sh

ssh:
	/bin/cp config ~/.ssh/config && chmod 600 ~/.ssh/config

package:
	grep -q "Ubuntu" /etc/lsb-release; [ $$? -eq 0 ] && sudo aptitude install -y zsh make gcc ncurses-dev gettext jq ncdu pssh libcurl4-openssl-dev emacs; true
	[ -x /usr/bin/yum ] && sudo yum install -y zsh make gcc ncurses-devel zlib-devel curl-devel expat-devel gettext-devel openssl-devel autoconf emacs; true

apt_conf:
	sudo /bin/sed -ri.org 's@http://[^ ]+ubuntu@http://ftp.jaist.ac.jp/ubuntu@' /etc/apt/sources.list
	apt-get update && apt-get -y upgrade

sudo:
	echo 'Defaults:ikushin !requiretty' > /etc/sudoers.d/ikushin
	echo 'ikushin ALL = (root) NOPASSWD:ALL' >>/etc/sudoers.d/ikushin
	chmod 0440 /etc/sudoers.d/ikushin

date:
	sudo ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

dstat:
	mkdir $$HOME/bin
	git clone https://github.com/dagwieers/dstat.git $$HOME/bin/dstat

git:
	wget --no-check-certificate https://www.kernel.org/pub/software/scm/git/git-2.3.5.tar.gz -O /tmp/git-2.3.5.tar.gz
	tar zxf /tmp/git-2.3.5.tar.gz -C /tmp
	cd /tmp/git-2.3.5; ./configure --without-tcltk && make && sudo make install
	git config --global user.email "you@example.com"
	git config --global user.name "ikushin"

zsh:
	git clone git://git.code.sf.net/p/zsh/code /tmp/zsh
	cd /tmp/zsh && ./Util/preconfig && ./configure && make && sudo make install.bin
	sudo usermod -s /usr/local//bin/zsh ikushin

epel:
	rpm -Uvh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm

apt_proxy:
	echo 'Acquire::ftp::proxy   "ftp://example.com:8080/"  ;' >>/etc/apt/apt.conf
	echo 'Acquire::http::proxy  "http://example.com:8080/" ;' >>/etc/apt/apt.conf
	echo 'Acquire::https::proxy "https://example.com:8080/";' >>/etc/apt/apt.conf

wget_proxy:
	echo 'http_proxy = http://example.com:8080/' >>/etc/wgetrc
	echo 'https_proxy = https://example.com:8080/' >>/etc/wgetrc

yum_proxy:
	echo 'proxy=http://example.com:8080/' >>/etc/yum.conf

git_proxy:
	git config --global http.proxy  http://example.com:8080
	git config --global https.proxy http://example.com:8080

parallel:
	wget --no-check-certificate http://ftp.gnu.org/gnu/parallel/parallel-20150422.tar.bz2 -O /tmp/parallel-20150422.tar.bz2
	tar jxf /tmp/parallel-20150422.tar.bz2 -C /tmp
	cd /tmp/parallel-20150422/; ./configure && make && make install

fuck_dpkg:
	sudo aptitude install -y python-pip python2.7-dev && sudo pip install thefuck

ansible:
	sudo aptitude install -y ansible

adduser:
	useradd -m -s /bin/zsh -p '$$6$$XYCe4cG6$$T/Is4TiopXaf8E06g6AKStbze2ENmhEsmOkC0mVacSWxHHLdff1kNF1EfSsKQpuvaniVwrdzZAOaKrgXagbjC1' ikushin

git_clone:
	echo 'IdentityFile=~/.ssh/ikushin.id_rsa' >.ssh/config
	git clone git@github.com:ikushin/myenv.git ~/.myenv
	rm -f ~/.ssh/config ~/Makefile
	cd ~/.myenv && git config --global push.default simple && make cp
