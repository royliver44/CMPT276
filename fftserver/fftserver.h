#ifndef FFTSERVER_H_
#define FFTSERVER_H_

#include <netinet/ip.h>

struct sockaddr;

// initialize and deinitialize module
int FFTServerInit();
int FFTServerDeInit();

// parse main program arguements
void ParseArguements(int argc, char **argv);

// launches the request manager threads
int Run(void);

// block to join the request manager threads
int WaitForStop(void);

// sets flags to stop the request manager threads
void Stop(void);

#endif
