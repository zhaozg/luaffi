CC=cc

FFI_DIR?= ${HOME}/.usr
LUA_DIR?= /usr/local

CFLAGS  = -Wall -O2 -fPIC
LIBS    = -lm
CFLAGS += -I${FFI_DIR}/include
LIBS   += -lffi -L${FFI_DIR}/lib
CFLAGS += -I${LUA_DIR}/include/lua
LIBS   += -llua -L${LUA_DIR}/lib

ffi.so: ffi.o
	$(CC) -shared -o $@ $(LDFLAGS) $< $(LIBS)

clean:
	rm -rf *.so *.o
