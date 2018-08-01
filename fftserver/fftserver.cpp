#include <string>

#include <stdio.h>
#include <unistd.h>
#include "connection_manager.h"

using namespace std;

int main(int argc, char **argv)
{
  if (ParseArguements(argc, argv))
  {
    return -1;
  }

  // initialize connection manager
  // this function initializes the request manager module
  ConnectionManagerInit();

  // run the server
  Run();

  // wait for the STOP command
  WaitForStop();

  // deinitialize
  ConnectionManagerDeinit();

  return 0;
}
