#ifndef FFT_REQUEST_MANAGER_H
#define FFT_REQUEST_MANAGER_H

// must be called before any other functions
int RequestManagerInit();
int RequestManagerDeinit();

// parses through a clients message and executes a database command
int ProcessRequest(char* clientMessage);

#endif
