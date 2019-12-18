//+-----------------------------------------------------------------+
//|                                                    MQLMySQL.c++ |
//|                                Copyright © 2013, Eugene Lugovoy |
//|                   http://www.odesk.com/users/~~2f05fc596039cd45 |
//+-----------------------------------------------------------------+

/********************************************************************
 * MQLMySQL wrapper library for MetaTrader 4                        *
 ********************************************************************
 * This library uses LIBMYSQL.DLL you may find in any MySQL related *
 * software, or from MySQL distribution package.                    *
 * Be sure about version of LIBMYSQL.DLL, it must be the same with  *
 * database version you have to use. Otherwise MetaTrader terminal  *
 * can be crashed (by fatal error of DLL).                          *
 * Note: Check expert advisor "Common" parameters to be sure that   *
 *       DLL imports are allowed.                                   *
 ********************************************************************/

#define WIN32_LEAN_AND_MEAN  // Exclude rarely-used stuff from Windows headers
#define MT4_EXPFUNC __declspec(dllexport)
#define _USE_INLINING
#define TRACE

#include <assert.h>
#include <locale.h>
#include <windows.h>
#include <stdlib.h>
#include <stdio.h>
#include <atlstr.h>
#include <mysql.h>

#ifdef _WIN64
#pragma comment(lib, "..\\MySQL-8.0.18 x64\\libmysql.lib")
#define LIB_VERSION L"MQLMySQL v3.0 x64 Copyright © 2014-2019, FxCodex Laboratory\x00"
#else
#pragma comment(lib, "..\\MySQL-5.7.28 x32\\libmysql.lib")
#define LIB_VERSION L"MQLMySQL v3.0 x32 Copyright © 2014-2019, FxCodex Laboratory\x00"
#endif
//----

#include "MQLMySQL.h"
wchar_t WideNull[1];
wchar_t buffer[MAX_INIKEY_VALUE];

// just for compatibility
BOOL APIENTRY DllMain(HANDLE hModule,DWORD ul_reason_for_call,LPVOID lpReserved)
{
	switch(ul_reason_for_call)
	{
	case DLL_PROCESS_ATTACH: WideNull[0] = 0; ConnectionsInit(); CursorsInit(); break;
	case DLL_THREAD_ATTACH: break;
	case DLL_THREAD_DETACH: break;
	case DLL_PROCESS_DETACH: ConnectionsDeinit(); CursorsDeinit(); break;
   }
   return(TRUE);
}

// return version of MySqlCursor.DLL
MT4_EXPFUNC wchar_t* __stdcall cMySqlVersion()
{
	return (LIB_VERSION);
}


MT4_EXPFUNC int __stdcall cGetMySqlErrorNumber(int pConnection)
{
	if ((pConnection<0) || (pConnection>=MAX_CONNECTIONS)) {return (MySqlErrorNumber);}
	if (Connections[pConnection].Id == -1) {return (MySqlErrorNumber);}
	return (Connections[pConnection].MySqlErrorNumber);
}

MT4_EXPFUNC wchar_t* __stdcall cGetMySqlErrorDescription(int pConnection)
{
	if ((pConnection<0) || (pConnection>=MAX_CONNECTIONS)) {return (MySqlErrorDescription);}
	if (Connections[pConnection].Id == -1) {return (MySqlErrorDescription);}
	return (Connections[pConnection].MySqlErrorDescription);
}

MT4_EXPFUNC int __stdcall cGetCursorErrorNumber(int pCursor)
{
	if ((pCursor<0) || (pCursor>=MAX_CURSORS)) {return (CursorErrorNumber);}
	if (Cursors[pCursor].Id == -1) {return (CursorErrorNumber);}
	return (Cursors[pCursor].CursorErrorNumber);
}

MT4_EXPFUNC wchar_t* __stdcall cGetCursorErrorDescription(int pCursor)
{
	if ((pCursor<0) || (pCursor>=MAX_CURSORS)) {return (CursorErrorDescription);}
	if (Cursors[pCursor].Id == -1) {return (CursorErrorDescription);}
	return (Cursors[pCursor].CursorErrorDescription);
}

