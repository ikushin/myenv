
ssh:
	find . -type l | xargs -r rm -v
	cat ssh.lst | cut -d, -f1 | xargs -r -n1 ln -snfvr ssh.sh
