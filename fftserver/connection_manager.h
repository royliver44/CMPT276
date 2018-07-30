#ifndef FFT_CONNECTION_MANAGER_H
#define FFT_CONNECTION_MANAGER_H

// initialize and deinitialize module
int ConnectionManagerInit();
int ConnectionManagerDeinit();

// parse main program arguements
int ParseArguements(int argc, char **argv);

// launches the request manager threads
int Run(void);

// block to join the request manager threads
int WaitForStop(void);

// sets flags to stop the request manager threads
void Stop(void);

#endif