// return connection id
MT4_EXPFUNC int __stdcall cMySqlConnect(wchar_t* pHost, wchar_t* pUser, wchar_t* pPassword, wchar_t* pDatabase, int pPort, wchar_t* pSocket, int pClientFlag)
{
 // занимаем мютекс
 SCOPE_LOCK_MUTEX(g_mutex.get());

 char xHost[1024];
 char xUser[32];
 char xPassword[32];
 char xDatabase[32];
 char xSocket[64];

 ClearErrors(-1);
 int cnn = GetNewConnectionId();
 MYSQL* mysql = 0;
 
 if (cnn<0 || cnn>=MAX_CONNECTIONS)
    {
     MySqlErrorNumber = -3;
	 swprintf(MySqlErrorDescription, MAX_ERROR_DESC, L"%s", L"Maximum connections exceeded.");
     return(-1);
    }

 setlocale(LC_ALL, "");
 sprintf_s(xHost, wcslen(pHost)+1, "%S", pHost);
 sprintf_s(xUser, wcslen(pUser)+1, "%S", pUser);
 sprintf_s(xPassword, wcslen(pPassword)+1, "%S", pPassword);
 sprintf_s(xDatabase, wcslen(pDatabase)+1, "%S", pDatabase);
 sprintf_s(xSocket, wcslen(pSocket)+1, "%S", pSocket);
 
 mysql = mysql_init(mysql);
 if (mysql)
    {
     // memory allocated successful
     Connections[cnn].Connection = mysql_real_connect(mysql, xHost, xUser, xPassword, xDatabase, pPort, xSocket, pClientFlag);
     if (Connections[cnn].Connection != mysql) 
        {
         MySqlErrorNumber = mysql_errno(mysql);
		 swprintf(MySqlErrorDescription, MAX_ERROR_DESC, L"%S", mysql_error(mysql));
         return(-1);
        }
    }
 else
    {
     MySqlErrorNumber = -1;
	 swprintf(MySqlErrorDescription, MAX_ERROR_DESC, L"%s", L"Cannot allocate memory for connection.");
     return(-1);
    }

 Connections[cnn].Id = cnn;
 return (cnn);
}

MT4_EXPFUNC void __stdcall cMySqlDisconnect(int pConnection)
{
	ClearErrors(pConnection);
	if ((pConnection<0) || (pConnection>=MAX_CONNECTIONS))
	   {
        MySqlErrorNumber = -2;
		swprintf(MySqlErrorDescription, 32, L"No connection to the database.\x00");
		return;
	   }
	if (Connections[pConnection].Id == -1)
	   {
        MySqlErrorNumber = -2;
		swprintf(MySqlErrorDescription, 32, L"No connection to the database.\x00");
		return;
	   }
	mysql_close(Connections[pConnection].Connection);
	DeleteConnection(pConnection);
}

// internal function - should not be exported
// used to execute SELECT statements
bool __stdcall MySqlExecute(int pConnection, wchar_t* pQuery)
{
	ClearErrors(pConnection);
	if (pConnection == -1) 
	{
		// no connection
		MySqlErrorNumber = -2;
		swprintf(MySqlErrorDescription, 32, L"No connection to the database.\x00");
		return (false);
    }
	char    Query[MAX_QUERY_SIZE];

	int unicodeLen = WideCharToMultiByte(CP_UTF8, 0, pQuery, -1, NULL, 0, NULL, NULL);
	
	if (unicodeLen < MAX_QUERY_SIZE)
	{
		WideCharToMultiByte(CP_UTF8, 0, pQuery, -1, Query, unicodeLen, NULL, NULL);
	}
	else
	{
		MySqlErrorNumber = -6;
		swprintf(MySqlErrorDescription, 32, L"Query is too big\x00");
		return (false);
	}

	//sprintf_s(Query, wcslen(pQuery)+1, "%S", pQuery); //
	
	//MessageBoxA(0, Connections[pConnection].Query, "MySqlExecute", 0);
 
	mysql_real_query(Connections[pConnection].Connection, (LPCSTR)Query, (unsigned long)strlen(Query));

	//MessageBoxA(0, "Executed", "MySqlExecute", 0);

	Connections[pConnection].MySqlErrorNumber = mysql_errno(Connections[pConnection].Connection);

	if (MySqlErrorNumber > 0)
	{
		swprintf(Connections[pConnection].MySqlErrorDescription, MAX_ERROR_DESC, L"%S", mysql_error(Connections[pConnection].Connection));
		return (false);
	}
	return (true);
}

