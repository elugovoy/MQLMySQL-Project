#define MAX_CONNECTIONS 32      // Maximum connections supported
#define MAX_CURSORS 256         // Maximum cursors can be opened concurrently (not depended on connections)
#define MAX_ERROR_DESC 1024     // Maximum length of error description (1024 wide chars)
#define MAX_FIELD_VALUE 32*1024 // Maximum length of field value can be returned to MQL (32Kb)
#define MAX_INIKEY_VALUE 256    // Size of buffer for INI key value (256 bytes)
#define MAX_QUERY_SIZE 65535    // Max size of SQL query


int  MySqlErrorNumber;
wchar_t MySqlErrorDescription[MAX_ERROR_DESC];

int  CursorErrorNumber;
wchar_t CursorErrorDescription[MAX_ERROR_DESC];

// database definition
struct CONNECTION
      {
        int     Id;
        MYSQL*  Connection;
        int     MySqlErrorNumber;
        wchar_t MySqlErrorDescription[MAX_ERROR_DESC];
      };

CONNECTION Connections[MAX_CONNECTIONS];

// cursor definition
struct CURSOR
      {
       int Id;
	   int Connection;
	   MYSQL_RES* RecordSet;
       MYSQL_ROW CurrentRow;
	   wchar_t Value[MAX_FIELD_VALUE]; // changed to 32Kb
       int  CursorErrorNumber;
       wchar_t CursorErrorDescription[MAX_ERROR_DESC];
      };

CURSOR Cursors[MAX_CURSORS];

// класс-оболочка, создающий и удал€ющий мютекс (Windows)
class CAutoMutex
{
  // дескриптор создаваемого мютекса
  HANDLE m_h_mutex;

  // запрет копировани€
  CAutoMutex(const CAutoMutex&);
  CAutoMutex& operator=(const CAutoMutex&);
  
public:
  CAutoMutex()
  {
    m_h_mutex = CreateMutexW(NULL, FALSE, L"FXCL-MYSQL");
    assert(m_h_mutex);
  }
  
  ~CAutoMutex() { CloseHandle(m_h_mutex); }
  
  HANDLE get() { return m_h_mutex; }
};

 // класс-оболочка, занимающий и освобождающий мютекс
class CMutexLock
{
  HANDLE m_mutex;

  // запрещаем копирование
  CMutexLock(const CMutexLock&);
  CMutexLock& operator=(const CMutexLock&);
public:
  // занимаем мютекс при конструировании объекта
  CMutexLock(HANDLE mutex): m_mutex(mutex)
  {
    const DWORD res = WaitForSingleObject(m_mutex, INFINITE);
    assert(res == WAIT_OBJECT_0);
  }
  // освобождаем мютекс при удалении объекта
  ~CMutexLock()
  {
    const BOOL res = ReleaseMutex(m_mutex);
    assert(res);
  }
};

// макрос, занимающий мютекс до конца области действи€
#define SCOPE_LOCK_MUTEX(hMutex) CMutexLock _tmp_mtx_capt(hMutex);

static CAutoMutex g_mutex;

void ClearErrors(int pId)
{
 if (pId == -1)
    {
     MySqlErrorNumber = 0;
     swprintf(MySqlErrorDescription, 11, L"No errors.\x00");
    }
 else
    {
     if ((pId>=0) && (pId<MAX_CONNECTIONS))
	    {
         Connections[pId].MySqlErrorNumber = 0;
         swprintf(Connections[pId].MySqlErrorDescription, 11, L"No errors.\x00"); 
        }
    }
}

void ClearCursorErrors(int pId)
{
 if (pId == -1)
    {
     CursorErrorNumber = 0;
     swprintf(CursorErrorDescription, 11, L"No errors.\x00");
    }
 else
    {
     if ((pId>=0) && (pId<MAX_CURSORS))
	    {
         Cursors[pId].CursorErrorNumber = 0;
         swprintf(Cursors[pId].CursorErrorDescription, 11, L"No errors.\x00"); 
        }
    }
}

// return free id in connections list
int GetNewConnectionId()
{
	for (int i=0; i<MAX_CONNECTIONS; i++)
		if (Connections[i].Id == -1) return (i);
	return(-1);
}

void DeleteConnection(int pId)
{
	if ((pId>=0) && (pId<MAX_CONNECTIONS))
	{
		Connections[pId].Id = -1;
	}
}

// initialization of all connections
void ConnectionsInit()
{
 // занимаем мютекс
 SCOPE_LOCK_MUTEX(g_mutex.get());

 for (int i=0; i<MAX_CONNECTIONS; i++)
     {
	  Connections[i].Id = -1;
	 }
}

// close all opened connections
void ConnectionsDeinit()
{
	ClearErrors(-1);

	for (int i=0; i<MAX_CONNECTIONS; i++)
	{
		if (Connections[i].Id != -1)
		{
			mysql_close(Connections[i].Connection);
			DeleteConnection(i);
		}
	}

}

// return free id in cursors list
int GetNewCursorId()
{
	for (int i=0; i<MAX_CURSORS; i++)
		if (Cursors[i].Id == -1) return (i);
	return(-1);
}

void DeleteCursor(int pId)
{
	if ((pId>=0) && (pId<MAX_CURSORS))
	{
		Cursors[pId].Id = -1;
	}
}

// initialization of all cursors
void CursorsInit()
{
 for (int i=0; i<MAX_CURSORS; i++)
     {
	  Cursors[i].Id = -1;
	 }
}

// close all opened cursors
void CursorsDeinit()
{
	ClearCursorErrors(-1);

	for (int i=0; i<MAX_CURSORS; i++)
	{
		if (Cursors[i].Id != -1)
		{
			mysql_free_result(Cursors[i].RecordSet);
			DeleteCursor(i);
		}
	}

}

