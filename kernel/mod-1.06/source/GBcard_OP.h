
#include <gb/gb.h>
#include "ezgb_hw.h"



// --------------------------------------------------------------------
extern void SetNORpage(UINT8 NORpage)__banked;
extern void Soft_reset(void)__banked;
extern void Send_FATbuffer(UINT8*buffer)__banked;
extern void SetTypesControl(UINT8  Types)__banked;
extern void SetROMBankCount(UINT8 m_iROMSize )__banked;
extern void SetROMHeader_Checksum(void)__banked;
extern void SetRAMBankCount(UINT8 m_iRAMSize )__banked;
// --------------------------------------------------------------------