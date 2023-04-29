CC=cc

FFI_DIR?= ${HOME}/.usr
LUA_DIR?= /usr/local

CFLAGS  = -Wall -O2 -fPIC
LIBS    = -lm
CFLAGS += -I${FFI_DIR}/include
LIBS   += -lffi -L${FFI_DIR}/lib
CFLAGS += -I${LUA_DIR}/include/lua
LIBS   += -llua -L${LUA_DIR}/lib

.PHONY: test clean

ffi.so: ffi.o
	$(CC) -shared -o $@ $(LDFLAGS) $< $(LIBS)

test: test.so ffi.so
	lua test.lua

test.so: test.o
	$(CC) -shared -o $@ $<

clean:
	rm -rf *.so *.o
