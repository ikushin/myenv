#
SHELL := /bin/bash
OS := $(shell python -mplatform)
USER := $(shell echo $(OS)_$$(id -nu) | egrep -qi 'cygwin|root$$' && echo "root" || echo "non_root" )
ifeq ($(USER),root)
	PREFIX := /usr/local
else
	PREFIX := $(HOME)/local
endif

.PHONY: cygwin git emacs

DOTFILES = zlogin zshrc inputrc screenrc vimrc zshrc.alias zshrc.git zshrc.func emacs.d
cp:
	for i in $(DOTFILES); do /bin/cp -T -avu $(HOME)/.myenv/$$i $(HOME)/.$$i; done
	/bin/cp -avn zshrc.local $(HOME)/.zshrc.local
	[[ -e $(HOME)/.ssh ]]        || install -v -m 700 -d $(HOME)/.ssh
	[[ -e $(HOME)/.ssh/config ]] || install -v -m 600 ssh_config $(HOME)/.ssh/config
	case $(OS) in \
		CYGWIN* )    /bin/cp -avu zshrc.cygwin  $(HOME)/.zshrc.cygwin   ;;  \
		Linux* )     /bin/cp -avu zshrc.linux   $(HOME)/.zshrc.linux    ;;& \
		*centos-5* | *redhat-5* ) /bin/cp -avu zshrc.centos5 $(HOME)/.zshrc.centos5 ;; \
		*centos-7* | *redhat-7* ) /bin/cp -avu zshrc.centos7 $(HOME)/.zshrc.centos7 ;; \
	esac

PKG =  wget zsh make gcc  autoconf epel-release perl-ExtUtils-MakeMaker
PKG += libbsd-devel libcurl-devel expat-devel gettext-devel openssl-devel zlib-devel ncurses-devel
install_package:
	@-case $(OS) in \
		CYGWIN* ) [[ ! -e /usr/local/perl/bin/perl ]] && make perl ;; \
		Linux*  ) rpm --quiet -q $(PKG) || yum --disablerepo=updates install -y $(PKG) ;; \
	esac

DSTAT_D := $(HOME)/local/dstat
dstat:
	if [[ -d $(DSTAT_D) ]]; then \
		git -C $(DSTAT_D) pull; \
	else \
		mkdir -p $(HOME)/local; \
		git clone "https://github.com/dagwieers/dstat.git" $(DSTAT_D); \
	fi

curl:
    # 最新バージョン取得
	@$(eval V := $(shell curl --max-time 10 -Lsk https://curl.haxx.se/download/ | \
		grep -Po 'curl-\d+\.\d+\.\d+.tar.gz' | sort -V | tail -n1))

    # 前準備
	make install_package
	/bin/rm -rf $(HOME)/$@*

    # コンパイル
	wget --no-check-certificate "https://curl.haxx.se/download/$(V)" -O $(HOME)/$@.tar.gz
	tar xf $(HOME)/$@.tar.gz -C $(HOME)
	cd $(HOME)/$@-*; ./configure --prefix=${PREFIX}/$@ && make && make install
	/bin/rm -rf $(HOME)/$@*

perl:
    # 最新バージョン取得
	$(eval V := $(shell curl --max-time 10 -Ls http://www.cpan.org/src/5.0/ | \
		grep -Po '(?<=perl-)5\.26\.\d+(?=\.tar\.gz)' | sort -V | tail -n1))

    # コンパイル
	/bin/rm -rf $(HOME)/$@*
	wget --no-check-certificate "http://www.cpan.org/src/5.0/perl-$(V).tar.gz" -O $(HOME)/$@.tar.gz
	tar xf $(HOME)/$@.tar.gz -C $(HOME)
	cd $(HOME)/$@-*; ./Configure -des -Dprefix=${PREFIX}/perl-$(V) && make && make install
	ln -snf ${PREFIX}/$@-$(V) ${PREFIX}/$@
	/bin/rm -rf $(HOME)/$@*

