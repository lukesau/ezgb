
#include <gb/gb.h>
#include "ezgb_hw.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "main.h"
#include "Bank_fun.h"

#define GBcard_OP_BANK
#include "banks.h"

extern UINT16 ROMBankCount_real;
extern  UINT8 Header_Checksum;
extern void DrawHEX(unsigned long uc);
extern enum CartridgeTypes m_Type;
// --------------------------------------------------------------------
void ramfun_DMA_Response(/*UINT8 bootmode*/)
{
	UINT8 res;
  void (*restart)(void) NONBANKED = (void*)0x0100;
  
	HW_BEGIN();
	HW_DMA_CTRL = 3;
	HW_END(); 
	
	while(1)
	{
		res = HW_WINDOW_REG; 
		if(res != 0x00)
			break;
	}
	
	while(1)
	{
		res = HW_WINDOW_REG; 
		if(res != 0x01)
			break; 
	}
	HW_BEGIN();
	HW_DMA_CTRL = 0;
	HW_END();
	

	//BOOT
  HW_BEGIN();
	HW_BOOT_MODE = 0X00u;// game mode
	HW_BOOT_CFG = 0x00U;
	HW_END();
	
  *(volatile UINT8 *)0x2000 = 0x01U;
  *(volatile UINT8 *)0x3000 = 0x00U;
  
	
		HW_BEGIN();
		HW_RESET = 0X80u;// reset
		HW_END();  
  /*}
  else{
  		(*restart)();
  }	*/
}
// --------------------------------------------------------------------
static void mem_cpy (void* dst, const void* src, BYTE cnt) {
	BYTE *d = (BYTE*)dst;
	const BYTE *s = (const BYTE*)src;

	while (cnt--)
		*d++ = *s++;
}
// --------------------------------------------------------------------
void DMA_Response(/*UINT8 bootmode*/)
{

	void (*fun_in_ram)(/*UINT8 bootmode*/)  = (void*)0xD100;
  mem_cpy((void *)0xD100, (void *)&ramfun_DMA_Response, 0xFF);
	
	(*fun_in_ram)(/*bootmode*/) ;

	
}
// --------------------------------------------------------------------

// --------------------------------------------------------------------
void SetbufferControl(UINT8  control)
{
	HW_BEGIN();
	HW_DMA_CTRL = control;
	HW_END(); 
}
// --------------------------------------------------------------------
void SetTypesControl(UINT8  Types)__banked
{
	HW_BEGIN();
	HW_GB_TYPE = Types;
	HW_END(); 
}
// --------------------------------------------------------------------

// --------------------------------------------------------------------
	

// --------------------------------------------------------------------
void SetROMBankCount(UINT8 m_iROMSize )__banked
{ 
	UINT16 ROMBankCount;
  switch (m_iROMSize)
  {
      case 0x00://32KByte
          ROMBankCount = 0;
          break;
      case 0x01://64KByte
          ROMBankCount = 4-1;
          break; 	
      case 0x02://128KByte (8 banks)
          ROMBankCount = 8-1;
          break;
      case 0x03://256KByte (16 banks)
          ROMBankCount = 16-1;
          break;
      case 0x04://512KByte (32 banks)
          ROMBankCount = 32-1;
          break;
      case 0x05://1MByte (64 banks)
          ROMBankCount = 64-1;
          break; 	
      case 0x06://2MByte (128 banks) 
          ROMBankCount = 128-1;
          break;
      case 0x07://4MByte (256 banks)
          ROMBankCount = 256-1;
          break;
      case 0x08:
          ROMBankCount = 512-1;
          break;
      case 0x52://1.1MByte (72 banks)
          ROMBankCount = 72-1;
          break;
      case 0x53://1.2MByte (80 banks)
          ROMBankCount = 80-1;
          break;
      case 0x54://1.5MByte (96 banks)
          ROMBankCount = 96-1;
          break;  
          
          
      default:
          ROMBankCount = 0;
          break;
  }
  
	if(ROMBankCount < (ROMBankCount_real-1))
	{
		if(ROMBankCount_real & 0x1)
			ROMBankCount = 0x1;
		if(ROMBankCount_real & 0x2)
			ROMBankCount = 0x3;
		if(ROMBankCount_real & 0x4)
			ROMBankCount = 0x7;
		if(ROMBankCount_real & 0x8)
			ROMBankCount = 0xF;	
		if(ROMBankCount_real & 0x10)
			ROMBankCount = 0x1F;
		if(ROMBankCount_real & 0x20)
			ROMBankCount = 0x3F;
		if(ROMBankCount_real & 0x40)
			ROMBankCount = 0x7F;
		if(ROMBankCount_real & 0x80)
			ROMBankCount = 0xFF;			
		if(ROMBankCount_real & 0x100)
			ROMBankCount = 0x1FF;			
						
	}
  	
  	
  HW_BEGIN();
	HW_ROM_BANKS_LO = ROMBankCount;
	HW_END(); 
	
  HW_BEGIN();
	HW_ROM_BANKS_HI = ROMBankCount>>8;
	HW_END(); 
	
}	
// --------------------------------------------------------------------
// --------------------------------------------------------------------
void SetRAMBankCount(UINT8 m_iRAMSize )__banked
{ 
	UINT8 RAMBankCount;
  switch (m_iRAMSize)
  {
      case 0x00:
      		if(m_Type==CartridgeMBC2)
					{
						RAMBankCount= 0;	
					}
					else {
          	RAMBankCount = 0;//
          }
          break;
      case 0x01:
      case 0x02:
          RAMBankCount = 0;//8KB
          break;
      case 0x04:
          RAMBankCount = 0x10-1;//128KB
          break;
      case 0x05:
          RAMBankCount = 0x8-1;//64KB Pocket Monsters - Crystal Version (Japan)  
          break;    		
      default:
          RAMBankCount = 0x4-1;//32KB
          break;
  }		
  	
  	
  HW_BEGIN();
	HW_RAM_BANKS = RAMBankCount;
	HW_END(); 
	 
	
}	
// --------------------------------------------------------------------
void SetROMHeader_Checksum(void)__banked
{ 	
  HW_BEGIN();
	HW_HDR_CHECKSUM = Header_Checksum;
	HW_END(); 
	
 
}	
// --------------------------------------------------------------------
// --------------------------------------------------------------------
/* The bootmode parameter was removed: DMA_Response() never used its argument,
   and callers passed GatherMetadata's FRESULT there, which was misleading. */
void Send_FATbuffer(UINT8*buffer)__banked
{	
	UINT16 i;
	
	SetbufferControl(1);

	
	set_data(Base_FATbuffer,buffer,0x200);
	DMA_Response(/*bootmode*/);
}
// --------------------------------------------------------------------