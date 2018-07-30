// C++ libraries
#include <iostream>
#include <fstream>
#include <string>
#include <vector>

// C libraries
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/ip.h>
#include <arpa/inet.h>
#include <pthread.h>
#include <unistd.h>

// modules
#include "connection_manager.h"
#include "request_manager.h"

using namespace std;

// static functions
static void* IncomingConnectionsManagerThread(void *param);
static void* SingleConnectionWorkerThread(void* param);
static int NewCallbackThreadID(void);

// NETWORKING VARIABELS
static int receiveBuffSize = 1440;
static const int MAX_CONNECTION_QUEUE_LENGTH = 255;
static struct sockaddr_in RMAddressInfo4;
static int RMsocket_fd = 0;
static int portNum = 33455;


// THREAD MANAGEMENT VARIABLES
struct TCThreadInfo
{
  pthread_t threadID;
  int client_fd;
  struct sockaddr clientAddress;
  std::string fileName;
};
pthread_mutex_t workersMutex;
static pthread_t RMThreadID = 245;
static vector<struct TCThreadInfo*> TCThreads;
static bool isStopRM = false;


// initializes objects used in this module
int ConnectionManagerInit()
{
  cout << "Initializing connection manager" << endl;

  // create socket file descriptors
  RMsocket_fd = socket(AF_INET, SOCK_STREAM, 0);
  if (RMsocket_fd == -1)
  {
    cout << "ERROR getting socket descriptor" << endl;
    return -1;
  }

  int optval = 1;
  int error = setsockopt(RMsocket_fd, SOL_SOCKET, SO_REUSEADDR, (const void*)&optval,
    sizeof(int));
  if (error == -1)
  {
    cout << "ERROR setting socket options" << endl;
    return -1;
  }

  // set address information for the Request Manageer sockets
  RMAddressInfo4.sin_family = AF_INET;
  RMAddressInfo4.sin_port = htons((uint16_t)portNum);
  RMAddressInfo4.sin_addr.s_addr = htonl(INADDR_ANY);

  // bind addresses to the socket file descriptors
  bind(RMsocket_fd, (struct sockaddr*)&RMAddressInfo4, sizeof(RMAddressInfo4));
  if (error != 0)
  {
    cout << "ERROR binding address information to socket" << endl;
    return error;
  }

  // initialize the request manager module
  error = RequestManagerInit();
  if (error)
  {
    cout << "ERROR initializing connection manager" << endl;
    return -1;
  }

  return 0;
}

int ConnectionManagerDeinit()
{
  cout << "Deinitializing connection manager" << endl;

  // wait for all threads to exit and deallocate TCThreadInfo structures
  while(!TCThreads.empty())
  {
    cout << "Waiting for threads to close" << endl;
    sleep(1);
    //RefreshThreads();
  }

  // close sockets
  int error = close(RMsocket_fd);
  if (error != 0)
  {
    cout << "ERROR closing socket" << endl;
    return error;
  }

  // deinitialize the request manager module
  RequestManagerDeinit();

  return 0;
}

// parse main program arguements
int ParseArguements(int argc, char **argv)
{
  cout << "Parsing command line arguements" << endl;

  if (argc != 3)
  {
    cout << "Incorrect number of input arguements" << endl
      << "usage: $ fftserver <IPv4 portNum> <MTU>" << endl;
    return -1;
  }

  // read the user's cmd input arguements
  portNum = atoi(argv[1]);
  receiveBuffSize = atoi(argv[2]);

  return 0;
}

// launches the Request Management threads
// starts fftserver
int Run(void)
{
  cout << "Starting connection manager thread" << endl;

  if (pthread_create(&RMThreadID, NULL, &IncomingConnectionsManagerThread, NULL))
  {
    cout << "ERROR starting connection manager thread" << endl;
    return -1;
  }

  return 0;
}

// wait for the Request Manager threads to join
int WaitForStop(void)
{
  cout << "Waiting for connection manager thread" << endl;

  if (pthread_join(RMThreadID, NULL))
  {
    cout << "ERROR joining connection manager thread" << endl;
  }

  return 0;
}

// sets flags to stop the request manager threads
void Stop(void)
{
  cout << "Setting stop flag for connection manager thread" << endl;
  isStopRM = true;
}

