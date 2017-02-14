
cp:
	for i in zshrc emacs inputrc screenrc vimrc zshrc.alias zshrc.git zshrc.func  ; do /bin/cp -a ~/.myenv/$$i ~/.$$i; done
	test -d /cygdrive/c && /bin/cp -a zshrc.cygwin ~/.zshrc.cygwin || true
	[ -e ~/.localrc ] || /bin/cp localrc ~/.localrc
	[ -d ~/.ssh ] || mkdir -p ~/.ssh && chmod 700 ~/.ssh
	[ -e ~/.ssh/config ] || /bin/cp ssh_config ~/.ssh/config; chmod 600 ~/.ssh/config
	cmp -s ssh_config_my ~/.ssh/config_my || cp ssh_config_my ~/.ssh/config_my
	uname -a | grep -qi 'ubuntu' && /bin/cp zshrc.ubuntu ~/.zshrc.ubuntu || true

.PHONY: cygwin
cygwin:
	mkdir -p ~/bin
	/bin/cp ./scripts/*_archive.sh ~/bin/
	#if [[ ! -e /usr/local/bin/perl ]]; then make perl; fi

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
	[ -d $$HOME/bin ] && git -C $$HOME/bin/dstat pull || { mkdir -p $$HOME/bin; git clone https://github.com/dagwieers/dstat.git $$HOME/bin/dstat; }

PKG=libcurl-devel expat-devel gettext-devel openssl-devel zlib-devel perl-ExtUtils-MakeMaker
git:
	if [ ! -e /etc/issue ]; then true; else if [ `id -u` -eq 0 ]; then true; else false; fi; fi
	/bin/rm -rf /tmp/git*
	if git --version 2>&1 | grep -q $(shell curl --max-time 3 -Ls https://www.kernel.org/pub/software/scm/git/ | grep -Po '(?<=git-)\d+.*?(?=.tar.gz)' | tail -n1); then false; fi
	egrep -q 'CentOS' /etc/issue 2>/dev/null  &&  { rpm --quiet -q $(PKG)  ||  sudo yum --disablerepo=updates install -y $(PKG); } || true
	egrep -q 'Ubuntu' /etc/issue 2>/dev/null  &&  aptitude install -y gettext autoconf gettext asciidoc libcurl4-openssl-dev || true
	wget --no-check-certificate https://www.kernel.org/pub/software/scm/git/$(shell curl -Ls https://www.kernel.org/pub/software/scm/git/ | grep -Po 'git-\d+\..*?\.tar\.gz' | tail -n1) -O /tmp/git.tar.gz
	tar zxf /tmp/git.tar.gz -C /tmp
	[ ! -e /etc/issue ] && [ ! -e /usr/local/perl/bin/perl ] && make perl || true
	[ ! -e /etc/issue ] && { cd /tmp/git-*; ./configure --without-tcltk && PERL_PATH=/usr/local/perl/bin/perl make && PERL_PATH=/usr/local/perl/bin/perl make install; } || true
	[ -e /etc/issue ]   && { cd /tmp/git-*; ./configure --without-tcltk && make && make install } || true
	/bin/cp -a /tmp/git-*/contrib /usr/local/share/git-core/
	/bin/rm -rf /tmp/git*
	make git_config

git_config:
	git config --global pager.log  '/usr/local/share/git-core/contrib/diff-highlight/diff-highlight | less'
	git config --global pager.show '/usr/local/share/git-core/contrib/diff-highlight/diff-highlight | less'
	git config --global pager.diff '/usr/local/share/git-core/contrib/diff-highlight/diff-highlight | less'
	git config --global diff.compactionHeuristic true
	git config --global user.email "you@example.com"
	git config --global user.name "ikushin"
	git config --global http.sslVerify false
	git config --global core.quotepath false
	git config --global status.showuntrackedfiles all
	make diff-so-fancy

