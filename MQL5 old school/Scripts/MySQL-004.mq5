//+------------------------------------------------------------------+
//|                                                    MySQL-004.mq5 |
//|                                   Copyright 2014, Eugene Lugovoy |
//|                                              http://www.mql5.com |
//| Select data from table (DEMO)                                    |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, Eugene Lugovoy."
#property link      "http://www.mql5.com"
#property version   "1.00"
#property strict

#include <MQLMySQL.mqh>

string INI;
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
 string Host, User, Password, Database, Socket; // database credentials
 int Port,ClientFlag;
 int DB; // database identifier
 
 Print (MySqlVersion());

 INI = TerminalInfoString(TERMINAL_PATH)+"\\MQL5\\Scripts\\MyConnection.ini";
 
 // reading database credentials from INI file
 Host = ReadIni(INI, "MYSQL", "Host");
 User = ReadIni(INI, "MYSQL", "User");
 Password = ReadIni(INI, "MYSQL", "Password");
 Database = ReadIni(INI, "MYSQL", "Database");
 Port     = (int)StringToInteger(ReadIni(INI, "MYSQL", "Port"));
 Socket   = ReadIni(INI, "MYSQL", "Socket");
 ClientFlag = (int)StringToInteger(ReadIni(INI, "MYSQL", "ClientFlag"));  

 Print ("Host: ",Host, ", User: ", User, ", Database: ",Database);
 
 // open database connection
 Print ("Connecting...");
 
 DB = MySqlConnect(Host, User, Password, Database, Port, Socket, ClientFlag);
 
 if (DB == -1) { Print ("Connection failed! Error: "+MySqlErrorDescription); return; } else { Print ("Connected! DBID#",DB);}
 
 // executing SELECT statement
 string Query;
 int    i,Cursor,Rows;
 
 int      vId;
 string   vCode;
 datetime vStartTime;
 
 Query = "SELECT id, code, start_date FROM `test_table`";
 Print ("SQL> ", Query);
 Cursor = MySqlCursorOpen(DB, Query);
 
 if (Cursor >= 0)
    {
     Rows = MySqlCursorRows(Cursor);
     Print (Rows, " row(s) selected.");
     for (i=0; i<Rows; i++)
         if (MySqlCursorFetchRow(Cursor))
            {
             vId = MySqlGetFieldAsInt(Cursor, 0); // id
             vCode = MySqlGetFieldAsString(Cursor, 1); // code
             vStartTime = MySqlGetFieldAsDatetime(Cursor, 2); // start_time
             Print ("ROW[",i,"]: id = ", vId, ", code = ", vCode, ", start_time = ", TimeToString(vStartTime, TIME_DATE|TIME_SECONDS));
            }
     MySqlCursorClose(Cursor); // NEVER FORGET TO CLOSE CURSOR !!!
    }
 else
    {
     Print ("Cursor opening failed. Error: ", MySqlErrorDescription);
    }
    
 MySqlDisconnect(DB);
 Print ("Disconnected. Script done!");
}
//+------------------------------------------------------------------+
