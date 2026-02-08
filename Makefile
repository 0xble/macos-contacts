PREFIX ?= /usr/local

install:
	install -m 755 contacts $(PREFIX)/bin/contacts

uninstall:
	rm -f $(PREFIX)/bin/contacts
