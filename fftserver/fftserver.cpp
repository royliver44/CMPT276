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
#include <arpa/inet.h>
#include <pthread.h>
#include <unistd.h>

// modules
#include "fftserver.h"
#include "utils.h"

using namespace std;

/*##################
STATIC FUNCTIONS
##################*/
// threads that manage connections and start file transfers
static void* RMFunc(void *param);

// transfers data using an existing connection
// will need to be thread safe! send 1 packet at a time
static void* TCFunc(void* param);

// generates a new thread ID for a new tranfer callback thread
static int NewCallbackThreadID(void);

// updates the TCThreads vector with accurate TCThread info
static void RefreshThreads(void);

/*##################
NETWORKING VARIABELS
##################*/
// generic VARIABLES
static int receiveBuffSize = 1440;
static const int MAX_CONNECTION_QUEUE_LENGTH = 255;

// address information and socket file descriptors
static struct sockaddr_in RMAddressInfo4;
static int RMsocket_fd = 0;
static int portNum = 33455;

/* ########################
THREAD MANAGEMENT VARIABLES
#########################*/
struct TCThreadInfo
{
  pthread_t threadID;
  int client_fd;
  struct sockaddr clientAddress;
  std::string fileName;
  bool isComplete;
};

// thread IDs
static pthread_t RMThreadID = 245;

// holds Transfer Callback thread IDs
static vector<struct TCThreadInfo*> TCThreads;

// bool that stops the Request Management threads
static bool isStopRM = false;


// initializes objects used in this module
int FFTServerInit()
{
  DPrint("Initializing FFTServer");

  // create socket file descriptors
  RMsocket_fd = socket(AF_INET, SOCK_STREAM, 0);
  int optval = 1;
  setsockopt(RMsocket_fd, SOL_SOCKET, SO_REUSEADDR, (const void*)&optval,
    sizeof(int));

  // set address information for the Request Manageer sockets
  RMAddressInfo4.sin_family = AF_INET;
  RMAddressInfo4.sin_port = htons((uint16_t)portNum);
  RMAddressInfo4.sin_addr.s_addr = htonl(INADDR_ANY);

  // bind addresses to the socket file descriptors
  int error = bind(RMsocket_fd, (struct sockaddr*)&RMAddressInfo4, sizeof(RMAddressInfo4));
  if (error != 0)
  {
    DPrint("ERROR binding socket");
    return error;
  }

  return 0;
}

int FFTServerDeInit()
{
  DPrint("Deinitializing FFTServer");

  // wait for all threads to exit and deallocate TCThreadInfo structures
  while(!TCThreads.empty())
  {
    DPrint("Waiting for threads to close");
    sleep(1);
    RefreshThreads();
  }

  // close sockets
  int error = close(RMsocket_fd);
  if (error != 0)
  {
    DPrint("ERROR closing socket");
    return error;
  }

  return 0;
}

// parse main program arguements
void ParseArguements(int argc, char **argv)
{
  DPrint("Parsing Arguements");

  // read the user'sprogram input arguements
  portNum = atoi(argv[1]);
  receiveBuffSize = atoi(argv[2]);
}

// launches the Request Management threads
// starts FFTServer
int Run(void)
{
  DPrint("Starting FFTServer");
  int error = pthread_create(&RMThreadID, NULL, &RMFunc, NULL);
  if (error)
  {
    DPrint("ERROR starting RM threads");
  }
  return 0;
}

// wait for the Request Manager threads to join
int WaitForStop(void)
{
  DPrint("Waiting for STOP command");
  pthread_join(RMThreadID, NULL);
  DPrint("FFTServer stopped");
  return 0;
}

// sets flags to stop the request manager threads
void Stop(void)
{
  DPrint("Stopping FFTServer");
  isStopRM = true;
}

// Threads that manage connection requests and start File Transfers
static void* RMFunc(void *param)
{
  // listen for incoming connections
  int error = listen(RMsocket_fd, MAX_CONNECTION_QUEUE_LENGTH);

  socklen_t clientAddressLength;
  struct sockaddr clientAddressFromAccept;
  while(!isStopRM)
  {
    clientAddressLength = sizeof(clientAddressFromAccept);

    // accept the next connection request
    DPrint("waiting to accept a connection...");
    int acceptClient_fd = accept(RMsocket_fd, (struct sockaddr*)&clientAddressFromAccept,
     &clientAddressLength);
    cout << "accept returned client_fd = " << error << endl;

    /* allocate memory for new callback thread information structure
    this is the arguement for the tranfer callback thread function
    populate this new memory with info for the new thread */
    struct TCThreadInfo* newCallbackThreadInfo
    = (struct TCThreadInfo*)malloc((size_t)sizeof(struct TCThreadInfo));
    newCallbackThreadInfo->threadID = NewCallbackThreadID();
    newCallbackThreadInfo->client_fd = acceptClient_fd;
    newCallbackThreadInfo->clientAddress = clientAddressFromAccept;
    newCallbackThreadInfo->isComplete = false;

    // add new callback thread to the list of callback threads
    TCThreads.push_back(newCallbackThreadInfo);

    // spawn new transfer callback thread
    pthread_create(&newCallbackThreadInfo->threadID, NULL,
      &TCFunc, (void*)newCallbackThreadInfo);

    // detach thread to continue accepting requests in the next iteration
    pthread_detach(newCallbackThreadInfo->threadID);
  }
  return NULL;
}

