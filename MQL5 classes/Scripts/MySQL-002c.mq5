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

#include <MQLMySQLClass.mqh>

string INI;
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
 CMySQL *DB = new CMySQL(); // database object
 
 Print (DB.DllVersion());

 INI = TerminalInfoString(TERMINAL_PATH)+"\\MQL5\\Scripts\\MyConnection.ini";
 DB.SetTrace(true);
 DB.LoadCredentials(INI);
 
 // open database connection
 Print ("Connecting...");
 
 if (!DB.Connect())
 {
  Print ("Connection failed! Error: ", DB.LastErrorMessage());
 }
 else 
 {
  Print ("Connection succeeded! ID#", DB.GetConnectID());
 }
 
 string Query;
 Query = "DROP TABLE IF EXISTS `test_table`";
 DB.Execute(Query);
 
 Query = "CREATE TABLE `test_table` (id int, code varchar(50), start_date datetime)";
 if (DB.Execute(Query))
    {
     Print ("Table `test_table` created.");
    }
 else
    {
     Print ("Table `test_table` cannot be created. Error: ",  DB.LastErrorMessage());
    }
 
 DB.Disconnect();
 Print ("Disconnected. Script done!");
 
 delete DB;
}
//+------------------------------------------------------------------+
