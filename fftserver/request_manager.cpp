#include <string>
#include <vector>
#include <iostream>

#include <stdio.h>
#include <string.h>
#include <pthread.h>
#include <mysql.h>

#include "request_manager.h"

using namespace std;

// Request Handlers
static int HandleCreateRequest(string &clientMessage, string &response);
static int HandleDeleteRequest(string &clientMessage);
static int HandleGetRequest(string &clientMessage, string &response);
static int HandleAccountRequest(string &clientMessage, string &response);

// Critical Subroutines
static int ChangeUserRep(string &userid, int amount);
static int ExecDB(string queryString);
static int PackagePosts(string &response, string &userid, MYSQL_RES *postsQueryResult);
static int PackagePosts(string &response, string &userid, MYSQL_RES *postsQueryResult);
static int GenerateTicket(string userid);
static int GetAuthorIDOfPost(string &authorid, string postid);
static int AuthenticateUser(string& userid);

// Helper Functions
static int GetClientData(string &clientMessage, vector<string> &clientData);
static int ConstructInsertQuery(string &queryString, string tableName, vector<string> &clientData);

static MYSQL mysqlObj;
static pthread_mutex_t dbmutex;

static const int BAD_REQ = -1;
static const int BAD_AUTH = -2;

static const char escapeChar = '\\';
static const char delimChar = ',';
static const char objectDelimChar = '~';
static const char listDelimChar = '^';
static const char ticketDelimChar = '-';
static char successHeader[] = "G";
static char failHeader[] = "B";

static const int likeRep = 1;
static const int postRep = 3;
static const int followRep = 5;

/* #######################
EXTERNALLY LINKED FUNCTIONS
######################## */

// must be called before any other functions in this module
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
  error = mysql_real_connect(&mysqlObj, NULL, "root", "root", "fftdb", 0, NULL, 0);
  if (!error)
  {
    cout << "ERROR connecting to FFT database" << endl
      << mysql_error(&mysqlObj) << endl;
    return -2;
  }

  // initialize random number generator
  time_t t;
  srand((unsigned) time(&t));

  return 0;
}

int RequestManagerDeinit()
{
  cout << "Deinitializing request manager" << endl;

  // disconnect from database deallocate the mysql object
  mysql_close(&mysqlObj);

  return 0;
}

// processes a clients message header
// processes the type of message and adds succes or fail status to the response body
// accepts references to a message received and a message to respond with
// returns zero on success
int ProcessRequest(string &clientMessage, string &response)
{
  int error;

	// look at first character of the message, either C, G or D
	switch (clientMessage[0])
	{
  	case 'C':
    {
  		error = HandleCreateRequest(clientMessage, response);
  		if (error)
      {
        response = failHeader;
        return error;
      }
      else
      {
        response.insert(0, successHeader);
        return 0;
      }
    }
    case 'D':
    {
  		error = HandleDeleteRequest(clientMessage);
  		if (error)
      {
        response = failHeader;
        return error;
      }
      else
      {
        // there are no reponses with body text for any delete requests
        response = successHeader;
        return 0;
      }
    }
  	case 'G':
    {
  		error = HandleGetRequest(clientMessage, response);
  		if (error)
      {
        response = failHeader;
        return error;
      }
      else
  		{
        response.insert(0, successHeader);
        return 0;
      }
    }
    case 'U':
    {
  		error = HandleAccountRequest(clientMessage, response);
  		if (error)
      {
        response = failHeader;
        return error;
      }
      else
  		{
        response.insert(0, successHeader);
        return 0;
      }
    }
    default:
    {
      cout << "ERROR: Unrecognized client message header" << endl;
      response = failHeader;
      return -1;
    }
	}
}

/* #######################
REQUEST HANDLING FUNCTIONS
######################## */

