export LIBS = 
export CFLAGS = -g -Wall -O2
export LFLAGS = 
export CC = powerpc-TiVo-linux-gcc

all: xpldev

xpldev: xpldev.o
	$(CC) -o xpldev $(LIBS) $(LFLAGS) xpldev.o
	@echo -e "Successfully built xpl application.\n"

xpldev.o: xpldev.cc xpldev.h
	$(CC) -c -o xpldev.o $(CFLAGS) $(xPL) xpldev.cc

clean:
	rm -f xpldev *.o