openssh:
	SSH_PKG="bash"
	if [ ! -e /etc/issue ]; then true; else if [ `id -u` -eq 0 ]; then true; else false; fi; fi
	/bin/rm -rf /tmp/openssh*
	if ssh -V 2>&1 | /bin/grep -q $(shell curl --max-time 3 -Ls http://www.ftp.ne.jp/OpenBSD/OpenSSH/portable/ | /bin/grep -Po '(?<=openssh-)\d+.*?(?=.tar.gz)' | tail -n1); then false; fi
	/bin/egrep -q 'CentOS' /etc/issue 2>/dev/null  &&  { rpm --quiet -q $(SSH_PKG)  ||  sudo yum --disablerepo=updates install -y $(SSH_PKG); } || true
	wget --no-check-certificate http://www.ftp.ne.jp/OpenBSD/OpenSSH/portable/$(shell curl -Ls http://www.ftp.ne.jp/OpenBSD/OpenSSH/portable/ | /bin/grep -Po 'openssh-\d+\..*?\.tar\.gz' | tail -n1) -O /tmp/openssh.tar.gz
	tar zxf /tmp/openssh.tar.gz -C /tmp
	{ cd /tmp/openssh-*; ./configure && make && make install; } || true
	/bin/rm -rf /tmp/openssh*

zsh:
	if [ ! -e /etc/issue ]; then true; else if [ `id -u` -eq 0 ]; then true; else false; fi; fi
	/bin/rm -rf /tmp/zsh*
	rpm --quiet -q ncurses-devel || sudo yum -y --disablerepo=updates install ncurses-devel; true
	wget https://sourceforge.net/projects/zsh/files/latest/download?source=files -O /tmp/zsh.tar.gz
	tar zxf /tmp/zsh.tar.gz -C /tmp
	cd /tmp/zsh-* && ./configure && make && make install
	sed -i 's/^clear/#&/' /etc/*/zlogout 2>/dev/null; true
	/bin/rm -rf /tmp/zsh*

user_zsh:
	[ -e /etc/issue ] && sudo /usr/sbin/usermod -s /usr/local/bin/zsh $(shell id -un) || true

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

.PHONY : emacs
emacs:
	if [ ! -e /etc/issue ]; then true; else if [ `id -u` -eq 0 ]; then true; else false; fi; fi
	/bin/rm -rf /tmp/emacs-*
	make emacs_lisp
	if emacs --version 2>&1 | grep -q $(shell curl --max-time 3 -Ls https://mirror.jre655.com/GNU/emacs/ | /bin/grep -Po '(?<=emacs-)24\.\d+' | tail -n1); then false; fi
	wget --no-check-certificate https://mirror.jre655.com/GNU/emacs/$(shell curl --max-time 3 -Ls https://mirror.jre655.com/GNU/emacs/ | /bin/grep -Po 'emacs-24\.\d+\.tar\.gz' | tail -n1) -O /tmp/emacs.tar.gz
	tar zxf /tmp/emacs.tar.gz -C /tmp
	cd /tmp/emacs-* && ./configure --without-x && make && make install
	/bin/rm -rf /tmp/emacs-*

emacs_lisp:
	mkdir -p ~/.lisp
	wget -nc --no-check-certificate -O ~/.lisp/minibuffer-complete-cycle.el https://raw.githubusercontent.com/knu/minibuffer-complete-cycle/master/minibuffer-complete-cycle.el; :
	wget -nc --no-check-certificate -O ~/.lisp/browse-kill-ring.el https://raw.githubusercontent.com/T-J-Teru/browse-kill-ring/master/browse-kill-ring.el; :
	wget -nc --no-check-certificate -O ~/.lisp/redo+.el            http://www.emacswiki.org/emacs/download/redo%2b.el; :
	wget -nc --no-check-certificate -O ~/.lisp/point-undo.el       https://www.emacswiki.org/emacs/download/point-undo.el; :
	wget -nc --no-check-certificate -O ~/.lisp/recentf-ext.el      https://www.emacswiki.org/emacs/download/recentf-ext.el; :

clone_https:
	mkdir -p ~/.ssh; chmod 700 ~/.ssh
	git clone https://github.com/ikushin/myenv.git ~/.myenv
	cd ~/.myenv && git config --global push.default simple && make cp
	usermod -s /bin/zsh root

test:
	sudo id

perl:
	wget http://www.cpan.org/src/5.0/perl-5.22.1.tar.gz -O /tmp/perl.tar.gz && tar zxf /tmp/perl.tar.gz -C /tmp
	cd /tmp/perl-5.22.1 && ./Configure -des -Dprefix=/usr/local/perl && make && make install
	/bin/rm -r /tmp/perl*.gz /tmp/perl-*

autoconf:
	rpm --quiet -q texinfo || sudo yum -y --disablerepo=updates install texinfo
	git clone http://git.sv.gnu.org/r/autoconf.git /tmp/autoconf
	cd /tmp/autoconf && git checkout -b 100f26c
	cd /tmp/autoconf && ./configure && make && sudo make install
	which autoconf
	autoconf --version

coreutils:
	wget http://ftp.jaist.ac.jp/pub/GNU/coreutils/coreutils-8.13.tar.gz
	wget --no-check-certificate http://ftp.jaist.ac.jp/pub/GNU/coreutils/coreutils-8.13.tar.gz -O /tmp/coreutils-8.13.tar.gz
	tar xf /tmp/coreutils-8.13.tar.gz -C /tmp
	cd /tmp/coreutils-8.13/; ./configure && make && make install

xcal:
	sed -i -e 's@msg =.*Encoding::ASCII_8BIT.*@msg = "\\0\\0".force_encoding(Encoding::UTF_16LE) * 1024@' -e '/super msg.tr/d' /usr/share/ruby/2.0.0/win32/registry.rb
	gem install -V --backtrace xcal

dhcp:
	netsh interface ip set address LAN dhcp

static:
	netsh interface ip set address LAN static 10.0.0.1 255.255.255.0

route:
	route add 192.168.0.1 MASK 255.255.255.0 10.0.0.254

net:
	/usr/bin/cygstart ncpa.cpl

term:
	i=f /bin/grep -q '^#.*putty_067.exe' /bin/cygterm.cfg; then /bin/sed -i -e '3s/^#T/T/' -e '4s/^T/#T/' /bin/cygterm.cfg; else /bin/sed -i -e '3s/^T/#T/' -e '4s/^#//' /bin/cygterm.cfg; fi

diff-so-fancy:
	cd /usr/local/share/git-core/contrib && git clone https://github.com/so-fancy/diff-so-fancy.git
	test -d /cygdrive/c && sed -i '1i #!/usr/local/perl/bin/perl' /usr/local/share/git-core/contrib/diff-so-fancy/libexec/diff-so-fancy.pl || true
	git config --global alias.dsf '!f() { [ -z "$$GIT_PREFIX" ] || cd "$$GIT_PREFIX" && git diff -b -w --ignore-blank-lines --ignore-space-at-eol --color "$$@" | /usr/local/share/git-core/contrib/diff-so-fancy/diff-so-fancy | less --tabs=4 -RFX; }; f'
	git config --global color.diff-highlight.oldNormal    "red bold"
	git config --global color.diff-highlight.oldHighlight "red bold 52"
	git config --global color.diff-highlight.newNormal    "green bold"
	git config --global color.diff-highlight.newHighlight "green bold 22"

man:
	yum install -y man man-pages man-pages-ja