MT4_EXPFUNC bool __stdcall cMySqlExecute(int pConnection, wchar_t* pQuery)
{
	ClearErrors(pConnection);
	unsigned int err;
	bool Result = false;
	MYSQL_RES* RSet = 0;
	if (pConnection == -1) 
	{
		// no connection
		MySqlErrorNumber = -2;
		swprintf(MySqlErrorDescription, 32, L"No connection to the database.\x00");
		return (false);
    }

	//MessageBoxW(0, pQuery, L"cMySqlExecute", 0);
	// MYSQL_ROW  Row;
	// execute query
	if (MySqlExecute(pConnection, pQuery))
    {
		Result = true;
		RSet = mysql_use_result(Connections[pConnection].Connection);
        // workround regarding to MySQL bug: http://forums.mysql.com/read.php?108,258968,259554#msg-259554
		// solution on PHP was implemented here, you may find: http://php.net/manual/en/mysqli.multi-query.php
		do 
		{
			if ((RSet = mysql_store_result(Connections[pConnection].Connection)) !=0)
			{
				mysql_free_result(RSet);
			}
			if (mysql_more_results(Connections[pConnection].Connection)==0) break;
		} while (mysql_next_result(Connections[pConnection].Connection)==0);

		err = mysql_errno(Connections[pConnection].Connection);
		if (err>0)
		{
			Result = false;
			Connections[pConnection].MySqlErrorNumber = err;
            swprintf(Connections[pConnection].MySqlErrorDescription, MAX_ERROR_DESC, L"%S", mysql_error(Connections[pConnection].Connection));
		}
		mysql_free_result(RSet);
    }
 return (Result);
}

// create cursor for data fetching
// return value is CURSOR IDENTIFIER when succeded,
// othervise return value = -1
MT4_EXPFUNC int __stdcall cMySqlCursorOpen(int pConnection, wchar_t* pQuery)
{
	SCOPE_LOCK_MUTEX(g_mutex.get());

	ClearErrors(pConnection);
	ClearCursorErrors(-1);
	if (pConnection == -1) 
	{
		// no connection
		MySqlErrorNumber = -2;
		swprintf(MySqlErrorDescription, 32, L"No connection to the database.\x00");
		return (-1);
    }

	int cur;
	cur = GetNewCursorId();
	if (cur>=0)
       {
		Cursors[cur].RecordSet = 0;
        // execute query
	    if (MySqlExecute(pConnection, pQuery))
           {
			Cursors[cur].RecordSet = mysql_store_result(Connections[pConnection].Connection);
           }

	    if (Cursors[cur].RecordSet!=0) // no error
           {
			   Cursors[cur].Id = cur;
			   Cursors[cur].Connection = pConnection;
           }
		else
		   {
            Connections[pConnection].MySqlErrorNumber = mysql_errno(Connections[pConnection].Connection);
	        if (Connections[pConnection].MySqlErrorNumber>0)
		       {
				DeleteCursor(cur);
				cur = -1;
                swprintf(Connections[pConnection].MySqlErrorDescription, MAX_ERROR_DESC, L"%S", mysql_error(Connections[pConnection].Connection));
  		       }
		   }
	   }
	else
       {
		cur = -1;
		Connections[pConnection].MySqlErrorNumber = -3;
		swprintf(Connections[pConnection].MySqlErrorDescription, 50, L"Maximum number of opened cursors was exceeded.\x00");
	   }
 return (cur);
}

// closes opened cursor and release memory
MT4_EXPFUNC void __stdcall cMySqlCursorClose(int pCursorID)
{
	SCOPE_LOCK_MUTEX(g_mutex.get());
	ClearCursorErrors(pCursorID);
 	if ((pCursorID >= 0) && (pCursorID<MAX_CURSORS) && (Cursors[pCursorID].Id!=-1))
 	{
		mysql_free_result(Cursors[pCursorID].RecordSet); // no error handling for this function
		DeleteCursor(pCursorID);
	}
	else
	{
		CursorErrorNumber = -5;
		swprintf(CursorErrorDescription, 32, L"Wrong CURSOR identifier.\x00");
	}
}

// return count of rows was selected into cursor
MT4_EXPFUNC int __stdcall cMySqlCursorRows(int pCursorID)
{
	ClearCursorErrors(pCursorID);
 	if ((pCursorID >= 0) && (pCursorID<MAX_CURSORS) && (Cursors[pCursorID].Id!=-1))
 	{
		return (int(mysql_num_rows(Cursors[pCursorID].RecordSet)));
	}
	else
	{
		CursorErrorNumber = -5;
		swprintf(CursorErrorDescription, 32, L"Wrong CURSOR identifier.\x00");
	}

	return (0);
}