// handles create messages
// tries to insert data into the database
static int HandleCreateRequest(string &clientMessage, string &response)
{
  int error = 0;
	switch(clientMessage[1])
	{
    case 'U':
    {
  		// get username, password
      clientMessage.erase(0, 2);
      vector<string> clientData;
      if (GetClientData(clientMessage, clientData)) return BAD_REQ;

  		// INSERT into users (generate userid)
      string queryString;
      if (ConstructInsertQuery(queryString, "Users", clientData)) return BAD_REQ;
      if (ExecDB(queryString)) return BAD_REQ;

      // send back the new user's ID and a new ticket
      int userid_int = mysql_insert_id(&mysqlObj);
      if (!userid_int) return BAD_REQ;
      string userid = to_string(userid_int);
      int ticket = GenerateTicket(userid);
      if (ticket < 0) return BAD_REQ;
      response += userid;
      response += ",";
      response += to_string(ticket);

  		return error;
    }
  	case 'P':
    {
  		// get userid, bodyText
      clientMessage.erase(0, 2);
      vector<string> clientData;
      if (GetClientData(clientMessage, clientData)) return BAD_REQ;
      if (AuthenticateUser(clientData[0])) return BAD_AUTH;

  		// INSERT into posts (generate postid, timestamp)
      string queryString;
      if (ConstructInsertQuery(queryString, "Posts", clientData)) return BAD_REQ;
      if (ExecDB(queryString)) return BAD_REQ;

  		// INSERT into posts by user
      // get the post id from the post that was just created
      int postid = mysql_insert_id(&mysqlObj);
      clientData[1] = to_string(postid); // clever swap here to reuse clientData
      if (ConstructInsertQuery(queryString, "PostsByUser", clientData)) return BAD_REQ;
      if (ExecDB(queryString)) return BAD_REQ;

      // incriment the posters rep for making a post
      // decriment happens with response to the delete post request
      if (ChangeUserRep(clientData[0], postRep)) return BAD_REQ;

  		return error; // NOT NULL
    }
  	case 'R':
    {
  		// get userid, postid, bodyText
  		// INSERT into replies
  		// INSERT into RepliesByUser
  		// INSERT into RepliesByReply OR RepliesByPost
  		return error; //NOT NULL
    }
  	case 'L':
    {
  		// get userid, postid, likeval
      clientMessage.erase(0, 2);
      vector<string> clientData;
      if (GetClientData(clientMessage, clientData)) return BAD_REQ;
      if (AuthenticateUser(clientData[0])) return BAD_AUTH;

      if (clientData.size() != 3)
      {
        cout << "ERROR reading like command, wrong number of parameters" << endl;
        return BAD_REQ;
      }

      // get user's the current likestate of the post
      string queryString = "SELECT LikeState FROM LikesByUser WHERE UserID = "
      + clientData[0] + " AND PostID = " + clientData[1] + ";";
      if (ExecDB(queryString)) return BAD_REQ;
      MYSQL_RES *res = mysql_store_result(&mysqlObj);

      // if no results, create entry
      int previousLikeState = 0;
      if (!mysql_num_rows(res))
      {
        if (ConstructInsertQuery(queryString, "LikesByUser", clientData)) return BAD_REQ;
        if (ExecDB(queryString)) return BAD_REQ;
      }
      // if results, update entry
      else
      {
        MYSQL_ROW row = mysql_fetch_row(res);
        previousLikeState = stoi(row[0]);
        queryString =
        "UPDATE LikesByUser SET LikeState = " + clientData[2]
        + " WHERE UserID = " + clientData[0] + " AND PostID = "
        + clientData[1] + ";";
        if (ExecDB(queryString)) return BAD_REQ;
      }
      mysql_free_result(res);

      // incriment/decrement poster's rep based on previous like state
      int newLikeState = stoi(clientData[2]);
      string authorid;
      GetAuthorIDOfPost(authorid, clientData[1]);
      cout << "AuthorID of the liked post: " << authorid << endl;
      if (ChangeUserRep(authorid, newLikeState - previousLikeState)) return BAD_REQ;

  		return error;
    }
  	case 'F':
    {
  		// get userid, followerid
      clientMessage.erase(0, 2);
      vector<string> clientData;
      if (GetClientData(clientMessage, clientData)) return -1;
      if (AuthenticateUser(clientData[0])) return BAD_AUTH;

  		// INSERT into FollowersByUser
      string queryString;
      if (ConstructInsertQuery(queryString, "FollowersByUser", clientData)) return -1;
      if (ExecDB(queryString)) return -1;

  		// incriment the followee's rep for gaining a follower
      // decriment happens with response to the delete follow request
      if (ChangeUserRep(clientData[1], followRep)) return -1;
  		return error;
    }
  	case 'S':
    {
  		// get userid, postid
      clientMessage.erase(0, 2);
      vector<string> clientData;
      if (GetClientData(clientMessage, clientData)) return -1;
      if (AuthenticateUser(clientData[0])) return BAD_AUTH;

      // INSERT into SharesByPost
      string queryString;
      if (ConstructInsertQuery(queryString, "SharesByPost", clientData)) return -1;
      if (ExecDB(queryString)) return -1;
  		return error;
    }
    default:
    {
      cout << "ERROR: Received create request for unrecognized object" << endl;
      return -1;
    }
	}
}

