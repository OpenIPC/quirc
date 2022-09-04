CC ?= $(CC)
AR ?= $(AR)
CXX ?= $(CXX)
LD ?= $(LD)

PREFIX ?= /usr
CFLAGS ?= -O1 -Wall -fPIC
QUIRC_CFLAGS = -Ilib $(CFLAGS)
QUIRC_CXXFLAGS = $(QUIRC_CFLAGS) --std=c++17

LIB_OBJ = \
    lib/decode.o \
    lib/identify.o \
    lib/quirc.o \
    lib/version_db.o

.PHONY: all install uninstall clean

all: libquirc.so qrscan

qrscan: bin/dbgutil.o bin/qrscan.o libquirc.a
	$(CC) -o $@ bin/dbgutil.o bin/qrscan.o libquirc.a $(LDFLAGS) -lm -ljpeg

libquirc.a: $(LIB_OBJ)
	rm -f $@
	$(AR) cr $@ $(LIB_OBJ)
	ranlib $@

.PHONY: libquirc.so

libquirc.so: $(LIB_OBJ)
	$(CC) -shared -o $@ $(LIB_OBJ) $(LDFLAGS) -lm

.c.o:
	$(CC) $(QUIRC_CFLAGS) -o $@ -c $<

.SUFFIXES: .cxx
.cxx.o:
	$(CXX) $(QUIRC_CXXFLAGS) -o $@ -c $<

install: libquirc.a libquirc.so
	install -o root -g root -m 0644 lib/quirc.h $(DESTDIR)$(PREFIX)/include
	install -o root -g root -m 0644 libquirc.a $(DESTDIR)$(PREFIX)/lib
	install -o root -g root -m 0755 libquirc.so $(DESTDIR)$(PREFIX)/lib

uninstall:
	rm -f $(DESTDIR)$(PREFIX)/include/quirc.h
	rm -f $(DESTDIR)$(PREFIX)/lib/libquirc.so
	rm -f $(DESTDIR)$(PREFIX)/lib/libquirc.a

clean:
	rm -f */*.o
	rm -f */*.lo
	rm -f libquirc.a
	rm -f libquirc.so
	rm -f qrscan
