CC_C = g++
CFLAGS = -std=c++11 -g -pthread -I /usr/include/mysql -L/usr/lib/x86_64-linux-gnu -lmysqlclient -lpthread -lz -lm -lrt -ldl -Wall

all: fftserver send

fftserver: fftserver.cpp connection_manager.o request_manager.o
	@echo FFTSERVER
	$(CC_C) -o fftserver fftserver.cpp connection_manager.o request_manager.o $(CFLAGS)

connection_manager.o: connection_manager.cpp connection_manager.h
	@echo CONNECTION MANAGER
	$(CC_C) $(CFLAGS) -c -o connection_manager.o connection_manager.cpp

request_manager.o: request_manager.cpp request_manager.h 
	@echo REQUEST MANAGER
	$(CC_C) $(CFLAGS) -c -o request_manager.o request_manager.cpp

send:
	@echo SEND
	fftscp fftserver
	fftscp fftdb

clean:
	@echo CLEAN
	rm -f *.o fftserver fftdbquery.sql
