#
SHELL := /bin/bash
GIT_VERSION := $(shell git --version 2>/dev/null )
OS := $(shell python -mplatform)
USER := $(shell echo $(OS)_$$(id -nu) | egrep -qi 'cygwin|root$$' && echo "root" || echo "non_root" )
ifeq ($(USER),root)
	PREFIX := /usr/local
else
	PREFIX := $(HOME)/local
endif

DOTFILES =  zlogin
DOTFILES += zshrc
DOTFILES += inputrc
DOTFILES += screenrc
DOTFILES += vimrc
DOTFILES += zshrc.alias
DOTFILES += zshrc.git
DOTFILES += zshrc.func
DOTFILES += emacs.d

cp:
	for i in $(DOTFILES); do /bin/cp -T -avu $(HOME)/.myenv/$$i $(HOME)/.$$i; done
	[ -e $(HOME)/.zshrc.local ] || /bin/cp -av zshrc.local $(HOME)/.zshrc.local
	install -v -m 700 -d $(HOME)/.ssh
	[ -e $(HOME)/.ssh/config ] || install -v -m 600 ssh_config $(HOME)/.ssh/config
	cmp -s ssh_config_my $(HOME)/.ssh/config_my || cp ssh_config_my $(HOME)/.ssh/config_my
	case $(OS) in \
		CYGWIN* )    /bin/cp -avu zshrc.cygwin  $(HOME)/.zshrc.cygwin   ;;  \
		Linux* )     /bin/cp -avu zshrc.linux   $(HOME)/.zshrc.linux    ;;& \
		*centos-5* | *redhat-5* ) /bin/cp -avu zshrc.centos5 $(HOME)/.zshrc.centos5  ;;  \
		*centos-7* | *redhat-7* ) /bin/cp -avu zshrc.centos7 $(HOME)/.zshrc.centos7  ;;  \
	esac

old:
	-wget -q -nc "https://raw.githubusercontent.com/maskedw/dotfiles/master/.gdbinit" -P $(HOME)

test:
	@echo $${USER}
	@echo $(OS)
	@echo $(PREFIX)
	#@echo $(GIT_VERSION)

.PHONY: cygwin
cygwin:
	mkdir -p ~/bin
	/bin/cp ./scripts/*_archive.sh ~/bin/
	if [[ ! -e /usr/local/bin/perl ]]; then make perl; fi

ssh:
	/bin/cp config ~/.ssh/config && chmod 600 ~/.ssh/config

package:
	-grep -q "Ubuntu" /etc/lsb-release 2>/dev/null; [[ $$? -eq 0 ]] && \
		sudo aptitude install -y \
		git autoconf zsh make gcc ncurses-dev gettext jq ncdu pssh libcurl4-openssl-dev emacs-goodies-el
	-[[ -x /usr/bin/yum ]] && \
		sudo yum --disablerepo=updates install -y \
		zsh make gcc ncurses-devel zlib-devel curl-devel expat-devel gettext-devel openssl-devel autoconf epel-release

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
	$(eval DIR := $(HOME)/local/dstat)
	if [[ -d $(DIR) ]]; then git -C $(DIR) pull;\
	else mkdir -p $(HOME)/local; git clone "https://github.com/dagwieers/dstat.git" $(DIR); fi

PKG=libcurl-devel expat-devel gettext-devel openssl-devel zlib-devel perl-ExtUtils-MakeMaker wget gcc
.PHONY : git
git:
    # gitの最新バージョン取得
	@$(eval V := $(shell curl --max-time 3 -Lsk https://www.kernel.org/pub/software/scm/git/ \
		| grep -Po '(?<=git-)\d+.*?(?=.tar.gz)' | sort -V | tail -n1))

    # 続行判定
	egrep -v $(V) <<<"$(GIT_VERSION)"

    # 前準備
	case $(OS) in \
		CYGWIN* ) [[ ! -e /usr/local/perl/bin/perl ]] && make perl ;; \
		Linux*  ) rpm --quiet -q $(PKG) || yum --disablerepo=updates install -y $(PKG) ;; \
	esac
	/bin/rm -rf $(HOME)/git-*/

    # コンパイル
	wget --no-check-certificate "https://www.kernel.org/pub/software/scm/git/git-$(V).tar.gz" -O $(HOME)/git.tar.gz
	tar zxf $(HOME)/git.tar.gz -C $(HOME)
	export PERL_PATH=$(shell PATH='/usr/local/perl/bin:/usr/bin:bin' type -p perl); cd $(HOME)/git-*; \
		./configure --prefix=${PREFIX}/git-$(V) --without-tcltk && \
		make && make install
	ln -snf ${PREFIX}/git-$(V) ${PREFIX}/git

    # diff-highlight
	make -C $(HOME)/git-*/contrib/diff-highlight
	/bin/mv $(HOME)/git-*/contrib/diff-highlight/diff-highlight ${PREFIX}/git/bin
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
	/bin/rm -rf $(HOME)/git-*/

