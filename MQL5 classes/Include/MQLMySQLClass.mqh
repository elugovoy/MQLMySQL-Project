/********************************************************************
 * MQLMySQL interface library "CLASSic Style"                       *
 ********************************************************************
 * This library uses MQLMySQL.DLL was developed as interface to con-*
 * nect to the MySQL database server.                               *
 * Note: Check expert advisor "Common" parameters to be sure that   *
 *       DLL imports are allowed.                                   *
 ********************************************************************/

#define MQLMYSQL_TRACER "TRACE: " // Prefix for tracer messages

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


class CMySQL
{
 private:
       bool     SQLTrace;
       datetime MySqlLastConnect;
       int      MySqlErrorNumber;       // recent MySQL error number
       string   MySqlErrorDescription;  // recent MySQL error description
       int      ConnectID;              // ID of database connection
       // database internal credentials can be set by SetCredentials or loaded from INI file by LoadCredentials
       bool     vCredentialsSet;
       string   vHost;
       string   vUser;
       string   vPassword;
       string   vDatabase;
       int      vPort;
       string   vSocket;
       int      vClientFlag;
       
       // just to clear error buffer before any function started its functionality
       void ClearErrors()
       {
        MySqlErrorNumber = 0;
        MySqlErrorDescription = "No errors.";
       }
 public:
       CMySQL(void)
       {
        // constructor
        SQLTrace = false; // Trace is disabled by default
        MySqlLastConnect = 0;
        vCredentialsSet = false; // database credentials are not set by default
        ConnectID = -1; // database is not connected by default
        ClearErrors();
       }
       
       ~CMySQL(void)
       {
        // destructor
        SQLTrace = false; // Trace is disabled by default
        MySqlLastConnect = 0;
        vCredentialsSet = false; // database credentials are not set by default
        if (ConnectID>=0) Disconnect();
        ClearErrors();
       }
       
       // Set tracing state
       // pState = true for debug
       //           false for release
       void SetTrace(bool pState)
       {
        SQLTrace = pState;
       }
       
       // Return the version of MQLMySQL library
       string DllVersion()
       {
        return(cMySqlVersion());
       }
       
       // Interface function Connect - make connection to MySQL database using parameter:
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
       bool Connect(string pHost, string pUser, string pPassword, string pDatabase, int pPort, string pSocket, int pClientFlag)
       {
        SetCredentials(pHost, pUser, pPassword, pDatabase, pPort, pSocket, pClientFlag);
        return (Connect());
       } // Connect
       
       // Interface function Connect - make connection to MySQL database using internal credentials (loaded or set)
       bool Connect(void)
       {
        int connection;
        ClearErrors();
        
        if (!vCredentialsSet)
        {
         MySqlErrorNumber = -8;
         MySqlErrorDescription = "No database credentials.";
         if (SQLTrace) Print (MQLMYSQL_TRACER, "Connection error #", MySqlErrorNumber, " ", MySqlErrorDescription);
         return (false);
        }
        
        if (ConnectID >= 0)
        {
         // Connection is already exists
         MySqlErrorNumber = -7;
         MySqlErrorDescription = "Connection already exists.";
         if (SQLTrace) Print (MQLMYSQL_TRACER, "Connection error #", MySqlErrorNumber, " ", MySqlErrorDescription);
         return (false);
        }
        
        connection = cMySqlConnect(vHost, vUser, vPassword, vDatabase, vPort, vSocket, vClientFlag);

        if (SQLTrace) Print (MQLMYSQL_TRACER, "Connecting to Host=", vHost, ", User=", vUser, ", Database=", vDatabase, " DBID#", connection);

        if (connection == -1)
        {
         MySqlErrorNumber = cGetMySqlErrorNumber(-1);
         MySqlErrorDescription = cGetMySqlErrorDescription(-1);
         if (SQLTrace) Print (MQLMYSQL_TRACER, "Connection error #", MySqlErrorNumber, " ", MySqlErrorDescription);
         return (false);
        }

        MySqlLastConnect = TimeCurrent();
        if (SQLTrace) Print (MQLMYSQL_TRACER, "Connected! DBID#", connection);
        
        ConnectID = connection;

        // SET UTF8 CHARSET FOR CONNECTION
        if (!Execute("SET NAMES UTF8"))
        {
         MySqlErrorNumber = cGetMySqlErrorNumber(-1);
         MySqlErrorDescription = cGetMySqlErrorDescription(-1);
         if (SQLTrace) Print (MQLMYSQL_TRACER, "'SET NAMES UTF8' error #", MySqlErrorNumber, " ", MySqlErrorDescription);
        }
        
        return (true);
       } // Connect

