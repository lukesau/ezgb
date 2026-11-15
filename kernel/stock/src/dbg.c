/* Banks 5, 6 and 9 start with this empty function, linked ahead of ff.c:
   EZ Flash's follow_path and f_mkdir pass it trace values, a debug print
   with its body compiled out. The name is ours. */

#include "integer.h"

void dbg_out (DWORD v)
{
	v;
}