// handles delete messages
// tries to delete data in the database
static int HandleDeleteRequest(string &clientMessage)
{
  int error = 0;
	switch(clientMessage[1])
  {
  	case 'U':
    {
  		// get userid
  		// MODIFY Users.alive
  		return error; //NOT NULL
    }
  	case 'P':
    {
  		// get postid
  		// DELETE POST (1)
  		// DELETE PostsByUser (1)
  		// DELETE
  		//...
  		//DecrimentUserRep(userid);
  		return error; // NOT NULL
    }
  	//R:??

  	case 'F':
    {
  		// get userid, followpostid
  		// Delete in FollowersByUser
  		//IncrimentUserRep(followerid, -);
  		return error; //NOT NULL
    }
    case 'S':
    {
  		// get postid, shareid
  		// Delete SharedPostsBySharedUser (how to impliment in client?)
  		return error; //NOT NULL
    }
    default:
    {
      cout << "ERROR: Received delete request for unrecognized object" << endl;
      return -1;
    }
  }
}

// handles a client's get request and constructs the body of the servers response
// makes select command, adds the row cells/row tags to create a response
static int HandleGetRequest(string &clientMessage, string &response)
{
  int error = 0;

	switch(clientMessage[1])
  {
  	case 'F':
    {
      return error;
    }
  	case 'L':
    {
      // get userid
      clientMessage.erase(0, 2);
      vector<string> clientData;
      if (GetClientData(clientMessage, clientData)) return -1;
      if (AuthenticateUser(clientData[0])) return BAD_AUTH;

      // get a list of Posts
      string queryString = "SELECT * from Posts ORDER BY ID DESC LIMIT 20;";

      // execute the select command
      if (ExecDB(queryString)) return -1;

      // retreive the ID and return
      MYSQL_RES* postsQueryResult = mysql_store_result(&mysqlObj);
      if(!postsQueryResult) return -1;

      // package the posts with associated user information
      PackagePosts(response, clientData[0], postsQueryResult);

      // clean up query results
      mysql_free_result(postsQueryResult);

      return error;
    }
  	case 'P':
    {
      return error;
    }
  	case 'M':
    {
      return error;
    }
  	case 'p':
    {
      return error;
    }
  	case 'u':
    {
      return error;
    }
    default:
    {
      cout << "ERROR: Received get request for unrecognized object" << endl;
      return -1;
    }
  }
  return -1;
}

// handles login/logout requests
// manages activity tokens
static int HandleAccountRequest(string &clientMessage, string &response)
{
  int error = 0;
	switch(clientMessage[1])
  {
  	case 'I':
    {
      // get username, password
      clientMessage.erase(0, 2);
      vector<string> clientData;
      if (GetClientData(clientMessage, clientData)) return -1;

      // check if account exists
      string queryString = "SELECT ID FROM Users WHERE Name = "
      + clientData[0] + " AND Password = " + clientData[1] + ";";
      if (ExecDB(queryString)) return -1;
      MYSQL_RES *res = mysql_store_result(&mysqlObj);
      if (mysql_num_rows(res))
      {
        // let the user log in! send back their ID and their new ticket
        MYSQL_ROW row = mysql_fetch_row(res);
        string userid = row[0];
        response += userid;
        response += ",";
        int ticket = GenerateTicket(userid);
        response += to_string(ticket);
      }
      else
      {
        // login failed
        error = -1;
      }

      mysql_free_result(res);
  		return error; //userid,ticket
    }
  	case 'O':
    {
  		// get userid
  		// MODIFY User.ticket (== 0)
  		return error; //NOT NULL
    }
    default:
    {
      cout << "ERROR: Unrecognized account request" << endl;
      return -1;
    }
  }
}

/* #################
CRITICAL SUBROUTINES
################# */

// changes a selected users reputation
// accepts the user's id in string format and the amount to inc/dec as an int
// returns 0 on success
static int ChangeUserRep(string &userid, int amount)
{
  string queryString = "UPDATE Users SET Reputation = Reputation + (" + to_string(amount)
  + ") WHERE ID = " + userid + ";";

  if (ExecDB(queryString)) return -1;

  if (!mysql_affected_rows(&mysqlObj))
  {
    cout << "ERROR: Zero rows affected while trying to update user rep" << endl;
    return -1;
  }

	return 0; //success status
}

// executes a database command in a mutual exclusion
// returns 0 on success
static int ExecDB(string queryString)
{
  int error;
  cout << "Executing SQL query: " << queryString << endl;

  pthread_mutex_lock(&dbmutex);
  error = mysql_real_query(&mysqlObj, queryString.c_str(), queryString.size());
  if (error)
  {
    cout << "ERROR executing database query" << endl
      << mysql_error(&mysqlObj) << endl;
  }
  pthread_mutex_unlock(&dbmutex);

  return error;
}

