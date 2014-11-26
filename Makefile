
DEST=/auto/share/matlab-local/ss

install:
	mkdir -p $(DEST)
	/bin/rm -f $(DEST)/*.m
	cp *.m $(DEST)