// continuously accepts client connections
static void* IncomingConnectionsManagerThread(void *param)
{
  // listen for incoming connections
  if (listen(RMsocket_fd, MAX_CONNECTION_QUEUE_LENGTH))
  {
    cout << "ERROR trying listening for incoming connections" << endl;
    return NULL;
  }

  socklen_t clientAddressLength;
  struct sockaddr clientAddressFromAccept;
  while(!isStopRM)
  {
    clientAddressLength = sizeof(clientAddressFromAccept);

    // accept the next connection request
    cout << "Connecions manager: Ready for next connection" << endl;
    int acceptClient_fd = accept(RMsocket_fd, (struct sockaddr*)&clientAddressFromAccept,
     &clientAddressLength);
    if (acceptClient_fd == -1)
    {
      cout << "ERROR accepting client connection" << endl;
      return NULL;
    }

    /* allocate memory for new callback thread information structure
    this is the arguement for the tranfer callback thread function
    populate this new memory with info for the new thread */
    struct TCThreadInfo* newCallbackThreadInfo
    = (struct TCThreadInfo*)malloc((size_t)sizeof(struct TCThreadInfo));
    newCallbackThreadInfo->client_fd = acceptClient_fd;
    newCallbackThreadInfo->clientAddress = clientAddressFromAccept;

    pthread_mutex_lock(&workersMutex); // CRITICAL SECTION for obtaining thread IDs
    newCallbackThreadInfo->threadID = NewCallbackThreadID();

    // add new callback thread to the list of callback threads
    TCThreads.push_back(newCallbackThreadInfo);
    pthread_mutex_unlock(&workersMutex);

    // spawn new worker thread to manager the new connection
    cout << endl << "Starting Connection worker thread" << endl;
    if (pthread_create(&newCallbackThreadInfo->threadID, NULL,
      &SingleConnectionWorkerThread, (void*)newCallbackThreadInfo))
    {
      cout << "ERROR creating connection worker thread" << endl;
      return NULL;
    }

    // detach thread to continue accepting requests in the next iteration
    if (pthread_detach(newCallbackThreadInfo->threadID))
    {
      cout << "ERROR detaching connection worker thread" << endl;
    }
  }
  return NULL;
}

// manages a single client connection from request to response before exiting
// thread safe! respond with 1 packet at a time
static void* SingleConnectionWorkerThread(void* param)
{
  // access the parameter passed to this thread
  // parameter is a thread info struct and a
  struct TCThreadInfo* info = (struct TCThreadInfo*)param;
  socklen_t clientAddressLength = sizeof(struct sockaddr);

  // create a receive buffer and read the client's message
  char receiveBuffer[receiveBuffSize];
  memset(receiveBuffer, 0, receiveBuffSize);
  int error = recvfrom(info->client_fd, receiveBuffer, receiveBuffSize, 0,
    (struct sockaddr*)&info->clientAddress, &clientAddressLength);
  if (error < 0)
  {
    cout << "ERROR receiving client message" << endl;
  }

  // print message from client to console
  cout << "receive buffer: ---" << receiveBuffer << "--- (" << error
    << " bytes)" << endl;

  // process the clients message
  // use c++ strings in request manager for simplicity
  string clientMessage(receiveBuffer);
  string response;
  error = ProcessRequest(clientMessage, response);
  const char* sendBuffer = response.c_str();
  if (sendBuffer[0] == 'B')
  {
    cout << "ERROR: SENDING BAD HEADER" << endl;
  }

  // send server response to client
  // WILL NEED SUPPORT FOR MESSAGES LONGER THAN MTU
  cout << "send buffer: ---" << sendBuffer << "---" << endl;
  error = sendto(info->client_fd, sendBuffer, strlen(sendBuffer),
    0, (struct sockaddr*)&info->clientAddress, clientAddressLength);
  if (error < 0)
  {
    cout << "ERROR sending response to client" << endl;
  }

  // exit upon client request
  if (strcmp(receiveBuffer, "STOPSTOPSTOP\n") == 0)
  {
    Stop();
  }

  // close tcp connection with the client
  error = close(info->client_fd);
  if (error)
  {
    cout << "ERROR closing connection" << endl;
  }

  pthread_mutex_lock(&workersMutex); // CRITICAL SECTION for deleting thread info
  // erase entry in thread tracking vector
  for (unsigned int i = 0; i < TCThreads.size(); i++)
  {
    if (TCThreads[i] == info)
    {
      TCThreads.erase(TCThreads.begin() + i);
    }
  }

  // deallocate TCThreadInfo struct for completed thread
  free(info);
  pthread_mutex_unlock(&workersMutex);

  cout << "Worker thread terminating" << endl;

  return NULL;
}

// generates a new thread ID for a new dedicated connection worker thread
// based on previously allocated thread IDs
static int NewCallbackThreadID(void)
{
  // try to allocate identifier i
  for (int i = 0; ; i++)
  {
    // see if i is an available thread_id in TCThreads
    bool isThreadIDAvailable = true;
    for(int j = 0; j < (int)TCThreads.size(); j++)
    {
      // if the id is already being used, keep searching!
      if ((int)TCThreads[j]->threadID == i)
      {
        isThreadIDAvailable = false;
        break;
      }
    }

    // if the id is available, return it so it can be allocated
    if(isThreadIDAvailable)
    {
      return i;
    }
  }

  return -1;
}
