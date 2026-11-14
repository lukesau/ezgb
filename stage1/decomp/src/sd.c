/* Stock stage1 SD reads through the FPGA's sector window at $A000.
 * 00:24E3-00:273D on FW4, $31 higher on FW5-0918. Same routine as the
 * kernel's DiskRead_B2. */
#include "hw.h"
#include "sd.h"

/* $C2AA: one sector, for reads that want part of one */
static UBYTE sector_buf[512];

/* 00:24E3 */
void FpgaSetSdWindow(UBYTE mode)
{
    FPGA_UNLOCK();
    FPGA_SD_MAP = mode;
    FPGA_COMMIT();
}

/* 00:2503: $E1 while the request is running, with $7F30 = 3 */
UBYTE SdWindowStatus(void)
{
    return WINDOW[0];
}

/* 00:250A: Petit FatFs asks for count bytes at offset in a sector. A whole
 * sector goes straight to buff; anything else is read into sector_buf and
 * the part copied out. */
void disk_readp_impl(UDWORD sector, UWORD offset, UWORD count, UBYTE *buff) BANKED
{
    if (count == 512) {
        DiskRead(sector, 1, buff);
    } else {
        DiskRead(sector, 1, sector_buf);
        memcpy(buff, sector_buf + offset, count);
    }
}

/* 00:2586: n sectors from lba, up to four per request.
 *
 * As stock has it, every chunk copies n sectors to the start of buf: buf
 * never advances and the length is n, not the chunk. Right for n = 1, the
 * only n stage1 uses. */
void DiskRead(UDWORD lba, UBYTE n, UBYTE *buf) BANKED
{
    UBYTE i, chunk;
    UDWORD sector;
    volatile UBYTE *reg;

    FpgaSetSdWindow(1);
    for (i = 0; i < n; i += 4) {
        if ((UWORD)n - i > 4)
            chunk = 4;
        else
            chunk = n - i;

        FPGA_UNLOCK();
        reg = (volatile UBYTE *)FPGA_SD_LBA;
        *reg = (UBYTE)lba + i;
        sector = lba + i;
        REG(FPGA_SD_LBA + 1) = (UBYTE)(sector >> 8);
        REG(FPGA_SD_LBA + 2) = (UBYTE)(sector >> 16);
        REG(FPGA_SD_LBA + 3) = (UBYTE)(sector >> 24);
        FPGA_SD_COUNT = chunk;
        FPGA_COMMIT();

        FpgaSetSdWindow(3);
        while (SdWindowStatus() == 0xE1)
            ;
        FpgaSetSdWindow(1);
        set_data(buf, (void *)WINDOW, (UWORD)n << 9);
    }
    FpgaSetSdWindow(0);
}