GIT_VERSION := $(shell git --version 2>/dev/null )
git:
	export PERL_PATH=$(shell PATH='/usr/local/perl/bin:/usr/bin:bin' type -p perl)

    # gitの最新バージョン取得
	@$(eval V := $(shell curl --max-time 10 -Lsk https://www.kernel.org/pub/software/scm/git/ | \
		grep -Po '(?<=git-)\d+.*?(?=.tar.gz)' | sort -V | tail -n1))

    # 続行判定
	egrep -v $(V) <<<"$(GIT_VERSION)"

    # 前準備
	make install_package
	/bin/rm -rf $(HOME)/$@*

    # コンパイル
	wget --no-check-certificate "https://www.kernel.org/pub/software/scm/git/git-$(V).tar.gz" -O $(HOME)/$@.tar.gz
	tar xf $(HOME)/$@.tar.gz -C $(HOME)
	cd $(HOME)/$@-*; ./configure --prefix=${PREFIX}/$@-$(V) --with-curl=$(HOME)/local/curl/ --without-tcltk | \
		tee configure.log
	grep --color=always 'supports SSL... yes' $(HOME)/$@-*/configure.log
	cd $(HOME)/$@-*; make && make install
	ln -snf ${PREFIX}/$@-$(V) ${PREFIX}/$@

    # diff-highlight
	make -C $(HOME)/git-*/contrib/diff-highlight
	/bin/mv $(HOME)/git-*/contrib/diff-highlight/diff-highlight ${PREFIX}/$@/bin
	git config --global pager.log  'diff-highlight | less'
	git config --global pager.show 'diff-highlight | less'
	git config --global pager.diff 'diff-highlight | less'
	git config --global diff.compactionHeuristic true
	git config --global color.diff-highlight.oldNormal    "red   bold"
	git config --global color.diff-highlight.oldHighlight "red   bold 52"
	git config --global color.diff-highlight.newNormal    "green bold"
	git config --global color.diff-highlight.newHighlight "green bold 22"

    # Config
	git config --global user.email "you@example.com"
	git config --global user.name "ikushin"
	git config --global http.sslVerify false
	git config --global core.quotepath false
	git config --global status.showuntrackedfiles all

    # Clean up
	/bin/rm -rf $(HOME)/$@*

metastore:
	case $(OS) in Linux*  ) \
		git clone https://github.com/przemoc/metastore.git $(HOME)/$@; \
		cd $(HOME)/$@ && make && make install PREFIX=${PREFIX}/$@; \
		rm -rf $(HOME)/$@ ;; \
	esac

zsh:
	/bin/rm -rf $(HOME)/$@*
	make install_package
	wget --no-check-certificate "https://sourceforge.net/projects/zsh/files/latest/download?source=files" -O $(HOME)/$@.tar.gz
	tar xf $(HOME)/$@.tar.gz -C $(HOME)
	cd $(HOME)/$@-* && ./configure --prefix=${PREFIX}/$@ && make && make install
	/bin/rm -rf $(HOME)/$@*

EMACS_VERSION := $(shell emacs --version 2>/dev/null | head -1 )
emacs:
    # 最新バージョン取得
	$(eval V := $(shell curl --max-time 10 -Ls http://ftp.jaist.ac.jp/pub/GNU/emacs/ | \
		/bin/grep -Po '(?<=emacs-)\d+\.\d+' | tail -n1))

    # 続行判定
	egrep -v $(V) <<<"$(EMACS_VERSION)"

    # 前準備
	make install_package
	/bin/rm -rf $(HOME)/$@*

    # コンパイル
	wget --no-check-certificate "http://ftp.jaist.ac.jp/pub/GNU/emacs/emacs-$(V).tar.gz" -O $(HOME)/$@.tar.gz
	tar xf $(HOME)/$@.tar.gz -C $(HOME)
	cd $(HOME)/$@-* && ./configure --prefix=${PREFIX}/$@-$(V) --without-x && LANG=C make && make install
	/bin/rm -rf $(HOME)/$@*
	ln -snf ${PREFIX}/$@-$(V) ${PREFIX}/$@

