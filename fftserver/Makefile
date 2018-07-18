CC_C = g++
CFLAGS = -g -pthread -Wall

all: main

main: main.cpp fftserver.o
	@echo MAIN
	$(CC_C) $(CFLAGS) -o fftserver main.cpp fftserver.o utils.o

fftserver.o: fftserver.cpp fftserver.h utils.o
	@echo FFTSERVER
	$(CC_C) $(CFLAGS) -c -o fftserver.o fftserver.cpp

utils.o: utils.cpp utils.h
	@echo UTILS
	$(CC_C) $(CFLAGS) -c -o utils.o utils.cpp

clean:
	@echo CLEAN
	rm *.o fftserver
