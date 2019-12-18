//+------------------------------------------------------------------+
//|                                                    MySQL-001.mq5 |
//|                                   Copyright 2014, Eugene Lugovoy |
//|                                              http://www.mql5.com |
//| Test connections to MySQL. Reaching limit (DEMO)                 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, Eugene Lugovoy"
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
 int DB1,DB2,DB3; // database identifiers
 
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
 
 DB1 = MySqlConnect(Host, User, Password, Database, Port, Socket, ClientFlag);
 
 if (DB1 == -1) { Print ("Connection failed! Error: "+MySqlErrorDescription); } else { Print ("Connected! DBID#",DB1);}
 
 DB2 = MySqlConnect(Host, User, Password, Database, Port, Socket, ClientFlag);
 
 if (DB2 == -1) { Print ("Connection failed! Error: "+MySqlErrorDescription); } else { Print ("Connected! DBID#",DB2);}

 DB3 = MySqlConnect(Host, User, Password, Database, Port, Socket, ClientFlag);
 
 if (DB3 == -1) { Print ("Connection failed! Error: "+MySqlErrorDescription); } else { Print ("Connected! DBID#",DB3);}
 
 MySqlDisconnect(DB3);
 MySqlDisconnect(DB2);
 MySqlDisconnect(DB1);
 Print ("All connections closed. Script done!");
   
}
//+------------------------------------------------------------------+
