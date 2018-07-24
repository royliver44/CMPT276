#include <string>
#include <vector>
#include <iostream>

#include <pthread.h>
#include <mysql.h>

#include "request_manager.h"
#include "utils.h"

using namespace std;

// static function declarations
static int GetColumnPairsForRow(string input, vector<string> &objects);
static string ContstructInsertQuery(string table, vector<string> &cells);
static int ExecDB(string queryString);

static MYSQL mysqlObj;
pthread_mutex_t dbmutex;

static const char escapeChar = '\\';
static const char delimChar = ',';


int RequestManagerInit()
{
  cout << "Initializing request manager" << endl;

  // initialize the mysql object
  void* error = mysql_init(&mysqlObj);
  if (!error)
  {
    cout << "ERROR initializing mysql object" << endl
      << mysql_error(&mysqlObj) << endl;
    return -1;
  }

  // connect to the FFT database
  error = mysql_real_connect(&mysqlObj, NULL, "root", "root", "fftdb", NULL, NULL, 0);
  if (!error)
  {
    cout << "ERROR connecting to FFT database" << endl
      << mysql_error(&mysqlObj) << endl;
    return -2;
  }

  return 0;
}

int RequestManagerDeinit()
{
  cout << "Deinitializing request manager" << endl;

  // disconnect from database deallocate the mysql object
  mysql_close(&mysqlObj);

  return 0;
}

// processes a clients message
int ProcessRequest(char* clientMessage_b)
{
  cout << "Processing client request" << endl;

  // save the message header information
  char requestType = clientMessage_b[0];
  char tableType = clientMessage_b[1];
  string clientMessage = clientMessage_b + 2;

  // respond according to the kind of request the client made
  switch (requestType)
  {
    case 'C':
    {
      vector<string> cells;
      GetColumnPairsForRow(clientMessage, cells);

      // Cu<row>0,'username','password','extradata'</row>
      // print the objects found
      for (int i = 0; i < cells.size(); i++)
      {
        cout << cells[i] << endl;
      }
      cout << "TOTAL CELLS: " << cells.size() << endl;

      switch (tableType)
      {
        case 'u':
        {
          //cout << "Create User" << endl;
          // add a row in Users
          string queryString = ContstructInsertQuery("Users", cells);
          ExecDB(queryString);

          break;
        }

        case 'p':
          //cout << "Create Post" << endl;
          // add a row in Posts
          string queryString = ContstructInsertQuery("Posts", cells);
          ExecDB(queryString);

          // add a row in PostsByUser
          break;

        case 'r':
          //cout << "Create Reply" << endl;
          // add a row in Replies
          // add a row in RepliesByUser
          // add a row in RepliesByPost or RepliesByReplies
          break;

        case 'f':
          //cout << "Create Follow" << endl;
          // add a row in FollowersByUser
          break;

        case 's':
          //cout << "Create Share" << endl;
          // add a row in SharesByPost
          break;

        case 'l':
          //cout << "Create Like" << endl;
                // modify Post.likedby, Reply.dislikedby...
          // create a row in LikesByUser
          break;

        default:
          //cout << "Invalid Request" << endl;
          break;
      }
      break;
    }
    case 'G':
    {
      switch (tableType)
      {
        case 'f':
          //cout << "Get page: FEED" << endl;
          break;

        case 'l':
          //cout << "Get page: Latest" << endl;
          break;

        case 'p':
          //cout << "Get page: Popular" << endl;
          break;

        case 'n':
          //cout << "Get page: Near" << endl;
          break;

        case 'm':
          //cout << "Get page: MyPosts" << endl;
          break;

        case 'd':
          //cout << "Get Post Details" << endl;
          break;

        case 'u':
          //cout << "Get User Profile" << endl;
          break;

        default:
          //cout << "Invalid" << endl;
          break;
      }
      break;
    }

    case 'D':
    {
      switch (tableType)
      {
        case 'u':
          //cout << "Delete User" << endl;
          // add a row in Users
          // remove any rows in FollowersByUser
          break;

        case 'p':
          //cout << "Delete Post" << endl;
          // remove a row in Posts
          // remove a row in PostsByUser
          // remove any rows in Replies
          // remove any rows in RepliesByUser
          // remove any rows in RepliesByPost and RepliesByReply
          // remove any rows in SharesByUSer
          break;

        case 'r':
          //cout << "Delete Reply" << endl;
          // remove a row in Replies
          // remove a row in RepliesByUser
          // remove a row in RepliesByPost and RepliesByReplies
          break;

        case 'f':
          //cout << "Delete Follow" << endl;
          // remove a row in FollowersByUser
          break;

        case 's':
          //cout << "Delete Share" << endl;
          // remove a row in SharesByPost
          break;

        case 'l':
          //cout << "Delete Like" << endl;
                // modify Post.likedby, Reply.dislikedby...
          // remove a row in LikesByUser
          break;

        default:
          //cout << "Invalid" << endl;
          break;
      }
    }
    default:
      //cout << "Invalid" << endl;
      break;
  }
  return 0;
}

// gets the column data to insert into the database
static int GetColumnPairsForRow(string message, vector<string> &objects)
{
  cout << message << endl;

  // find the body of the message
  int pos = message.find("<row>");
  if (pos == string::npos)
  {
    cout << "ERROR in message FORMAT: no row open tag" << endl;
    return -1;
  }
  message.erase(0, pos + 5);
  int pos2 = message.find("</row>");
  if (pos2 == string::npos)
  {
    cout << "ERROR in message FORMAT: no row close tag" << endl;
    return -2;
  }
  message.erase(pos2, message.size() - 1);

  // get rid of escape characters
  /* LATER IMPLIMENT
  pos = message.find(escapeChar);
  while(pos < pos2 && pos != string::npos)
  {
    cout << "asdasd" << endl;
    message.erase(message.begin() + pos, message.begin() + pos + 1);
    pos = message.find(escapeChar, pos + 1);
  }*/

  // add objects in the message to the objects vector
  pos = 0;
  pos2 = message.find(delimChar);
  while(pos2 != string::npos)
  {
    objects.push_back(message.substr(pos, pos2 - pos));
    pos = pos2 + 1;
    pos2 = message.find(delimChar, pos);
  }
  objects.push_back(message.substr(pos, message.size() - 1));

  return 0;
}


static string ContstructInsertQuery(string table, vector<string> &cells)
{
  // create the begining of the query before column data
  string retString = "INSERT into " + table + " values(";

  // add the column data
  retString += cells[0];
  cells.erase(cells.begin());
  for (int i = 0; cells.size() != 0; cells.erase(cells.begin()))
  {
    retString += ",";
    retString += cells[0];
  }

  // add the end of the query
  retString += ");";

  cout << retString << endl;

  return retString;
}

// executes a database command in a mutual exclusion
static int ExecDB(string queryString)
{
  cout << queryString << endl;

  // OBTAIN MUTEX LOCK
  pthread_mutex_lock(&dbmutex);

  if (mysql_real_query(&mysqlObj, queryString.c_str(), queryString.size()))
  {
    cout << "ERROR executing database query" << endl
      << mysql_error(&mysqlObj) << endl;
    return -1;
  }

  pthread_mutex_unlock(&dbmutex);

  return 0;
}
