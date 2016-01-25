
cp:
	for i in zshrc emacs inputrc screenrc vimrc; do /bin/cp -a ~/.myenv/$$i ~/.$$i; done
	[ -e ~/.localrc ] || /bin/cp zprompt ~/.localrc
	mkdir -p ~/.ssh
	[ -e ~/.ssh/config ] || /bin/cp config ~/.ssh/config; chmod 600 ~/.ssh/config
	[ $$OSTYPE == "cygwin" ] && if [[ ! -e /usr/local/bin/perl ]]; then make perl; fi

cygwin:
	mkdir -p ~/bin/; [ -f ~/bin/puttylog_archive.sh ] || cp puttylog_archive.sh ~/bin/puttylog_archive.sh

ssh:
	/bin/cp config ~/.ssh/config && chmod 600 ~/.ssh/config

package:
	grep -q "Ubuntu" /etc/lsb-release; [ $$? -eq 0 ] && sudo aptitude install -y git autoconf zsh make gcc ncurses-dev gettext jq ncdu pssh libcurl4-openssl-dev emacs-goodies-el; true
	[ -x /usr/bin/yum ] && sudo yum install -y zsh make gcc ncurses-devel zlib-devel curl-devel expat-devel gettext-devel openssl-devel autoconf epel-release; true

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
	mkdir -p $$HOME/bin
	git clone https://github.com/dagwieers/dstat.git $$HOME/bin/dstat

GIT=2.7.0
git2:
	rpm --quiet -q curl-devel expat-devel gettext-devel openssl-devel zlib-devel perl-ExtUtils-MakeMaker && sudo yum --disablerepo=updates install -y curl-devel expat-devel gettext-devel openssl-devel zlib-devel perl-ExtUtils-MakeMaker; :
	wget --no-check-certificate https://www.kernel.org/pub/software/scm/git/git-$(GIT).tar.gz -O /tmp/git-$(GIT).tar.gz
	tar zxf /tmp/git-$(GIT).tar.gz -C /tmp
	cd /tmp/git-$(GIT); ./configure --without-tcltk && make
	cd /tmp/git-$(GIT); [ $$OSTYPE == "cygwin" ] && PERL_PATH=/usr/local/bin/perl make install || sudo make install
	git config --global user.email "you@example.com"
	git config --global user.name "ikushin"

zsh5:
	grep -q "release 5" /etc/issue && make autoconf
	rpm --quiet -q ncurses-devel || sudo yum --disablerepo=updates install ncurses-devel
	git clone http://git.code.sf.net/p/zsh/code zsh-code
	cd zsh-code && ./Util/preconfig && ./configure && make && sudo make install && sudo /usr/sbin/usermod -s /usr/local/bin/zsh $(id -un)

epel:
	grep -q 'release 6' /etc/issue && rpm -Uvh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm; true
	grep -q 'release 5' /etc/issue && rpm -Uvh http://dl.fedoraproject.org/pub/epel/5/x86_64/epel-release-5-4.noarch.rpm; true

apt_proxy:
	echo 'Acquire::ftp::proxy   "ftp://example.com:8080/"  ;' | sudo tee -a /etc/apt/apt.conf
	echo 'Acquire::http::proxy  "http://example.com:8080/" ;' | sudo tee -a /etc/apt/apt.conf
	echo 'Acquire::https::proxy "https://example.com:8080/";' | sudo tee -a /etc/apt/apt.conf

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

emacs24:
	if emacs --version | tee /tmp/zzai | egrep  'GNU Emacs 24'; then :; else wget http://mirror.jre655.com/GNU/emacs/emacs-24.5.tar.gz && tar xvf emacs-24.5.tar.gz && cd emacs-24.5/ && ./configure --without-x && sudo make install && rm -rf emacs-24.5.tar.gz emacs-24.5; fi
	mkdir -p  ~/.lisp
	wget -nc --no-check-certificate -O ~/.lisp/minibuffer-complete-cycle.el https://raw.githubusercontent.com/knu/minibuffer-complete-cycle/master/minibuffer-complete-cycle.el; :
	wget -nc --no-check-certificate -O ~/.lisp/browse-kill-ring.el https://raw.githubusercontent.com/T-J-Teru/browse-kill-ring/master/browse-kill-ring.el; :
	wget -nc --no-check-certificate -O ~/.lisp/redo+.el http://www.emacswiki.org/emacs/download/redo%2b.el; :

clone_https:
	mkdir -p ~/.ssh; chmod 700 ~/.ssh
	git clone https://github.com/ikushin/myenv.git ~/.myenv
	cd ~/.myenv && git config --global push.default simple && make cp
	usermod -s /bin/zsh root

test:
	[ $$OSTYPE != "cygwin" ] && echo cygwin || echo xxx

perl:
	wget http://www.cpan.org/src/5.0/perl-5.22.1.tar.gz
	tar xvf perl-5.22.1.tar.gz
	cd perl-5.22.1
	./Configure -des -Dprefix=/usr/local
	make && make install

autoconf:
	rpm --quiet -q texinfo || sudo yum --disablerepo=updates texinfo
	git clone http://git.sv.gnu.org/r/autoconf.git /tmp/autoconf
	cd /tmp/autoconf
	git checkout 100f26c
	./configure && make && sudo make install
	which autoconf
	autoconf --version