// fetch 1 row from record set into cursor's buffer
MT4_EXPFUNC bool __stdcall cMySqlCursorFetchRow(int pCursorID)
{
	ClearCursorErrors(pCursorID);
 	if ((pCursorID >= 0) && (pCursorID<MAX_CURSORS) && (Cursors[pCursorID].Id!=-1))
 	{
		Cursors[pCursorID].CurrentRow = mysql_fetch_row(Cursors[pCursorID].RecordSet);
	    if (Cursors[pCursorID].CurrentRow == 0) // error
		{
			Cursors[pCursorID].CursorErrorNumber = mysql_errno(Connections[Cursors[pCursorID].Connection].Connection);
            swprintf(Cursors[pCursorID].CursorErrorDescription, MAX_ERROR_DESC, L"%S", mysql_error(Connections[Cursors[pCursorID].Connection].Connection));
			return (false);
		}
		return(true);
    }
	else
	{
		CursorErrorNumber = -5;
		swprintf(CursorErrorDescription, 32, L"Wrong CURSOR identifier.\x00");
	}
	return (false);
}

// return string representation of field's value
// should be called after MySqlCursorFetchRow()
// pCursorID - CURSOR IDENTIFIER
// pField    - number of field from SELECT list (started from 0) - 0,1,2 e.t.c.
MT4_EXPFUNC wchar_t* __stdcall cMySqlGetRowField(int pCursorID, unsigned int pField)
{
	SCOPE_LOCK_MUTEX(g_mutex.get());
	if ((pCursorID >= 0) && (pCursorID < MAX_CURSORS) && (Cursors[pCursorID].Id!=-1))
 	{
        ClearCursorErrors(pCursorID);
		if ((pField >= 0) && (pField < mysql_num_fields(Cursors[pCursorID].RecordSet)))
		{
			Cursors[pCursorID].Value[0] = 0;
			int unicodeLen = MultiByteToWideChar(CP_UTF8, 0, Cursors[pCursorID].CurrentRow[pField], -1, nullptr, 0);
			if (unicodeLen <= MAX_FIELD_VALUE)
			{
				MultiByteToWideChar(CP_UTF8, 0, Cursors[pCursorID].CurrentRow[pField], -1, Cursors[pCursorID].Value, unicodeLen);
				return (Cursors[pCursorID].Value);
			}
			else
			{
				Cursors[pCursorID].CursorErrorNumber = -6;
				swprintf(Cursors[pCursorID].CursorErrorDescription, 32, L"Result value is too big\x00");
				return (WideNull);
			}
		}
		else
		{
			Cursors[pCursorID].CursorErrorNumber = -4;
            swprintf(Cursors[pCursorID].CursorErrorDescription, 32, L"Wrong number of field.\x00");
		}
	}
	else
	{
		CursorErrorNumber = -5;
		swprintf(CursorErrorDescription, 32, L"Wrong CURSOR identifier.\x00");
	}
 return (WideNull);
}

MT4_EXPFUNC int __stdcall cMySqlRowsAffected(int pConnection)
{
	int Result = 0;
    if (pConnection == -1) 
	{
		// no connection
		MySqlErrorNumber = -2;
		swprintf(MySqlErrorDescription, 32, L"No connection to the database.\x00");
		return (0);
    }

	Result = (int)mysql_affected_rows(Connections[pConnection].Connection);
	return (Result);
}

// Reads and returns the key value from standard INI-file
// [SECTION]
// Key = Value
// pFileName - name of file
// pSection  - name of section '[SECTION]'
// pKey      - name of key 'Key ='
// @return   - string value of key 'Value'
MT4_EXPFUNC wchar_t* __stdcall WINAPI ReadIni (wchar_t* pFileName, wchar_t* pSection, wchar_t* pKey)
{
 SCOPE_LOCK_MUTEX(g_mutex.get());
 int x;
 buffer[0] = 0;
 x = GetPrivateProfileStringW(pSection, pKey, L"", buffer, MAX_INIKEY_VALUE-1, pFileName);
 buffer[x] = 0;

 return (buffer);
}
