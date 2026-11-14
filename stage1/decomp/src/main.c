/* Stock stage1 main.c: the boot screen, mounting the SD card, the load
 * command for EZGB.DAT, and the hand-off.
 *
 * Reconstructed from the FW4 and FW5-0918 disassemblies. Addresses in the
 * comments are FW4 / FW5-0918. FW5-0918 differs from FW4 only in this file:
 * FpgaSetBootCpu() and two lines in main(), marked FW == 5. Everything after
 * main() in bank 0 is the same code $31 bytes higher.
 *
 * Build with -DFW=4 or -DFW=5. */
#include "hw.h"
#include "pff.h"
#include "handoff.h"

#ifndef FW
#error "build with -DFW=4 or -DFW=5"
#endif

/* $C0A0: the load command, built here and copied to the FPGA's window by
 * LoadKernel(). First in RAM: main.c's globals are linked first. */
UBYTE LoadCmd[512];

/* $C2A0-$C2A7. Initialized by InitMessages (01:4134), the startup code the
 * compiler made for these, which crt0 calls before main(). */
UBYTE *msg_not_found1 = "ezgb.dat not found  on SD card";
UBYTE *msg_not_found2 = "Please download it ";
UBYTE *msg_not_found3 = "from www.ezflash.cn";
char  *msg_sd_error   = "Micro SD initial error!";

/* 00:05BC: puts() without GBDK's, one putchar() at a time. Unused. */
void PrintLine(char *s)
{
    while (*s)
        putchar(*s++);
    putchar('\n');
}

/* 00:05E9: K&R itoa() into s, then the digits reversed into a local buffer
 * and printed. Unused, and wrong twice: the reverse copy reads s[-1] into
 * the last place instead of a terminator, and the buffer has room for
 * five characters. */
void PrintNumber(int n, char *s)
{
    int i, j, sign;
    char buf[5];

    if ((sign = n) < 0)
        n = -n;
    i = 0;
    do {
        s[i++] = n % 10 + '0';
    } while ((n /= 10) > 0);
    if (sign < 0)
        s[i++] = '-';
    s[i] = 0;

    for (j = i; j >= 0; j--)
        buf[(UBYTE)(i - j)] = s[j - 1];
    PrintLine(buf);
}

/* 00:071C: wait for B alone, then 200 ms. Unused. */
void WaitButtonB(void)
{
    while (joypad() != J_B)
        ;
    delay(200);
}

/* 00:073B */
void FpgaSetMode(UBYTE mode)
{
    FPGA_UNLOCK();
    FPGA_SRAM_MAP = mode;
    FPGA_COMMIT();
}

/* 00:075B: enter the kernel the way HandoffPoll() ends, without loading it
 * first. Unused, except as the code RunFromWram() copies. kernel.sym had it
 * at $0752, inside FpgaSetMode(); RunFromWram() copies from $075B. */
void BootRomDirect(void)
{
    FPGA_UNLOCK();
    FPGA_7F31 = 0;
    FPGA_MODE = 0x80;
    FPGA_COMMIT();
    ENTRY_0100();
    while (1)
        ;
}

/* 00:0786: BootRomDirect() from WRAM, since cart space changes under it.
 * Unused. Copies 256 bytes, more than BootRomDirect() is. */
void RunFromWram(void)
{
    ROMB0 = 1;
    ROMB1 = 0;
    memcpy((void *)0xD000, (void *)BootRomDirect, 0x100);
    ((void (*)(void))0xD000)();
}

/* 00:07A7: eight blank lines. Unused. */
void PrintBlankLines(void)
{
    puts(" ");
    puts(" ");
    puts(" ");
    puts(" ");
    puts(" ");
    puts(" ");
    puts(" ");
    puts(" ");
}

#if FW == 5
/* FW5 00:07F1: the console's boot A to $7FD3, half of the fast-load key.
 * A color console's $11 there (and $11 at $7FD4, which stock FW5 never
 * writes) skips the loader's delay. */
void FpgaSetBootCpu(UBYTE cpu)
{
    FPGA_UNLOCK();
    FPGA_BOOT_CPU = cpu;
    FPGA_COMMIT();
}
#endif

const char KernelFileName[] = "EZGB.DAT";   /* 00:0B4D / 00:0B7E */

/* Load command offsets (../stock.md#the-load-command) */
#define CMD_FILE_SIZE  0x1F0
#define CMD_ONE        0x1F4
#define CMD_CSIZE      0x1F8


/* 00:07F1 / 00:0811 */
void main(void)
{
    FATFS fs;              /* sp+$30, 42 bytes */
    UBYTE unused[20];      /* sp+$1C-$2F: allocated, never touched */
    UDWORD *p;             /* sp+$1A */
    UDWORD clst;           /* sp+$16 */
    UDWORD prev;           /* sp+$12 */
    UDWORD eoc;            /* sp+$0E */
    UDWORD fsize;          /* sp+$0A */
    FRESULT res;           /* register c */
    UWORD  clusters;       /* sp+$08: clusters walked so far */
    /* sp+$00-$07: the compiler's temporaries (call results, &p[0x7E]) */

    (void)unused;

#if FW == 5
    rNR52 = 0;             /* sound off */
#endif
    puts(" \n\n\n\n\n\n\n");
    puts("      EZ-FLASH");
    delay(700);
#if FW == 5
    FpgaSetBootCpu(_cpu);
#endif
    puts("\n\n\n\nLOADING...");
    FpgaSetMode(0);

    res = pf_mount(&fs);
    if (res != FR_OK) {
        puts(msg_sd_error);
        while (1)
            ;
    }
    res = pf_open(KernelFileName);
    if (res != FR_OK) {
        puts(msg_not_found1);
        puts(msg_not_found2);
        puts(msg_not_found3);
        while (1)
            ;
    }
    puts("OSINIT...");

    /* End of chain. FAT12 is not handled: it gets FAT32's marker. */
    if (FsType() == FS_FAT16)
        eoc = 0x0000FFFF;
    else
        eoc = 0x0FFFFFF7;

    clst = FsFileCluster();
    fsize = FsFileSize();

    /* {end, lba} pairs, where end is the running total of file sectors
     * before the extent. The first end is 0. */
    p = (UDWORD *)LoadCmd;
    *p++ = 0;
    *p++ = clust2sect(clst);
    prev = clst;
    clusters = 0;

    /* Nothing bounds the extents: past 61 they run into the tail fields,
     * then $C2A0. The sector total is a 16-bit product, so it wraps at
     * 65536 sectors (32 MB). */
    do {
        clst = FsNextCluster(clst);
        clusters++;
        if (clst != prev + 1) {
            *p++ = (UWORD)(clusters * FsClusterSectors());
            *p++ = clust2sect(clst);
        }
        prev = clst;
    } while (clst < eoc);

    /* The walk ends with an extent for the end-of-chain marker. Its lba
     * becomes the 0 that closes the table, and its end $FFFFFFFF. */
    p--;
    *p = 0;
    p--;
    *p = 0xFFFFFFFF;

    p = (UDWORD *)LoadCmd;
    p[CMD_FILE_SIZE / 4] = fsize;
    p[CMD_ONE / 4] = 1;
    p[CMD_CSIZE / 4] = FsClusterSectors();

    FpgaSetMode(2);
    disable_interrupts();
    LoadKernel(LoadCmd);
}
