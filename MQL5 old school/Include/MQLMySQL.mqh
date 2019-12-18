/********************************************************************
 * MQLMySQL interface library                                       *
 ********************************************************************
 * This library uses MQLMySQL.DLL was developed as interface to con-*
 * nect to the MySQL database server.                               *
 * Note: Check expert advisor "Common" parameters to be sure that   *
 *       DLL imports are allowed.                                   *
 ********************************************************************/
bool SQLTrace = false;
datetime MySqlLastConnect=0;

#import "MQLMySQL.dll"
// returns version of MySqlCursor.dll library
string cMySqlVersion ();

// number of last error of connection
int    cGetMySqlErrorNumber(int pConnection);

// number of last error of cursor
int    cGetCursorErrorNumber(int pCursorID);

// description of last error for connection
string cGetMySqlErrorDescription(int pConnection);

// description of last error for cursor
string cGetCursorErrorDescription(int pCursorID);

// establish connection to MySql database server
// and return connection identifier
int    cMySqlConnect       (string pHost,       // Host name
                            string pUser,       // User
                            string pPassword,   // Password
                            string pDatabase,   // Database name
                            int    pPort,       // Port
                            string pSocket,     // Socket for Unix
                            int    pClientFlag);// Client flag
// closes connection to database
void   cMySqlDisconnect    (int pConnection);   // pConnection - database identifier (pointer to structure)
// executes non-SELECT statements
bool   cMySqlExecute       (int    pConnection, // pConnection - database identifier (pointer to structure)
                            string pQuery);     // pQuery      - SQL query for execution
// creates an cursor based on SELECT statement
// return valuse - cursor identifier
int    cMySqlCursorOpen    (int    pConnection, // pConnection - database identifier (pointer to structure)
                            string pQuery);     // pQuery      - SELECT statement for execution
// closes opened cursor
void   cMySqlCursorClose   (int pCursorID);     // pCursorID  - internal identifier of cursor
// return number of rows was selected by cursor
int    cMySqlCursorRows    (int pCursorID);     // pCursorID  - internal identifier of cursor
// fetch next row from cursor into current row buffer
// return true - if succeeded, otherwise - false
bool   cMySqlCursorFetchRow(int pCursorID);     // pCursorID  - internal identifier of cursor
// retrieves the value from current row was fetched by cursor
string cMySqlGetRowField   (int    pCursorID,   // pCursorID  - internal identifier of cursor
                            int    pField);     // pField     - number of field in SELECT clause (started from 0,1,2... e.t.c.)

// return the number of rows affected by last DML operation (INSERT/UPDATE/DELETE)
int cMySqlRowsAffected (int pConnection);      

// Reads and returns the key value from standard INI-file
string ReadIni             (string pFileName,   // INI-filename
                            string pSection,    // name of section
                            string pKey);       // name of key
#import


//interface variables
int    MySqlErrorNumber;       // recent MySQL error number
string MySqlErrorDescription;  // error description

// return the version of MySQLCursor.DLL
string MySqlVersion()
{
 return(cMySqlVersion());
}