// packages post data to be sent to a client
// adds user specific information about the collection of posts
// returns 0 on success
static int PackagePosts(string &response, string &userid, MYSQL_RES *postsQueryResult)
{
  int numPosts = mysql_num_rows(postsQueryResult);
  int error = 0;
  string queryString;
  MYSQL_RES *res;
  MYSQL_ROW row;
  bool addThisAuthorFlag = true;
  vector<string> authorids;

  // construct the first half of the response string and create a list of authors
  for (int i = 0; i < numPosts; i++)
  {
    // look at a post in the list of posts we are sending to the client
    MYSQL_ROW currentPost = mysql_fetch_row(postsQueryResult);

    // add the posts data to the response
    for (int j = 0; j < 5; j++)
    {
      response += currentPost[j];
      response += delimChar;
    }

    // determine whether the client has liked this post before loading this page
    queryString = "SELECT LikeState FROM LikesByUser WHERE UserID = "
    + userid + " AND PostID = " + currentPost[0] + ";";
    if (ExecDB(queryString)) return -1;
    res = mysql_store_result(&mysqlObj);

    // add the post specific like results to the response buffer
    // will be zero if the user is not logged in (userid == 0)
    if (!mysql_num_rows(res))
    {
      response += "0";
    }
    else
    {
      // user has like the post before
      row = mysql_fetch_row(res);
      response += row[0];
    }
    mysql_free_result(res);

    // add a newObject character to signal we have added all the data relevent
    // to this post
    if (i + 1 < numPosts)
    {
      response += objectDelimChar;
    }

    // add this post's author ID to our list of authors if it hasn't already been
    for (unsigned int j = 0; j < authorids.size(); j++)
    {
      if (currentPost[1] == authorids[j])
      {
        addThisAuthorFlag = false;
        break;
      }
    }
    if (addThisAuthorFlag)
    {
      // save this post'd author id in a string vector
      authorids.push_back(currentPost[1]);
    }
    // assume we will add the author unless we already have
    addThisAuthorFlag = true;
  }

  // add the list delim char to signal we have finished adding post object data
  // in our response
  response += listDelimChar;

  // construct the second half of the response string with author data
  int numAuthors = authorids.size();
  for (int i = 0; i < numAuthors; i++)
  {
    queryString = "SELECT Name, Reputation FROM Users WHERE ID = "
    + authorids[i] + ";";
    if (ExecDB(queryString)) return -1;
    res = mysql_store_result(&mysqlObj);

    if (mysql_num_rows(res) != 1)
    {
      cout << "ERROR: IDs in Users table appears to inconsistent" << endl;
      return -1;
    }

    // add the author's id, name, and reputation to the response
    row = mysql_fetch_row(res);
    mysql_free_result(res);
    response += authorids[i];
    response += ",";
    response += row[0];
    response += ",";
    response += row[1];
    response += ",";

    // get the users follow status for this author
    queryString = "SELECT * FROM FollowersByUser where UserID = "
    + userid + " AND FollowerID = " + authorids[i] + ";";
    if (ExecDB(queryString)) return -1;
    res = mysql_store_result(&mysqlObj);

    // add the following status to the response message
    // will be "0" if the client hasn't logged in
    if (mysql_num_rows(res) > 0)
    {
      response += "1";
    }
    else
    {
      response += "0";
    }
    mysql_free_result(res);

    // add a newObject character to signal we have added all the data relevent
    // to this post
    if (i + 1 < numAuthors)
    {
      response += objectDelimChar;
    }
  }

  return error;
}

// sets the user's ticket number in the database to be a random number
// returns negative on failure
static int GenerateTicket(string userid)
{
	int ticket = rand() % 1024;
  if (ticket < 0) ticket *= -1;
	string queryString = "UPDATE Users SET Ticket = " + to_string(ticket)
  + " WHERE ID = " + userid + ";";
  if (ExecDB(queryString)) return -1;
  if (mysql_affected_rows(&mysqlObj) == 1)
  {
    return ticket;
  }
  else
  {
    return -1;
  }
}

// retreives the author of a post
// returns 0 on success
static int GetAuthorIDOfPost(string &authorid, string postid)
{
  string queryString = "SELECT AuthorID FROM Posts WHERE ID = "
  + postid + ";";

  if (ExecDB(queryString)) return -1;
  MYSQL_RES *res = mysql_store_result(&mysqlObj);
  if (mysql_num_rows(res) != 1)
  {
    cout << "ERROR getting author ID of specific post" << endl;
    return -1;
  }
  MYSQL_ROW row = mysql_fetch_row(res);
  authorid = row[0];

  return 0;
}