       // Set database credentials for further connection
       void SetCredentials(string pHost, string pUser, string pPassword, string pDatabase, int pPort, string pSocket, int pClientFlag)
       {
        vHost = pHost;
        vUser = pUser;
        vPassword = pPassword;
        vDatabase = pDatabase;
        vPort = pPort;
        vSocket = pSocket;
        vClientFlag = pClientFlag;
        vCredentialsSet = true;
       } // SetCredentials

       // Load database credentials for further connection from standard INI file
       // INI file must have section MYSQL and keys Host, User, Password, Database, Port, Socket, ClientFlag
       void LoadCredentials(string p_ini_file)
       {
        // reading database credentials from INI file
        vHost = ReadIni(p_ini_file, "MYSQL", "Host");
        vUser = ReadIni(p_ini_file, "MYSQL", "User");
        vPassword = ReadIni(p_ini_file, "MYSQL", "Password");
        vDatabase = ReadIni(p_ini_file, "MYSQL", "Database");
        vPort     = (int)StringToInteger(ReadIni(p_ini_file, "MYSQL", "Port"));
        vSocket   = ReadIni(p_ini_file, "MYSQL", "Socket");
        vClientFlag = (int)StringToInteger(ReadIni(p_ini_file, "MYSQL", "ClientFlag"));  

        if (SQLTrace) Print (MQLMYSQL_TRACER, "Loaded '", p_ini_file, "'> Host: ", vHost, ", User: ", vUser, ", Database: ", vDatabase);
        vCredentialsSet = true;
       } // LoadCredentials

       // Interface function Disconnect - closes connection to database
       // When no connection was established - nothing happends
       void Disconnect(void)
       {
        ClearErrors();
        if (ConnectID != -1) 
        {
         cMySqlDisconnect(ConnectID);
         if (SQLTrace) Print (MQLMYSQL_TRACER, "DBID#", ConnectID, " disconnected");
         ConnectID = -1;
        }
       } // Disconnect

       // Interface function Execute - executes SQL query (DML/DDL/DCL operations, MySQL commands)
       // pQuery      - SQL query
       // ------------------------------------------------------
       // RETURN      - true : when execution succeded
       //             - false: when any error was raised (see MySqlErrorNumber, MySqlErrorDescription)
       bool Execute(string pQuery)
       {
        ClearErrors();
        if (SQLTrace) Print (MQLMYSQL_TRACER, "DBID#", ConnectID, ", CMD:", pQuery);
        if (ConnectID == -1) 
        {
         // no connection
         MySqlErrorNumber = -2;
         MySqlErrorDescription = "No connection to the database.";
         if (SQLTrace) Print (MQLMYSQL_TRACER, "CMD>", MySqlErrorNumber, ": ", MySqlErrorDescription);
         return (false);
        }
 
        if (!cMySqlExecute(ConnectID, pQuery))
        {
         MySqlErrorNumber = cGetMySqlErrorNumber(ConnectID);
         MySqlErrorDescription = cGetMySqlErrorDescription(ConnectID);
         if (SQLTrace) Print (MQLMYSQL_TRACER, "CMD>", MySqlErrorNumber, ": ", MySqlErrorDescription);
         return (false);
        }
        return (true);
       } // Execute
       
       // return number of rows affected by last DML operation
       int RowsAffected(void)
       {
        return (cMySqlRowsAffected(ConnectID));
       } // RowsAffected

       // return internal connection identifier
       int GetConnectID(void)
       {
        return ConnectID;
       } // GetConnectID
       
       bool GetTrace(void)
       {
        return SQLTrace;
       } // GetTrace
       
       int LastError(void)
       {
        return MySqlErrorNumber;
       } // LastError
       
       string LastErrorMessage(void)
       {
        return MySqlErrorDescription;
       } // LastErrorMessage
       
}; // class CMySQL

class CMySQLCursor
{
 private:
       int CursorID;
       int ConnectID;
       int CursorErrorNumber;
       string CursorErrorDescription;
       bool SQLTrace; 
       
