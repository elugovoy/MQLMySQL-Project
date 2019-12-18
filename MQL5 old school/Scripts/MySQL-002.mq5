//+------------------------------------------------------------------+
//|                                                    MySQL-002.mq5 |
//|                                   Copyright 2014, Eugene Lugovoy |
//|                                              http://www.mql5.com |
//| Table creation (DEMO)                                            |
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
 
 if (DB == -1) { Print ("Connection failed! Error: "+MySqlErrorDescription); } else { Print ("Connected! DBID#",DB);}
 
 string Query;
 Query = "DROP TABLE IF EXISTS `test_table`";
 MySqlExecute(DB, Query);
 
 Query = "CREATE TABLE `test_table` (id int, code varchar(50), start_date datetime)";
 if (MySqlExecute(DB, Query))
    {
     Print ("Table `test_table` created.");
    }
 else
    {
     Print ("Table `test_table` cannot be created. Error: ", MySqlErrorDescription);
    }
 
 MySqlDisconnect(DB);
 Print ("Disconnected. Script done!");
}
//+------------------------------------------------------------------+
