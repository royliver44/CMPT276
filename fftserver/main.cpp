#include <string>

#include <stdio.h>
#include <unistd.h>
#include "fftserver.h"

using namespace std;

int main(int argc, char **argv)
{
  // initialize
  ParseArguements(argc, argv);
  FFTServerInit();

  // run the server
  Run();

  // wait for the STOP command
  WaitForStop();

  // deinitialize
  FFTServerDeInit();

  return 0;
}
