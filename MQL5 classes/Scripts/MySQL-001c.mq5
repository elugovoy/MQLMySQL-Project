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

#include <MQLMySQLClass.mqh>

string INI;
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
 CMySQL* DB1 = new CMySQL();
 CMySQL* DB2 = new CMySQL();
 CMySQL* DB3 = new CMySQL();
 
 string Host, User, Password, Database, Socket; // database credentials
 int Port,ClientFlag;
 
 Print (DB1.DllVersion());
 DB1.SetTrace(true); // Enable Trace for DB1

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
 Print ("Connect test 1: Set Database Credentials directly on Connect..."); 
 if (!DB1.Connect(Host, User, Password, Database, Port, Socket, ClientFlag))
 {
  Print ("Connection failed! Error: ", DB1.LastErrorMessage());
 }
 else 
 { 
  Print ("Connection succeeded! ID#", DB1.GetConnectID());
 }

 Print ("Connect test 2: Set Database Credentials before Connect...");
 DB2.SetCredentials(Host, User, Password, Database, Port, Socket, ClientFlag);
 if (!DB2.Connect()) 
 {
  Print ("Connection failed! Error: ", DB2.LastErrorMessage());
 } 
 else 
 {
  Print ("Connection succeeded! ID#", DB2.GetConnectID());
 }

 Print ("Connect test 3: Load Database Credentials from INI file before Connect...");
 DB3.LoadCredentials(INI);
 if (!DB3.Connect()) 
 {
  Print ("Connection failed! Error: ", DB3.LastErrorMessage());
 }
 else 
 {
  Print ("Connection succeeded! ID#", DB3.GetConnectID());
 }
 
 Print ("Disconnecting...");
 
 DB1.Disconnect();
 DB2.Disconnect();
 DB3.Disconnect();
 
 Print ("All connections closed. Script done!");
 
 delete DB1;
 delete DB2;
 delete DB3;
 
}
//+------------------------------------------------------------------+
