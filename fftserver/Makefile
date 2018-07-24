CC_C = g++
CFLAGS = -g -pthread -I /usr/include/mysql -L/usr/lib/x86_64-linux-gnu -lmysqlclient -lpthread -lz -lm -lrt -ldl -Wall

all: fftserver

fftserver: fftserver.cpp connection_manager.o request_manager.o
	@echo FFTSERVER
	$(CC_C) -o fftserver fftserver.cpp connection_manager.o request_manager.o utils.o $(CFLAGS)

connection_manager.o: connection_manager.cpp connection_manager.h utils.o
	@echo CONNECTION MANAGER
	$(CC_C) $(CFLAGS) -c -o connection_manager.o connection_manager.cpp

request_manager.o: request_manager.cpp request_manager.h utils.o
	@echo REQUEST MANAGER
	$(CC_C) $(CFLAGS) -c -o request_manager.o request_manager.cpp

utils.o: utils.cpp utils.h
	@echo UTILS
	$(CC_C) $(CFLAGS) -c -o utils.o utils.cpp

clean:
	@echo CLEAN
	rm *.o fftserver