m:
	@{ echo ' cat <<\EOF | base64 -di | tar zxvf -'; tar zcf - Makefile  | base64 ; echo EOF; } | tee /dev/clipboard

term:
	if /bin/grep -q '^#.*putty_067.exe' /bin/cygterm.cfg; then \
		/bin/sed -i -e '3s/^#T/T/' -e '4s/^T/#T/' /bin/cygterm.cfg; \
	else \
		/bin/sed -i -e '3s/^T/#T/' -e '4s/^#//' /bin/cygterm.cfg; \
	fi

sudo:
	[[ -n "$(user)" ]]
	echo 'Defaults:$(user)    !requiretty'     > /etc/sudoers.d/$(user)
	echo '$(user)	ALL=(root)	NOPASSWD: ALL' >>/etc/sudoers.d/$(user)
	chmod 0440 /etc/sudoers.d/$(user)

cygwin:
	mkdir -p $(HOME)/local/cygwin
	/bin/cp -avu ./scripts/*_archive.sh $(HOME)/local/cygwin
	[[ ! -e /usr/local/bin/perl ]] || make perl

emacs_lisp:
	mkdir -p ~/.lisp
	-wget -q -nc --no-check-certificate -O ~/.lisp/minibuffer-complete-cycle.el  https://raw.githubusercontent.com/knu/minibuffer-complete-cycle/master/minibuffer-complete-cycle.el
	-wget -q -nc --no-check-certificate -O ~/.lisp/browse-kill-ring.el           https://raw.githubusercontent.com/T-J-Teru/browse-kill-ring/master/browse-kill-ring.el
	-wget -q -nc --no-check-certificate -O ~/.lisp/redo+.el                      http://www.emacswiki.org/emacs/download/redo%2b.el
	-wget -q -nc --no-check-certificate -O ~/.lisp/point-undo.el                 https://www.emacswiki.org/emacs/download/point-undo.el
	-wget -q -nc --no-check-certificate -O ~/.lisp/recentf-ext.el                https://www.emacswiki.org/emacs/download/recentf-ext.el

win_net:
	/usr/bin/cygstart ncpa.cpl

win_proxy:
	/usr/bin/cygstart control.exe inetcpl.cpl,,4

old:
	-wget -q -nc "https://raw.githubusercontent.com/maskedw/dotfiles/master/.gdbinit" -P $(HOME)

test:
	echo $(user)
	# @echo $${USER}
	# @echo $(OS)
	# @echo $(PREFIX)
	# @echo $(GIT_VERSION)


ssh:
	/bin/cp config ~/.ssh/config && chmod 600 ~/.ssh/config

apt_conf:
	/bin/sed -ri.org 's@http://[^ ]+ubuntu@http://ftp.jaist.ac.jp/ubuntu@' /etc/apt/sources.list
	apt-get update && apt-get -y upgrade

date:
	ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

diff-so-fancy:
	cd /usr/local/share/git-core/contrib && git clone "https://github.com/so-fancy/diff-so-fancy.git" 2>/dev/null
	test -d /cygdrive/c && sed -i '1i #!/usr/local/perl/bin/perl' /usr/local/share/git-core/contrib/diff-so-fancy/libexec/diff-so-fancy.pl || true
	git config --global alias.dsf '!f() { [ -z "$$GIT_PREFIX" ] || cd "$$GIT_PREFIX" && git --no-pager diff -b -w --ignore-blank-lines --ignore-space-at-eol --color "$$@" | /usr/local/share/git-core/contrib/diff-so-fancy/diff-so-fancy; }; f'

openssh:
	SSH_PKG="bash"
	if [ ! -e /etc/issue ]; then true; else if [ `id -u` -eq 0 ]; then true; else false; fi; fi
	/bin/rm -rf /tmp/openssh*
	if ssh -V 2>&1 | /bin/grep -q $(shell curl --max-time 10 -Ls http://www.ftp.ne.jp/OpenBSD/OpenSSH/portable/ | /bin/grep -Po '(?<=openssh-)\d+.*?(?=.tar.gz)' | tail -n1); then false; fi
	/bin/egrep -q 'CentOS' /etc/issue 2>/dev/null  &&  { rpm --quiet -q $(SSH_PKG)  ||  yum --disablerepo=updates install -y $(SSH_PKG); } || true
	wget --no-check-certificate "http://www.ftp.ne.jp/OpenBSD/OpenSSH/portable/$(shell curl -Ls http://www.ftp.ne.jp/OpenBSD/OpenSSH/portable/" | /bin/grep -Po 'openssh-\d+\..*?\.tar\.gz' | tail -n1) -O /tmp/openssh.tar.gz
	tar xf /tmp/openssh.tar.gz -C /tmp
	{ cd /tmp/openssh-*; ./configure && make && make install; } || true
	/bin/rm -rf /tmp/openssh*

user_zsh:
	[ -e /etc/issue ] && /usr/sbin/usermod -s /usr/local/bin/zsh $(shell id -un) || true

epel:
	-grep -q 'release 6' /etc/issue && rpm -Uvh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
	-grep -q 'release 5' /etc/issue && rpm -Uvh http://dl.fedoraproject.org/pub/epel/5/x86_64/epel-release-5-4.noarch.rpm

apt_proxy:
	echo 'Acquire::ftp::proxy   "ftp://example.com:8080/"  ;' | tee -a /etc/apt/apt.conf
	echo 'Acquire::http::proxy  "http://example.com:8080/" ;' | tee -a /etc/apt/apt.conf
	echo 'Acquire::https::proxy "https://example.com:8080/";' | tee -a /etc/apt/apt.conf

wget_proxy:
	echo 'http_proxy = http://example.com:8080/' >>/etc/wgetrc
	echo 'https_proxy = https://example.com:8080/' >>/etc/wgetrc

yum_proxy:
	echo 'proxy=http://example.com:8080/' >>/etc/yum.conf

git_proxy:
	git config --global http.proxy  "http://example.com:8080"
	git config --global https.proxy "http://example.com:8080"

parallel:
	wget --no-check-certificate "http://ftp.gnu.org/gnu/parallel/parallel-20150422.tar.bz2" -O /tmp/parallel-20150422.tar.bz2
	tar jxf /tmp/parallel-20150422.tar.bz2 -C /tmp
	cd /tmp/parallel-20150422/; ./configure && make && make install

fuck_dpkg:
	aptitude install -y python-pip python2.7-dev && pip install thefuck

ansible:
	aptitude install -y ansible

git_clone:
	echo 'IdentityFile=~/.ssh/ikushin.id_rsa' >.ssh/config
	git clone "git@github.com:ikushin/myenv.git" ~/.myenv
	rm -f ~/.ssh/config ~/Makefile
	cd ~/.myenv && git config --global push.default simple && make cp

clone:
	mkdir -p ~/.ssh; chmod 700 ~/.ssh
	git clone "https://github.com/ikushin/myenv.git" ~/.myenv
	cd ~/.myenv && git config --global push.default simple && make cp


autoconf:
	rpm --quiet -q texinfo || yum -y --disablerepo=updates install texinfo
	git clone "http://git.sv.gnu.org/r/autoconf.git" /tmp/autoconf
	cd /tmp/autoconf && git checkout -b 100f26c
	cd /tmp/autoconf && ./configure && make && make install
	which autoconf
	autoconf --version

coreutils:
	wget --no-check-certificate "http://ftp.jaist.ac.jp/pub/GNU/coreutils/coreutils-8.13.tar.gz" -O /tmp/coreutils-8.13.tar.gz
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

man:
	yum install -y man man-pages man-pages-ja

email:
	rm -rf $(HOME)/eMail
	git clone "https://github.com/deanproxy/eMail.git" $(HOME)/eMail
	git clone "https://github.com/deanproxy/dlib.git"  $(HOME)/eMail/dlib
	cd $(HOME)/eMail && ./configure --prefix=$(PREFIX)/eMail && make && make install
	rm -rf $(HOME)/eMail
