
help:
	cat Makefile

clean:
	/bin/rm -f *.key *.crt *.log

crt:
	cat ip.lst | xargs -L1 -P10 ./gen_self_crt.sh