diff-so-fancy:
	cd /usr/local/share/git-core/contrib && git clone "https://github.com/so-fancy/diff-so-fancy.git" 2>/dev/null
	test -d /cygdrive/c && sed -i '1i #!/usr/local/perl/bin/perl' /usr/local/share/git-core/contrib/diff-so-fancy/libexec/diff-so-fancy.pl || true
	git config --global alias.dsf '!f() { [ -z "$$GIT_PREFIX" ] || cd "$$GIT_PREFIX" && git --no-pager diff -b -w --ignore-blank-lines --ignore-space-at-eol --color "$$@" | /usr/local/share/git-core/contrib/diff-so-fancy/diff-so-fancy; }; f'

openssh:
	SSH_PKG="bash"
	if [ ! -e /etc/issue ]; then true; else if [ `id -u` -eq 0 ]; then true; else false; fi; fi
	/bin/rm -rf /tmp/openssh*
	if ssh -V 2>&1 | /bin/grep -q $(shell curl --max-time 3 -Ls http://www.ftp.ne.jp/OpenBSD/OpenSSH/portable/ | /bin/grep -Po '(?<=openssh-)\d+.*?(?=.tar.gz)' | tail -n1); then false; fi
	/bin/egrep -q 'CentOS' /etc/issue 2>/dev/null  &&  { rpm --quiet -q $(SSH_PKG)  ||  sudo yum --disablerepo=updates install -y $(SSH_PKG); } || true
	wget --no-check-certificate "http://www.ftp.ne.jp/OpenBSD/OpenSSH/portable/$(shell curl -Ls http://www.ftp.ne.jp/OpenBSD/OpenSSH/portable/" | /bin/grep -Po 'openssh-\d+\..*?\.tar\.gz' | tail -n1) -O /tmp/openssh.tar.gz
	tar zxf /tmp/openssh.tar.gz -C /tmp
	{ cd /tmp/openssh-*; ./configure && make && make install; } || true
	/bin/rm -rf /tmp/openssh*

