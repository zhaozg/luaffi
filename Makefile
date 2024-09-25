FFI_DIR?= $(shell pwd)/.usr
LUA_DIR?= /usr/local

CFLAGS  = -Wall -O2 -fPIC
LIBS    = -lm
CFLAGS += -I${FFI_DIR}/include
LIBS   += -lffi -L${FFI_DIR}/lib
CFLAGS += -I${LUA_DIR}/include/lua
LIBS   += -llua -L${LUA_DIR}/lib

.PHONY: test clean deps

ffi.so: ffi.o
	$(CC) -shared -o $@ $(LDFLAGS) $< $(LIBS)

test: test.so ffi.so
	lua test.lua

test.so: test.o
	$(CC) -shared -o $@ $<

ffi.o: deps

deps: .usr/lib/libffi.a
	make -C deps/libffi libffi.la install

.usr/lib/libffi.a: deps/libffi/Makefile

deps/libffi/Makefile: deps/libffi/configure
	cd deps/libffi && \
	./configure --disable-docs --disable-shared --prefix=$(FFI_DIR)


deps/libffi/configure:
	cd deps/libffi && ./autogen.sh

clean:
	rm -rf *.so *.o