// Interface function MySqlConnect - make connection to MySQL database using parameter:
// pHost       - DNS name or IP-address
// pUser       - database user (f.e. root)
// pPassword   - password of user (f.e. Zok1LmVdx)
// pDatabase   - database name (f.e. metatrader)
// pPort       - TCP/IP port of database listener (f.e. 3306)
// pSocket     - unix socket (for sockets or named pipes using)
// pClientFlag - combination of the flags for features (usual 0)
// ------------------------------------------------------------------------------------
// RETURN      - database connection identifier
//               if return value = 0, check MySqlErrorNumber and MySqlErrorDescription
int MySqlConnect(string pHost, string pUser, string pPassword, string pDatabase, int pPort, string pSocket, int pClientFlag)
{
 int connection;
 ClearErrors();
 connection = cMySqlConnect(pHost, pUser, pPassword, pDatabase, pPort, pSocket, pClientFlag);

 if (SQLTrace) Print ("Connecting to Host=", pHost, ", User=", pUser, ", Database=", pDatabase, " DBID#", connection);

 if (connection == -1)
    {
     MySqlErrorNumber = cGetMySqlErrorNumber(-1);
     MySqlErrorDescription = cGetMySqlErrorDescription(-1);
     if (SQLTrace) Print ("Connection error #",MySqlErrorNumber," ",MySqlErrorDescription);
    }
 else
    {
     MySqlLastConnect = TimeCurrent();
     if (SQLTrace) Print ("Connected! DBID#",connection);
    }

 // SET UTF8 CHARSET FOR CONNECTION
 if (!MySqlExecute(connection, "SET NAMES UTF8"))
    {
     MySqlErrorNumber = cGetMySqlErrorNumber(-1);
     MySqlErrorDescription = cGetMySqlErrorDescription(-1);
     if (SQLTrace) Print ("'SET NAMES UTF8' error #",MySqlErrorNumber," ",MySqlErrorDescription);
    }
 
 return (connection);
}

// Interface function MySqlDisconnect - closes connection "pConnection" to database
// When no connection was established - nothing happends
void MySqlDisconnect(int &pConnection)
{
 ClearErrors();
 if (pConnection != -1) 
    {
     cMySqlDisconnect(pConnection);
     if (SQLTrace) Print ("DBID#",pConnection," disconnected");
     pConnection = -1;
    }
}

// Interface function MySqlExecute - executes SQL query via specified connection
// pConnection - opened database connection
// pQuery      - SQL query
// ------------------------------------------------------
// RETURN      - true : when execution succeded
//             - false: when any error was raised (see MySqlErrorNumber, MySqlErrorDescription, MySqlErrorQuery)
bool MySqlExecute(int pConnection, string pQuery)
{
 ClearErrors();
 if (SQLTrace) {Print ("DBID#",pConnection,", CMD:",pQuery);}
 if (pConnection == -1) 
    {
     // no connection
     MySqlErrorNumber = -2;
     MySqlErrorDescription = "No connection to the database.";
     if (SQLTrace) Print ("CMD>",MySqlErrorNumber, ": ", MySqlErrorDescription);
     return (false);
    }
 
 if (!cMySqlExecute(pConnection, pQuery))
    {
     MySqlErrorNumber = cGetMySqlErrorNumber(pConnection);
     MySqlErrorDescription = cGetMySqlErrorDescription(pConnection);
     if (SQLTrace) Print ("CMD>",MySqlErrorNumber, ": ", MySqlErrorDescription);
     return (false);
    }
 return (true);
}

// creates an cursor based on SELECT statement
// return valuse - cursor identifier
int MySqlCursorOpen(int pConnection, string pQuery)
{
 int result;
 if (SQLTrace) {Print ("DBID#",pConnection,", QRY:",pQuery);}
 ClearErrors();
 result = cMySqlCursorOpen(pConnection, pQuery);
 if (result == -1)
    {
     MySqlErrorNumber = cGetMySqlErrorNumber(pConnection);
     MySqlErrorDescription = cGetMySqlErrorDescription(pConnection);
     if (SQLTrace) Print ("QRY>",MySqlErrorNumber, ": ", MySqlErrorDescription);
    }
 return (result);
}

// closes opened cursor
void MySqlCursorClose(int pCursorID)
{
 ClearErrors();
 cMySqlCursorClose(pCursorID);
 MySqlErrorNumber = cGetCursorErrorNumber(pCursorID);
 MySqlErrorDescription = cGetCursorErrorDescription(pCursorID);
 if (SQLTrace) 
    {
     if (MySqlErrorNumber!=0)
        {
         Print ("Cursor #",pCursorID," closing error:", MySqlErrorNumber, ": ", MySqlErrorDescription);
        }
     else 
        {
         Print ("Cursor #",pCursorID," closed");
        }
    }
}

