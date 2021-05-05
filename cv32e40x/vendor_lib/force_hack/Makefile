LIBDPI=force_hack.so

ifeq ($(IRUN),1)
CC=$(XCELIUM_HOME)/tools.lnx86/cdsgcc/gcc/bin/g++
else
CC=$(QUESTASIM_HOME)/questasim/gcc-7.4.0-linux_x86_64/bin/g++
endif

OBJS=force_hack.o

LDFLAGS=
CFLAGS+=-fPIC

# Uncomment for more debug runtime messages from C
#CFLAGS+=-DDEBUG

LDFLAGS+=-Wl,--export-dynamic -Wl,-Bsymbolic

VPATH+=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

ifeq ($(IRUN),1)
CFLAGS+=-I$(INCISIV_DIR)/tools/include
CFLAGS+=-DDPI_COMPATIBILITY_VERSION_1800v2005
else
CFLAGS+=-I$(QUESTASIM_HOME)/questasim/include
endif

.cpp.o:
	$(CC) -c $(CFLAGS) $< -o $@

$(LIBDPI): $(OBJS)
	$(CC) $(LDFLAGS) -shared $^ -o $@

clean:
	rm -f *.o *.so
