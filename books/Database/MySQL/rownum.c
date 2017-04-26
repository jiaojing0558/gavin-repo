#include <my_global.h>
#include <my_sys.h>

#if defined(MYSQL_SERVER)
#include <m_string.h>		/* To get strmov() */
#else
/* when compiled as standalone */
#include <string.h>
#define strmov(a,b) stpcpy(a,b)
#endif

#include <mysql.h>
#include <ctype.h>

/* 
 gcc -fPIC -Wall -I/mysql/mysql3306/include -I. -shared rownum.c -o rownum.so
 DROP FUNCTION IF EXISTS rownum;
 CREATE FUNCTION rownum RETURNS INTEGER SONAME 'rownum.so';
 */

C_MODE_START;

my_bool rownum_init(UDF_INIT *initid, UDF_ARGS *args, char *message);
 void rownum_deinit(UDF_INIT *initid);
longlong rownum(UDF_INIT *initid, UDF_ARGS *args, char *is_null,char *error);

C_MODE_END;



/*
  Simple example of how to get a sequences starting from the first argument
  or 1 if no arguments have been given
*/

my_bool rownum_init(UDF_INIT *initid, UDF_ARGS *args, char *message)
{
  if (args->arg_count > 1)
  {
    strmov(message,"This function takes none or 1 argument");
    return 1;
  }
  if (args->arg_count)
    args->arg_type[0]= INT_RESULT;		/* Force argument to int */

  if (!(initid->ptr=(char*) malloc(sizeof(longlong))))
  {
    strmov(message,"Couldn't allocate memory");
    return 1;
  }
  memset(initid->ptr, 0, sizeof(longlong));
  initid->const_item=0;
  return 0;
}

void rownum_deinit(UDF_INIT *initid)
{
  if (initid->ptr)
    free(initid->ptr);
}

longlong rownum(UDF_INIT *initid __attribute__((unused)), UDF_ARGS *args,char *is_null __attribute__((unused)),char *error __attribute__((unused)))
{
  ulonglong val=0;
  if (args->arg_count)
    val= *((longlong*) args->args[0]);
  return ++*((longlong*) initid->ptr) + val;
}