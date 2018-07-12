#include <iostream>
#include <string>
#include "utils.h"

using namespace std;

void DPrint(string message)
{
  if (DEBUG_LEVEL > 0)
  {
    cout << message << endl;
  }
}


void DPrint(int success, int error, std::string message)
{
  if (error != success && DEBUG_LEVEL > 0)
  {
    cout << message << endl;
  }
}