zsh:
	if [ ! -e /etc/issue ]; then true; else if [ `id -u` -eq 0 ]; then true; else false; fi; fi
	/bin/rm -rf /tmp/zsh*
	rpm --quiet -q ncurses-devel || sudo yum -y --disablerepo=updates install ncurses-devel; true
	wget --no-check-certificate "https://sourceforge.net/projects/zsh/files/latest/download?source=files" -O /tmp/zsh.tar.gz
	tar zxf /tmp/zsh.tar.gz -C /tmp
	cd /tmp/zsh-* && ./configure && make && make install
	sed -i 's/^clear/#&/' /etc/*/zlogout 2>/dev/null; true
	/bin/rm -rf /tmp/zsh*
	usermod -s /usr/local/bin/zsh root

user_zsh:
	[ -e /etc/issue ] && sudo /usr/sbin/usermod -s /usr/local/bin/zsh $(shell id -un) || true

epel:
	-grep -q 'release 6' /etc/issue && rpm -Uvh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
	-grep -q 'release 5' /etc/issue && rpm -Uvh http://dl.fedoraproject.org/pub/epel/5/x86_64/epel-release-5-4.noarch.rpm

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
	git config --global http.proxy  "http://example.com:8080"
	git config --global https.proxy "http://example.com:8080"

parallel:
	wget --no-check-certificate "http://ftp.gnu.org/gnu/parallel/parallel-20150422.tar.bz2" -O /tmp/parallel-20150422.tar.bz2
	tar jxf /tmp/parallel-20150422.tar.bz2 -C /tmp
	cd /tmp/parallel-20150422/; ./configure && make && make install

fuck_dpkg:
	sudo aptitude install -y python-pip python2.7-dev && sudo pip install thefuck

ansible:
	sudo aptitude install -y ansible

git_clone:
	echo 'IdentityFile=~/.ssh/ikushin.id_rsa' >.ssh/config
	git clone "git@github.com:ikushin/myenv.git" ~/.myenv
	rm -f ~/.ssh/config ~/Makefile
	cd ~/.myenv && git config --global push.default simple && make cp

.PHONY : emacs
emacs:
    # 最新バージョン取得
	$(eval V := $(shell curl --max-time 3 -Ls https://mirror.jre655.com/GNU/emacs/ | /bin/grep -Po '(?<=emacs-)25\.\d+' | tail -n1))

    # ホストの情報収集
	$(eval T := $(shell echo $${OSTYPE}_$$(id -un)_$$(emacs --version 2>/dev/null | head -n1)))

    # 続行判定
	egrep -v $(V) <<<"$(T)"
	egrep "cygwin|root" <<<"$(T)"
	/bin/rm -rf /tmp/emacs-*
	make _emacs
_emacs:
	make package
	$(eval V := $(shell curl --max-time 3 -Ls https://mirror.jre655.com/GNU/emacs/ | /bin/grep -Po '(?<=emacs-)25\.\d+' | tail -n1))
	wget --no-check-certificate "https://mirror.jre655.com/GNU/emacs/emacs-$(V).tar.gz" -O /tmp/emacs.tar.gz; tar zxf /tmp/emacs.tar.gz -C /tmp
	cd /tmp/emacs-* && ./configure --without-x && LANG=C make && make install
	/bin/rm -rf /tmp/emacs-*
	make emacs_lisp
emacs_lisp:
	mkdir -p ~/.lisp
	-wget -q -nc --no-check-certificate -O ~/.lisp/minibuffer-complete-cycle.el  https://raw.githubusercontent.com/knu/minibuffer-complete-cycle/master/minibuffer-complete-cycle.el
	-wget -q -nc --no-check-certificate -O ~/.lisp/browse-kill-ring.el           https://raw.githubusercontent.com/T-J-Teru/browse-kill-ring/master/browse-kill-ring.el
	-wget -q -nc --no-check-certificate -O ~/.lisp/redo+.el                      http://www.emacswiki.org/emacs/download/redo%2b.el
	-wget -q -nc --no-check-certificate -O ~/.lisp/point-undo.el                 https://www.emacswiki.org/emacs/download/point-undo.el
	-wget -q -nc --no-check-certificate -O ~/.lisp/recentf-ext.el                https://www.emacswiki.org/emacs/download/recentf-ext.el

clone:
	mkdir -p ~/.ssh; chmod 700 ~/.ssh
	git clone "https://github.com/ikushin/myenv.git" ~/.myenv
	cd ~/.myenv && git config --global push.default simple && make cp

perl:
	wget "http://www.cpan.org/src/5.0/perl-5.22.1.tar.gz" -O /tmp/perl.tar.gz && tar zxf /tmp/perl.tar.gz -C /tmp
	cd /tmp/perl-5.22.1 && ./Configure -des -Dprefix=/usr/local/perl && make && make install
	/bin/rm -r /tmp/perl*.gz /tmp/perl-*

autoconf:
	rpm --quiet -q texinfo || sudo yum -y --disablerepo=updates install texinfo
	git clone "http://git.sv.gnu.org/r/autoconf.git" /tmp/autoconf
	cd /tmp/autoconf && git checkout -b 100f26c
	cd /tmp/autoconf && ./configure && make && sudo make install
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

net:
	/usr/bin/cygstart ncpa.cpl

term:
	if /bin/grep -q '^#.*putty_067.exe' /bin/cygterm.cfg; then /bin/sed -i -e '3s/^#T/T/' -e '4s/^T/#T/' /bin/cygterm.cfg; else /bin/sed -i -e '3s/^T/#T/' -e '4s/^#//' /bin/cygterm.cfg; fi

man:
	yum install -y man man-pages man-pages-ja

make:
	@{ echo 'cat <<\EOF | base64 -di | tar zxvf -'; tar zcf - Makefile  | base64 -w120; echo EOF; } | tee /dev/clipboard

email:
	git clone "https://github.com/deanproxy/eMail.git" /tmp/eMail
	git clone "https://github.com/deanproxy/dlib.git" /tmp/eMail/dlib
	cd /tmp/eMail && ./configure && make && make install

email_local:
	git clone "https://github.com/deanproxy/eMail.git" $(HOME)/tmp/eMail
	git clone "https://github.com/deanproxy/dlib.git" $(HOME)/tmp/eMail/dlib
	cd ~/tmp/eMail && ./configure --prefix=$(HOME)/local && make && make install
