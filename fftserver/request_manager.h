#ifndef FFT_REQUEST_MANAGER_H
#define FFT_REQUEST_MANAGER_H

// must be called before any other functions
int RequestManagerInit();
int RequestManagerDeinit();

// executes a client's request and creates a response
int ProcessRequest(std::string &clientMessage, std::string &response);

#endif
