/*
fftserver.cpp
Main routine that starts fftserver
Group 6
Jordan Ehrenholz
*/

#include "connection_manager.h"

using namespace std;

int main(int argc, char **argv)
{
  if (ParseArguements(argc, argv)) return -1;
  ConnectionManagerInit();

  // run the server
  Run();

  // wait for the STOP command
  WaitForStop();
  ConnectionManagerDeinit();

  return 0;
}