// return number of rows was selected by cursor
int MySqlCursorRows(int pCursorID)
{
 int result;
 result = cMySqlCursorRows(pCursorID);
 MySqlErrorNumber = cGetCursorErrorNumber(pCursorID);
 MySqlErrorDescription = cGetCursorErrorDescription(pCursorID);
 if (SQLTrace) Print ("Cursor #",pCursorID,", rows: ",result);
 return (result);
}

// fetch next row from cursor into current row buffer
// return true - if succeeded, otherwise - false
bool MySqlCursorFetchRow(int pCursorID)
{
 bool result;
 result = cMySqlCursorFetchRow(pCursorID);
 MySqlErrorNumber = cGetCursorErrorNumber(pCursorID);
 MySqlErrorDescription = cGetCursorErrorDescription(pCursorID);
 return (result); 
}

// retrieves the value from current row was fetched by cursor
string MySqlGetRowField(int pCursorID, int pField)
{
 string result;
 result = cMySqlGetRowField(pCursorID, pField);
 MySqlErrorNumber = cGetCursorErrorNumber(pCursorID);
 MySqlErrorDescription = cGetCursorErrorDescription(pCursorID);
 return (result);
}

int MySqlGetFieldAsInt(int pCursorID, int pField)
{
 return ((int)StringToInteger(MySqlGetRowField(pCursorID, pField)));
}

double MySqlGetFieldAsDouble(int pCursorID, int pField)
{
 return (StringToDouble(MySqlGetRowField(pCursorID, pField)));
}

datetime MySqlGetFieldAsDatetime(int pCursorID, int pField)
{
 string x = MySqlGetRowField(pCursorID, pField);
 StringReplace(x,"-",".");
 return (StringToTime(x));
}

string MySqlGetFieldAsString(int pCursorID, int pField)
{
 return (MySqlGetRowField(pCursorID, pField));
}

// just to clear error buffer before any function started its functionality
void ClearErrors()
{
 MySqlErrorNumber = 0;
 MySqlErrorDescription = "No errors.";
}

int MySqlRowsAffected  (int pConnection)
{
 return (cMySqlRowsAffected(pConnection));
}


/********************************************************************
 * MySQL standard definitions                                       *
 ********************************************************************/
#define CLIENT_LONG_PASSWORD               1 /* new more secure passwords */
#define CLIENT_FOUND_ROWS                  2 /* Found instead of affected rows */
#define CLIENT_LONG_FLAG                   4 /* Get all column flags */
#define CLIENT_CONNECT_WITH_DB             8 /* One can specify db on connect */
#define CLIENT_NO_SCHEMA                  16 /* Don't allow database.table.column */
#define CLIENT_COMPRESS                   32 /* Can use compression protocol */
#define CLIENT_ODBC                       64 /* Odbc client */
#define CLIENT_LOCAL_FILES               128 /* Can use LOAD DATA LOCAL */
#define CLIENT_IGNORE_SPACE              256 /* Ignore spaces before '(' */
#define CLIENT_PROTOCOL_41               512 /* New 4.1 protocol */
#define CLIENT_INTERACTIVE              1024 /* This is an interactive client */
#define CLIENT_SSL                      2048 /* Switch to SSL after handshake */
#define CLIENT_IGNORE_SIGPIPE           4096 /* IGNORE sigpipes */
#define CLIENT_TRANSACTIONS             8192 /* Client knows about transactions */
#define CLIENT_RESERVED                16384 /* Old flag for 4.1 protocol  */
#define CLIENT_SECURE_CONNECTION       32768 /* New 4.1 authentication */
#define CLIENT_MULTI_STATEMENTS        65536 /* Enable/disable multi-stmt support */
#define CLIENT_MULTI_RESULTS          131072 /* Enable/disable multi-results */
#define CLIENT_PS_MULTI_RESULTS       262144 /* Multi-results in PS-protocol */

