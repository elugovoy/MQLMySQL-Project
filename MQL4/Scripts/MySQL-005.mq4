//+------------------------------------------------------------------+
//|                                                    MySQL-005.mq4 |
//|                                   Copyright 2014, Eugene Lugovoy |
//|                                        http://www.fxcodexlab.com |
//| Reaching cursors limit (DEMO)                                    |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, Eugene Lugovoy."
#property link      "http://www.fxcodexlab.com"
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

 INI = TerminalPath()+"\\MQL4\\Scripts\\MyConnection.ini";
 
 // reading database credentials from INI file
 Host = ReadIni(INI, "MYSQL", "Host");
 User = ReadIni(INI, "MYSQL", "User");
 Password = ReadIni(INI, "MYSQL", "Password");
 Database = ReadIni(INI, "MYSQL", "Database");
 Port     = StrToInteger(ReadIni(INI, "MYSQL", "Port"));
 Socket   = ReadIni(INI, "MYSQL", "Socket");
 ClientFlag = StrToInteger(ReadIni(INI, "MYSQL", "ClientFlag"));  

 Print ("Host: ",Host, ", User: ", User, ", Database: ",Database);
 
 // open database connection
 Print ("Connecting...");
 
 DB = MySqlConnect(Host, User, Password, Database, Port, Socket, ClientFlag);
 
 if (DB == -1) { Print ("Connection failed! Error: "+MySqlErrorDescription); } else { Print ("Connected! DBID#",DB);}
 
 string Query;
 int Cursor1, Cursor2, Cursor3, Cursor4;
 Query = "SELECT * FROM `test_table` LIMIT 1";

 Cursor1 = MySqlCursorOpen(DB, Query);
 if (Cursor1 >= 0) {Print ("Cursor 1 was opened.");} else {Print ("Cursor 1 failed. Error: ", MySqlErrorDescription);}
 Cursor2 = MySqlCursorOpen(DB, Query);
 if (Cursor2 >= 0) {Print ("Cursor 2 was opened.");} else {Print ("Cursor 2 failed. Error: ", MySqlErrorDescription);}
 Cursor3 = MySqlCursorOpen(DB, Query);
 if (Cursor3 >= 0) {Print ("Cursor 3 was opened.");} else {Print ("Cursor 3 failed. Error: ", MySqlErrorDescription);}
 Cursor4 = MySqlCursorOpen(DB, Query);
 if (Cursor4 >= 0) {Print ("Cursor 4 was opened.");} else {Print ("Cursor 4 failed. Error: ", MySqlErrorDescription);}
 
 Print ("Closing cursors...");
 MySqlCursorClose(Cursor1);
 MySqlCursorClose(Cursor2);
 MySqlCursorClose(Cursor3);
 MySqlCursorClose(Cursor4);
 Print ("Passed!");
 
 MySqlDisconnect(DB);
 Print ("Disconnected. Script done!");
}
//+------------------------------------------------------------------+
