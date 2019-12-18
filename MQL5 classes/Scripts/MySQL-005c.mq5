//+------------------------------------------------------------------+
//|                                                    MySQL-005.mq5 |
//|                                   Copyright 2014, Eugene Lugovoy |
//|                                              http://www.mql5.com |
//| Reaching cursors limit (DEMO)                                    |
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
 CMQLMySQL *DB = new CMQLMySQL(); // database object
 
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
 CMQLCursor *Cursor1 = new CMQLCursor(), *Cursor2 = new CMQLCursor(), *Cursor3 = new CMQLCursor(), *Cursor4 = new CMQLCursor();
 Query = "SELECT * FROM `test_table` LIMIT 1";

 if (Cursor1.Open(DB, Query)) {Print ("Cursor 1 was opened.");} else {Print ("Cursor 1 failed. Error: ", Cursor1.LastErrorMessage());}
 
 if (Cursor2.Open(DB, Query)) {Print ("Cursor 2 was opened.");} else {Print ("Cursor 2 failed. Error: ", Cursor2.LastErrorMessage());}

 if (Cursor3.Open(DB, Query)) {Print ("Cursor 3 was opened.");} else {Print ("Cursor 3 failed. Error: ", Cursor3.LastErrorMessage());}

 if (Cursor4.Open(DB, Query)) {Print ("Cursor 4 was opened.");} else {Print ("Cursor 4 failed. Error: ", Cursor4.LastErrorMessage());}
 
 Print ("Closing cursors...");
 Cursor1.Close();
 Cursor2.Close();
 Cursor3.Close();
 Cursor4.Close();
 Print ("Passed!");
 
 DB.Disconnect();
 Print ("Disconnected. Script done!");
 
 delete Cursor1;
 delete Cursor2;
 delete Cursor3;
 delete Cursor4;
 
 delete DB;
}
//+------------------------------------------------------------------+
