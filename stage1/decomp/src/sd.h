#ifndef SD_H
#define SD_H

#include "gb.h"

void  FpgaSetSdWindow(UBYTE mode);
UBYTE SdWindowStatus(void);
void  disk_readp_impl(UDWORD sector, UWORD offset, UWORD count, UBYTE *buff);
void  DiskRead(UDWORD lba, UBYTE n, UBYTE *buf);

#endif