// transfers data using an existing connection
// thread safe! send 1 packet at a time
static void* TCFunc(void* param)
{
  DPrint("\tTC: Starting Transfer Callback");

  // make the parameters to this function accessible
  struct TCThreadInfo* info = (struct TCThreadInfo*)param;
  socklen_t clientAddressLength = sizeof(struct sockaddr);

  // create a receive buffer and read message the client request
  char receiveBuffer[receiveBuffSize];
  memset(receiveBuffer, 0, receiveBuffSize);
  int error = recvfrom(info->client_fd, receiveBuffer, receiveBuffSize, 0,
    (struct sockaddr*)&info->clientAddress, &clientAddressLength);
  cout << "\tTC: recv bytes = " << error << endl;

  //echo what was received to back to the client
  error = sendto(info->client_fd, receiveBuffer, strlen(receiveBuffer),
    0, (struct sockaddr*)&info->clientAddress, clientAddressLength);

  // print message from host
  cout << "\tTC: receive buffer:" << endl << "\t-";
  for (int i = 0; i < receiveBuffSize; i++)
  {
    cout << receiveBuffer[i];
  }
  cout << "\t-" << endl;

  switch (receiveBuffer[0])
  {
    case 'C':
      switch (receiveBuffer[1])
        case 'u':
          //cout << "Create User" << endl;
          // add a row in Users

          break;

        case 'p'
          //cout << "Create Post" << endl;
          // add a row in Posts

          // add a row in PostsByUser

          break;

        case 'r'
          //cout << "Create Reply" << endl;
          // add a row in Replies

          // add a row in RepliesByUser

          // add a row in RepliesByPost or RepliesByReplies

          break;

        case 'f':
          //cout << "Create Follow" << endl;
          // add a row in FollowersByUser

          break;

        case 's'
          //cout << "Create Share" << endl;
          // add a row in SharesByUser

          break;

        case 'l'
          //cout << "Create Like" << endl;
          // modify Post.likedby, Reply.dislikedby...

          break;

        default:
          //cout << "Invalid Request" << endl;
          break;
      break;

    case 'G':
      switch (receiveBuffer[1])
        case 'f':
          //cout << "Get page: FEED" << endl;
          break;

        case 'l'
          //cout << "Get page: Latest" << endl;
          break;

        case 'p'
          //cout << "Get page: Popular" << endl;
          break;

        case 'n':
          //cout << "Get page: Near" << endl;
          break;

        case 'm'
          //cout << "Get page: MyPosts" << endl;
          break;

        case 'd'
          //cout << "Get Post Details" << endl;
          break;

        case 'u':
          //cout << "Get User Profile" << endl;
          break;

        default:
          //cout << "Invalid Request" << endl;
          break;
      break;

    case 'D':
      switch (receiveBuffer[1])
        case 'u':
          //cout << "Delete User" << endl;
          // add a row in Users

          // remove any rows in FollowersByUser

          break;

        case 'p'
          //cout << "Delete Post" << endl;
          // remove a row in Posts

          // remove a row in PostsByUser

          // remove any rows in Replies

          // remove any rows in RepliesByUser

          // remove any rows in RepliesByPost and RepliesByReply

          // remove any rows in SharesByUSer

          break;

        case 'r'
          //cout << "Delete Reply" << endl;
          // remove a row in Replies

          // remove a row in RepliesByUser

          // remove a row in RepliesByPost and RepliesByReplies

          break;

        case 'f':
          //cout << "Delete Follow" << endl;
          // remove a row in FollowersByUser

          break;

        case 's'
          //cout << "Delete Share" << endl;
          // remove a row in SharesByPost

          break;

        case 'l'
          //cout << "Delete Like" << endl;
          // modify Post.likedby, Reply.dislikedby...

          break;

        default:
          //cout << "Invalid Request" << endl;
          break;
      break;
  }

  // exit upon client request
  if (strcmp(receiveBuffer, "STOPSTOPSTOP\n") == 0)
  {
    Stop();
  }

  // close tcp connection with the client
  error = close(info->client_fd);

  // flag this thread as complete and exit
  info->isComplete = true;
  DPrint("\tTC: Transfer Callback Complete");

  return NULL;
}

// generates a new thread ID for a new Tranfer Callback thread
// based on previously allocated Transfer Callback thread IDs
static int NewCallbackThreadID(void)
{
  // stop monitoring threads that hoave completed
  RefreshThreads();

  // allocate a new thread id
  for (int i = 0; ; i++)
  {
    // see if the current index i is an available thread_id
    bool isThreadIDAvailable = true;
    for(int j = 0; j < (int)TCThreads.size(); j++)
    {
      if ((int)TCThreads[j]->threadID == i)
      {
        isThreadIDAvailable = false;
        break;
      }
    }

    if(isThreadIDAvailable)
    {
      // thread_id i is not in use!
      return i;
    }
  }

  return -1;
}

// updates the TCThreads vector with accurate TCThread info
static void RefreshThreads(void)
{
  // stop monitoring threads that have completed
  for(int i = 0; i < (int)TCThreads.size(); i++)
  {
    if (TCThreads[i]->isComplete)
    {
      DPrint("Removing old thread info struct");

      // deallocate TCThreadInfo struct for completed thread
      free(TCThreads[i]);

      // erase entry in TCThreads vector
      TCThreads.erase(TCThreads.begin() + i);
      i--;
    }
  }
}