// authenticates a users ID and ticket sent as the first arguement of many requests
// returns 0 on success
static int AuthenticateUser(string& userid)
{
  cout << "Authenticating user" << endl;

  // break the ticket into <id><ticket>
  int pos = userid.find(ticketDelimChar);
  if (pos == (int)string::npos)
  {
    // no ticket was provided with this user
    int id = stoi(userid);

    if (id == 0)
    {
      // userid is "0" and the user wants to be anonymous
      cout << "Request from anonymous user" << endl;
      return 0;
    }
    else
    {
      cout << "BAD AUTHENTICATION" << endl;
      return -1;
    }
  }
  else
  {
    // authenticate the user
    string userTicket = userid.substr( pos+1, (userid.size()-pos)-1 );
    userid = userid.substr(0, pos); // will modify user ID returned to handler functions

    string queryString = "SELECT * FROM Users WHERE ID = " + userid
    + " AND Ticket = " + userTicket + ";";
    if (ExecDB(queryString)) return BAD_REQ;
    MYSQL_RES *res = mysql_store_result(&mysqlObj);

    // authentication fails if the provided token doesn't match up
    int affectedRows = mysql_affected_rows(&mysqlObj);
    MYSQL_ROW row = mysql_fetch_row(res);
    char IDstring[strlen(row[0])];
    strcpy(IDstring, row[0]);
    mysql_free_result(res);
    if (affectedRows != 1)
    {
      cout << "BAD AUTHENTICATION" << endl;
      return -1;
    }
    else
    {
      // ticket and userid are good
      cout << "Request from user " << IDstring << endl;
      return 0;
    }
  }
}

/* #############
HELPER FUNCTIONS
###############*/

// parses the clients message into strings (database cells) and store them in a vector
// returns zero on successs
static int GetClientData(string &clientMessage, vector<string> &clientData)
{
  int startOfItem = 0;
  int endOfItem = 0;
  endOfItem = clientMessage.find(delimChar);
  while (endOfItem != (int)string::npos)
  {
    // WILL NEED TO ADD SUPPORT FOR ESCAPE CHARS
    if (clientMessage[endOfItem - 1] == escapeChar)
    {
      clientMessage.erase(endOfItem - 1, (size_t)1);
      endOfItem = clientMessage.find(delimChar, endOfItem);
    }

    clientData.push_back(clientMessage.substr(startOfItem, endOfItem - startOfItem));
    startOfItem = endOfItem + 1;
    endOfItem = clientMessage.find(delimChar, startOfItem);
  }
  clientData.push_back(clientMessage.substr(startOfItem, (clientMessage.size() - 1) - startOfItem));
  return 0;
}

// contructs an insert query into a specific table
// accepts a reference to a string to populate with the query
// returns 0 on success
int ConstructInsertQuery(string &queryString, string tableName, vector<string> &clientData)
{
  if (!clientData.size())
  {
    cout << "ERROR: No client data in message" << endl;
    return -1;
  }

  queryString = "INSERT into " + tableName + " ";
  string columns;
  unsigned int numFields;

  // change variables based on the table the user is trying to insert into
  if (tableName == "Users")
  {
    numFields = 2;
    columns = "(Name, Password) ";
  }
  else if (tableName == "Posts")
  {
    numFields = 2;
    columns = "(AuthorId, Body) ";
  }
  else if (tableName == "PostsByUser")
  {
    numFields = 2;
    columns = "(UserID, PostID) ";
  }
  else if (tableName == "LikesByUser")
  {
    numFields = 3;
    columns = "(UserID, PostID, LikeState) ";
  }
  else if (tableName == "FollowersByUser")
  {
    numFields = 2;
    columns = "(UserID, FollowerID) ";
  }
  else if (tableName == "SharesByPost")
  {
    numFields = 2;
    columns = "(PostID, UserID) ";
  }
  else
  {
    cout << "ERROR: Unrecognized table name when constructing MYSQL query" << endl;
    return -1;
  }

  // make sure the client provided the correct amount of information to
  // complete the database query it requested
  if (clientData.size() != numFields)
  {
    cout << "ERROR: Incorrect amount of client data to perform requested MYSQL query" << endl;
    return -1;
  }

  // add the column names of the row we want to insert into to the query
  queryString += columns;

  // add values to query from client data
  queryString += "values(";
  queryString += clientData[0];
  for (unsigned int i = 1; i < clientData.size(); i++)
  {
    queryString += ",";
    queryString += clientData[i];
  }
  queryString += ");";

  return 0;
}
