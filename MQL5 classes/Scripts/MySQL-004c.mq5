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

 // executing SELECT statement
 string Query;
 int    i,Rows;
 
 int      vId;
 string   vCode;
 datetime vStartTime;
 
 Query = "SELECT id, code, start_date FROM `test_table`";
 Print ("SQL> ", Query);
 
 CMySQLCursor *Cursor = new CMySQLCursor();
 
 if (Cursor.Open(DB, Query))
    {
     Rows = Cursor.Rows();
     Print (Rows, " row(s) selected.");
     for (i=0; i<Rows; i++)
         if (Cursor.Fetch())
            {
             vId = Cursor.FieldAsInt(0); // id
             vCode = Cursor.FieldAsString(1); // code
             vStartTime = Cursor.FieldAsDatetime(2); // start_time
             Print ("ROW[",i,"]: id = ", vId, ", code = ", vCode, ", start_time = ", TimeToString(vStartTime, TIME_DATE|TIME_SECONDS));
            }
     Cursor.Close(); // NEVER FORGET TO CLOSE CURSOR !!!
    }
 else
    {
     Print ("Cursor opening failed. Error: ", Cursor.LastErrorMessage());
    }
 
 delete Cursor;
 
 DB.Disconnect();
 Print ("Disconnected. Script done!");
 
 delete DB;
}
//+------------------------------------------------------------------+
