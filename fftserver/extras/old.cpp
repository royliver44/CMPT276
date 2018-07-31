
// retreives the ID of an entry in a table
// executes a select query on a specific table to find the ID using provided data
// accepts references to a message received and a message to respond with
// returns ID (greater than zero) on success, negative on failure
/*int GetRowID(string tableName, vector<string> &clientData)
{
  if (!clientData.size())
  {
    cout << "ERROR: no client data in create messageto retreive ID" << endl;
    return -1;
  }

  string queryString = "SELECT ID from " + tableName + " where ";
  string columns;

  // change variables based on the table the user is trying to insert into
  if (tableName == "Posts")
  {
    if (clientData.size() != 2)
    {
      cout << "ERROR wrong amount of data provided to find post ID" << endl;
      return -1;
    }
    string whereString = "AuthorID = " + clientData[0]
      + " AND Body = " + clientData[1] + ";";
    queryString += whereString;
  }
  else
  {
    cout << "ERROR: unrecognized table name when constructing query" << endl;
    return -1;
  }

  // execute the select command
  if (ExecDB(queryString)) return -1;

  // retreive the ID and return
  MYSQL_RES* result = mysql_store_result(&mysqlObj);
  if(!result)
  {
    cout << "ERROR retreiving mysql query results" << endl;
    return -1;
  }

  // fetch the first row in the results and convert the string to an integer
  MYSQL_ROW row = mysql_fetch_row(result);
  if(!mysql_num_rows(result))
  {
    cout << "ERROR: no rows in table match request! cannot get ID" << endl;
    return -1;
  }
  int id = stoi(row[0]);

  mysql_free_result(result);

  return id;

  sample fetch row
  MYSQL_ROW row;
  unsigned int num_fields;
  unsigned int i;

  num_fields = mysql_num_fields(result);
  while ((row = mysql_fetch_row(result)))
  {
     unsigned long *lengths;
     lengths = mysql_fetch_lengths(result);
     for(i = 0; i < num_fields; i++)
     {
         printf("[%.*s] ", (int) lengths[i],
                row[i] ? row[i] : "NULL");
     }
     printf("\n");
  }
}
*/

/* ###########
OLD FUNCTIONS
########### */

/*
// executes a clients create message
// tries to insert client object into database
// accepts a pointer to the input message
// returns success code
int HandleCreateRequest(char* clientMessage_b)
{
  string queryString = "insert into ";

  // figure out what table the client wants to insert to
  string tableName;
  switch (clientMessage_b[1])
  {
    case 'U':
      tableName = "Users";
      break;
    case 'P':
      tableName = "Posts";
      break;
    case 'R':
      tableName = "Replies";
      break;
    default:
      cout << "ERROR unknown table name in create message" << clientMessage_b[1] << endl;
      return -1;
      break;
  }
  queryString += tableName;
  queryString += " values(";
  string clientMessage(clientMessage_b + 2);

  // get the table cells the client wants to insert and construct the query
  int pos1 = 0;
  int pos2 = 0;
  pos2 = clientMessage.find(delimChar);
  while (pos2 != (int)string::npos)
  {
    // WILL NEED TO ADD SUPPORT FOR ESCAPE CHARS
    queryString += clientMessage.substr(pos1, pos2 - pos1);
    queryString += ",";
    pos1 = pos2 + 1;
    pos2 = clientMessage.find(delimChar, pos1);
  }
  queryString += clientMessage.substr(pos1, (clientMessage.size() - pos1) - 1);
  queryString += ");";

	// execute DB query
  return ExecDB(queryString);
}

// handles a clients delete message
// tries to delete a row in the database
// accepts a pointer to the input message
// returns a success code
int HandleDeleteRequest(char* buff)
{
  string queryString = "insert into ";

  // figure out what table the client wants to insert to
  string tableName;
  switch (clientMessage_b[1])
  {
    case 'U':
      tableName = "Users";
      break;
    case 'P':
      tableName = "Posts";
      break;
    case 'R':
      tableName = "Replies";
      break;
    default:
      cout << "ERROR unknown table name in create message" << clientMessage_b[1] << endl;
      return -1;
      break;
  }
  queryString += tableName;
  queryString += " values(";
  string clientMessage(clientMessage_b + 2);

  // get the table cells the client wants to insert and construct the query
  int pos1 = 0;
  int pos2 = 0;
  pos2 = clientMessage.find(delimChar);
  while (pos2 != (int)string::npos)
  {
    // WILL NEED TO ADD SUPPORT FOR ESCAPE CHARS
    queryString += clientMessage.substr(pos1, pos2 - pos1);
    queryString += ",";
    pos1 = pos2 + 1;
    pos2 = clientMessage.find(delimChar, pos1);
  }
  queryString += clientMessage.substr(pos1, (clientMessage.size() - pos1) - 1);
  queryString += ");";

  // execute DB query
  return -1; //ExecDB(queryString);
}

// handles a client's get request and constructs the body of the servers response
// makes select command, adds the row cells/row tags to create a response
// accepts a pointer to the input message
// returns a pointer to a buffer containing the body of the server response
char* HandleGetRequest(char* buff)
{
  int error = 0;
	// create DB query
	// execute DB query
	// construct response from query result
	if (error)
  {
		return NULL;
  }
  return buff;
}


// processes a clients message and wraps the response with ack or nack
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
}*/
/*
// gets the column data to insert into the database
static int GetColumnPairsForRow(string message, vector<string> &objects)
{
  cout << message << endl;

  // find the body of the message
  unsigned pos = message.find("<row>");
  if (pos == string::npos)
  {
    cout << "ERROR in message FORMAT: no row open tag" << endl;
    return -1;
  }
  message.erase(0, pos + 5);
  unsigned pos2 = message.find("</row>");
  if (pos2 == string::npos)
  {
    cout << "ERROR in message FORMAT: no row close tag" << endl;
    return -2;
  }
  message.erase(pos2, message.size() - 1);

  // get rid of escape characters
  //LATER IMPLIMENT
  //pos = message.find(escapeChar);
  //while(pos < pos2 && pos != string::npos)
  //{
  //  cout << "asdasd" << endl;
  //  message.erase(message.begin() + pos, message.begin() + pos + 1);
  //  pos = message.find(escapeChar, pos + 1);
//  }

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
  for (; cells.size() != 0; cells.erase(cells.begin()))
  {
    retString += ",";
    retString += cells[0];
  }

  // add the end of the query
  retString += ");";

  cout << retString << endl;

  return retString;
}
*/
