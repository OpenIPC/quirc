CC ?= $(CC)
AR ?= $(AR)

PREFIX ?= /usr
CFLAGS ?= -O1 -Wall -fPIC
QUIRC_CFLAGS = -Ilib $(CFLAGS)

LIB_OBJ = \
    lib/decode.o \
    lib/identify.o \
    lib/quirc.o \
    lib/version_db.o

.PHONY: all install uninstall clean

all: libquirc.a qrscan

qrscan: bin/dbgutil.o bin/qrscan.o libquirc.a
	$(CC) -o $@ bin/dbgutil.o bin/qrscan.o libquirc.a $(LDFLAGS) -lm -ljpeg

libquirc.a: $(LIB_OBJ)
	rm -f $@
	$(AR) cr $@ $(LIB_OBJ)
	ranlib $@

.c.o:
	$(CC) $(QUIRC_CFLAGS) -o $@ -c $<

install: libquirc.a
	install -m 0644 lib/quirc.h $(DESTDIR)$(PREFIX)/include
	install -m 0644 libquirc.a $(DESTDIR)$(PREFIX)/lib
	install -m 0755 qrscan $(DESTDIR)$(PREFIX)/sbin

uninstall:
	rm -f $(DESTDIR)$(PREFIX)/include/quirc.h
	rm -f $(DESTDIR)$(PREFIX)/lib/libquirc.a

clean:
	rm -f */*.o
	rm -f */*.lo
	rm -f libquirc.a
	rm -f qrscan
