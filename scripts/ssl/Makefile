
help:
	cat Makefile

clean:
	/bin/rm -f *.key *.crt

cert:
	cat ip.lst | xargs -L1 -P10 ./gen_self_crt.sh
