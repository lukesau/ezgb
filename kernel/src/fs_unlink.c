/* f_unlink for the kernel's FatFs, which was built without it
 * (docs/save-manager.md "Delete").
 *
 * Bank 9, injected at 09:7cc0, next to the bank's own copy of the FatFs
 * internals, which it calls directly: this is R0.10's f_unlink and
 * dir_remove written against the kernel's structures, with only regular
 * files allowed (no directories, nothing read-only). Far target of the
 * SoUnlink stub in bank 1 (save_ops.c); FarCallTrampoline puts the first
 * real argument at sp+6, so two pad parameters.
 *
 * Structures, from Open_B9 (which is really f_mkdir: it starts with
 * get_fattime and turns FR_OK from follow_path into FR_EXIST):
 *
 *   DIR (26 bytes): fs +$00, index +$04, sclust +$06, clust +$0a,
 *     sect +$0e, dir +$12, fn +$14 (a 12-byte buffer on the caller's stack),
 *     lfn +$16 (LfnBuf, $c5a9), lfn_idx +$18
 *   FATFS: wflag +$04, fsi_flag +$05, free_clust +$0e (winsect is +$2e:
 *     R0.10 with _FS_RPATH)
 *
 * The free-cluster count is left unknown ($FFFFFFFF) for FSInfo. This
 * kernel's mount starts free_clust at 0 instead of reading FSInfo, so an
 * allocation makes it $FFFFFFFF ("unset" on the card, which hosts recount)
 * but a free with no allocation before it counts up from 0, and sync_fs
 * then wrote that (65 after deleting a 32 KB file) as the card's free space.
 *
 * Internal signatures (sdcccall 0; argument sizes checked against the
 * `add sp` after every call in bank 9):
 *
 *   find_volume(FATFS **rfs, const TCHAR **path, BYTE wmode)
 *   follow_path(DIR *dp, const TCHAR *path)
 *   dir_sdi(DIR *dp, UINT idx), dir_next(DIR *dp, int stretch)
 *   move_window(FATFS *fs, DWORD sector)
 *   ld_clust(FATFS *fs, BYTE *dir), remove_chain(FATFS *fs, DWORD clst)
 *   sync_fs(FATFS *fs)
 *
 *   python3 tools/inject.py src/fs_unlink.c $V 9 7cc0 FsUnlink \
 *       --pin FindVolume_B9=76f7 --pin FollowPath_B9=72c5 --pin DirSdi_B9=54db \
 *       --pin DirNext_B9=580c --pin MoveWindow_B9=437e --pin LdClust_B9=5d72 \
 *       --pin RemoveChain_B9=4f94 --pin SyncFs_B9=4447 --apply
 */

#include "types.h"

extern u8 FindVolume_B9(u8 **rfs, const u8 **path, u8 wmode);
extern u8 FollowPath_B9(u8 *dp, const u8 *path);
extern u8 DirSdi_B9(u8 *dp, u16 idx);
extern u8 DirNext_B9(u8 *dp, int stretch);
extern u8 MoveWindow_B9(u8 *fs, u32 sector);
extern u32 LdClust_B9(u8 *fs, u8 *dir);
extern u8 RemoveChain_B9(u8 *fs, u32 clst);
extern u8 SyncFs_B9(u8 *fs);

#define LFN_BUF   ((u8 *)0xC5A9)
#define D_FS(d)   (*(u8 **)(d))
#define D_INDEX(d) (*(u16 *)((d) + 0x04))
#define D_SECT(d) (*(u32 *)((d) + 0x0e))
#define D_DIR(d)  (*(u8 **)((d) + 0x12))
#define D_FN(d)   (*(u8 **)((d) + 0x14))
#define D_LFN(d)  (*(u8 **)((d) + 0x16))
#define D_LFNIDX(d) (*(u16 *)((d) + 0x18))
#define FS_WFLAG  4
#define FS_FSI    5
#define FS_FREE(f) (*(u32 *)((f) + 0x0e))
#define DIR_ATTR  11
#define AM_RDO    0x01
#define AM_DIR    0x10
#define DDEM      0xE5
#define FR_NO_FILE 4
#define FR_INT_ERR 2
#define FR_INVALID_NAME 6
#define FR_DENIED 7

static u8 dir_remove(u8 *dp);

/* The entry point stays the first function in the file. */
u8 FsUnlink(u16 far_pad_af, u16 far_pad_ret, const u8 *path) {
    u8 dj[26];
    u8 sfn[12];
    const u8 *p = path;
    u8 *dir;
    u32 dclst;
    u8 res;

    (void)far_pad_af;
    (void)far_pad_ret;
    res = FindVolume_B9((u8 **)dj, &p, 1);
    if (res) return res;
    D_FN(dj) = sfn;
    D_LFN(dj) = LFN_BUF;
    res = FollowPath_B9(dj, p);
    if (res) return res;
    dir = D_DIR(dj);
    if (!dir) return FR_INVALID_NAME;
    if (dir[DIR_ATTR] & (AM_RDO | AM_DIR)) return FR_DENIED;
    dclst = LdClust_B9(D_FS(dj), dir);
    res = dir_remove(dj);
    if (res) return res;
    if (dclst) {
        res = RemoveChain_B9(D_FS(dj), dclst);
        if (res) return res;
    }
    FS_FREE(D_FS(dj)) = 0xFFFFFFFF;
    D_FS(dj)[FS_FSI] |= 1;
    return SyncFs_B9(D_FS(dj));
}

/* Mark the entry and its LFN entries deleted (R0.10 dir_remove). */
static u8 dir_remove(u8 *dp) {
    u16 i = D_INDEX(dp);
    u8 res;

    res = DirSdi_B9(dp, D_LFNIDX(dp) == 0xFFFF ? i : D_LFNIDX(dp));
    while (res == 0) {
        res = MoveWindow_B9(D_FS(dp), D_SECT(dp));
        if (res) break;
        *D_DIR(dp) = DDEM;
        D_FS(dp)[FS_WFLAG] = 1;
        if (D_INDEX(dp) >= i) break;
        res = DirNext_B9(dp, 0);
    }
    if (res == FR_NO_FILE) res = FR_INT_ERR;
    return res;
}
