//+------------------------------------------------------------------+
//|                                                    MySQL-003.mq4 |
//|                                   Copyright 2014, Eugene Lugovoy |
//|                                        http://www.fxcodexlab.com |
//| Inserting data with multi-statement (DEMO)                       |
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
 ClientFlag = CLIENT_MULTI_STATEMENTS; //StrToInteger(ReadIni(INI, "MYSQL", "ClientFlag"));  

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
     
     // Inserting data 1 row
     Query = "INSERT INTO `test_table` (id, code, start_date) VALUES ("+(string)AccountNumber()+",\'ACCOUNT\',\'"+TimeToStr(TimeLocal(), TIME_DATE|TIME_SECONDS)+"\')";
     if (MySqlExecute(DB, Query))
        {
         Print ("Succeeded: ", Query);
         Print ("Rows affected: ", MySqlRowsAffected(DB));
        }
     else
        {
         Print ("Error: ", MySqlErrorDescription);
         Print ("Query: ", Query);
        }
     
     // multi-insert
     Query =         "INSERT INTO `test_table` (id, code, start_date) VALUES (1,\'EURUSD\',\'2014.01.01 00:00:01\');";
     Query = Query + "INSERT INTO `test_table` (id, code, start_date) VALUES (2,\'EURJPY\',\'2014.01.02 00:02:00\');";
     Query = Query + "INSERT INTO `test_table` (id, code, start_date) VALUES (3,\'USDJPY\',\'2014.01.03 03:00:00\');";
     if (MySqlExecute(DB, Query))
        {
         Print ("Succeeded! 3 rows has been inserted by one query.");
         Print ("Rows affected: ", MySqlRowsAffected(DB)); // the only 1 should be shown
        }
     else
        {
         Print ("Error of multiple statements: ", MySqlErrorDescription);
        }

     Query = "UPDATE `test_table` SET id = id + 1 WHERE id in (2,3)";
     if (MySqlExecute(DB, Query))
        {
         Print ("Succeeded! 2 rows has been updated.");
         Print ("Rows affected: ", MySqlRowsAffected(DB)); // 2 should be shown
        }
     else
        {
         Print ("Error of multiple statements: ", MySqlErrorDescription);
        }
    }
 else
    {
     Print ("Table `test_table` cannot be created. Error: ", MySqlErrorDescription);
    }
 
 MySqlDisconnect(DB);
 Print ("Disconnected. Script done!");
}
//+------------------------------------------------------------------+
