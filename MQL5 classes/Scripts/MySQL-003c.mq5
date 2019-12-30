//+------------------------------------------------------------------+
//|                                                    MySQL-003.mq5 |
//|                                   Copyright 2014, Eugene Lugovoy |
//|                                              http://www.mql5.com |
//| Inserting data with multi-statement (DEMO)                       |
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
     
     // Inserting data 1 row
     Query = "INSERT INTO `test_table` (id, code, start_date) VALUES ("+(string)AccountInfoInteger(ACCOUNT_LOGIN)+",\'ACCOUNT\',\'"+TimeToString(TimeLocal(), TIME_DATE|TIME_SECONDS)+"\')";
     if (DB.Execute(Query))
        {
         Print ("Succeeded: ", Query);
        }
     else
        {
         Print ("Error: ", DB.LastErrorMessage());
         Print ("Query: ", Query);
        }
     
     // multi-insert
     Query =         "INSERT INTO `test_table` (id, code, start_date) VALUES (1,\'EURUSD\',\'2014.01.01 00:00:01\');";
     Query = Query + "INSERT INTO `test_table` (id, code, start_date) VALUES (2,\'EURJPY\',\'2014.01.02 00:02:00\');";
     Query = Query + "INSERT INTO `test_table` (id, code, start_date) VALUES (3,\'USDJPY\',\'2014.01.03 03:00:00\');";
     if (DB.Execute(Query))
        {
         Print ("Succeeded! 3 rows has been inserted by one query.");
        }
     else
        {
         Print ("Error of multiple statements: ", DB.LastErrorMessage());
        }
    }
 else
    {
     Print ("Table `test_table` cannot be created. Error: ", DB.LastErrorMessage());
    }
 
 DB.Disconnect();
 Print ("Disconnected. Script done!");
 
 delete DB;
}
//+------------------------------------------------------------------+