       // just to clear error buffer before any function started its functionality
       void ClearErrors()
       {
        CursorErrorNumber = 0;
        CursorErrorDescription = "No errors.";
       } // ClearErrors
 public:
       CMySQLCursor(void)
       {
        // constructor
        ConnectID = -1;
        CursorID = -1;
        ClearErrors();
        SQLTrace = false;
       }
       
       ~CMySQLCursor(void)
       {
        // destructor
        if (CursorID>=0) Close();
        ClearErrors();
       }

      // creates an cursor based on SELECT statement
      // return valuse - true on success
      //                 false on fail, to get the error - call LastError() and/or LastErrorMessage()
      bool Open(CMySQL *pConnection, string pQuery)
      {
       SQLTrace = pConnection.GetTrace();
       ConnectID =  pConnection.GetConnectID();
       if (SQLTrace) Print (MQLMYSQL_TRACER, "DBID#", ConnectID, ", QRY:", pQuery);
       ClearErrors();
       
       CursorID = cMySqlCursorOpen(ConnectID, pQuery);
       if (CursorID == -1)
       {
        CursorErrorNumber = cGetMySqlErrorNumber(ConnectID);
        CursorErrorDescription = cGetMySqlErrorDescription(ConnectID);
        if (SQLTrace) Print (MQLMYSQL_TRACER, "QRY>", CursorErrorNumber, ": ", CursorErrorDescription);
        return (false);
       }
       return (true);
      } // Open
      
      // closes opened cursor
      void Close(void)
      {
       ClearErrors();
       // if (CursorID == -1) return; // no active cursor
       
       cMySqlCursorClose(CursorID);
       CursorErrorNumber = cGetCursorErrorNumber(CursorID);
       CursorErrorDescription = cGetCursorErrorDescription(CursorID);
       if (CursorErrorNumber != 0)
       {
        if (SQLTrace) Print (MQLMYSQL_TRACER, "Cursor #", CursorID, " closing error: ", CursorErrorNumber, ": ", CursorErrorDescription);
       }
       else 
       {
        if (SQLTrace) Print (MQLMYSQL_TRACER, "Cursor #", CursorID, " closed");
        CursorID = -1;
       } // if (CursorErrorNumber != 0)
      } // Close
      
      // return number of rows was selected by cursor
      int Rows(void)
      {
       int result;
       result = cMySqlCursorRows(CursorID);
       CursorErrorNumber = cGetCursorErrorNumber(CursorID);
       CursorErrorDescription = cGetCursorErrorDescription(CursorID);
       if (SQLTrace) Print (MQLMYSQL_TRACER, "Cursor #", CursorID, ", rows: ", result);
       return (result);
      } // Rows

      // fetch next row from cursor into current row buffer
      // return true - if succeeded, otherwise - false
      bool Fetch(void)
      {
       bool result;
       result = cMySqlCursorFetchRow(CursorID);
       CursorErrorNumber = cGetCursorErrorNumber(CursorID);
       CursorErrorDescription = cGetCursorErrorDescription(CursorID);
       if (SQLTrace && CursorErrorNumber != 0)
       {
        Print (MQLMYSQL_TRACER, "Cursor #", CursorID, " fetching error: ", CursorErrorNumber, ": ", CursorErrorDescription);
       }
       return (result); 
      } // Fetch

      // retrieves the value from current row was fetched by cursor
      // fields start from 0
      string FieldAsString(int pField)
      {
       string result;
       result = cMySqlGetRowField(CursorID, pField);
       CursorErrorNumber = cGetCursorErrorNumber(CursorID);
       CursorErrorDescription = cGetCursorErrorDescription(CursorID);
       return (result);
      } // FieldAsString

      int FieldAsInt(int pField)
      {
       return ((int)StringToInteger(FieldAsString(pField)));
      } // FieldAsInt
      
      double FieldAsDouble(int pField)
      {
       return (StringToDouble(FieldAsString(pField)));
      } // FieldAsDouble

      datetime FieldAsDatetime(int pField)
      {
       string x = FieldAsString(pField);
       StringReplace(x, "-", ".");
       return (StringToTime(x));
      } // FieldAsDatetime
      
       int LastError(void)
       {
        return CursorErrorNumber;
       } // LastError
       
       string LastErrorMessage(void)
       {
        return CursorErrorDescription;
       } // LastErrorMessage
}; // class CMQLCursor


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
