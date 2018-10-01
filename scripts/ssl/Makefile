
help:
	cat Makefile

clean:
	/bin/rm -rf ./out

crt:
	cat ip.lst | xargs -L1 -P1 ./gen_self_crt.sh

