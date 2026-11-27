#ifndef UI_TEXT_H
#define UI_TEXT_H

/* ============================================================================
   Table of fixed on-screen strings
   ----------------------------------------------------------------------------
   Every fixed string shown on screen lives here: to change a message only this
   file needs editing.

   Two hard rules (both learned the hard way):

   1) len must equal the real character count.
      When len is larger than strlen, Draw_Text(str, len, x, y) calls
      color(BLACK,WHITE,SOLID), flips BGP to a white background and pads with
      spaces. BGP is a global register, so the whole dialog turns white - it
      looks like a white progress bar. Always use UI_LEN() (sizeof based),
      never a hand-written number.

   2) A dialog is only 10 characters wide.
      box(35,37,125,108) spans 40px..125px, which holds 10 characters of 8px.
      Anything longer draws outside the frame. tools/check_ui_text.py checks
      this at build time and fails the build.

   Usage:
       Draw_Text(UI_SAVE_OK, UI_LEN(UI_SAVE_OK), 5, 10);
       Draw_Text(UI_LOAD_NEW, 0, 5, 11);         len=0 pads to 17 cells
   ========================================================================== */

#include <gb/gb.h>

/* Length of a literal; the argument must be a string literal or a UI_* macro */
#define UI_LEN(s)               ((UINT8)(sizeof(s) - 1))

/* ---------- save dialog (Bank_fun.c Show_SAVE_info) ---------- */
#define UI_SAVE_TITLE           "BACKUPSAVE"
#define UI_SAVE_BUSY            "Saving..."
#define UI_SAVE_OK              "SAVE OK! "
#define UI_SAVE_FAIL            "SAVE FAIL!"
#define UI_SAVE_FAIL_SD         "SD ERROR"
#define UI_SAVE_PRESS_B         "press B"
#define UI_BTN_NO               "[B]NO"
#define UI_BTN_OK               "[A]OK"

/* ---------- load dialog (Bank_fun.c Show_LOAD_info) ---------- */
#define UI_LOAD_TITLE           "LOAD SAVE"
#define UI_LOAD_BUSY            "Loading..."
#define UI_LOAD_OK              "LOAD OK!  "
#define UI_LOAD_NONE            "NO sav fil"
#define UI_LOAD_NEW             "Make new"

/* ---------- file list (Bank_fun.c Show_filename / Refresh_filename) ---------- */
#define UI_LIST_DIR             "DIR"

/* ---------- recently played (main.c + Bank_fun.c Show_recent_list) ---------- */
#define UI_RECENT_TITLE         "Recently played"	/* mod: was "Recently play" */

/* ---------- tab bar (UI.c) ---------- */
#define UI_TAB_SD               " SD "
#define UI_TAB_SET              " SET "
#define UI_TAB_HELP             " HELP "

/* ---------- generic status messages (UI.c) ---------- */
#define UI_READING              "Reading..."
/* A whole row of 20 spaces: rewrites one tile row as blank, used to wipe
   graphics that should not be there (palette independent) */
#define UI_BLANK_LINE           "                    "
#define UI_ERROR_FILE           "Error file"
#define UI_BTN_RETURN           "[B]return"
#define UI_BTN_START            "[A]start"

/* ---------- help page (Help.c) ---------- */
#define UI_HELP_VER             "ver:"
#define UI_HELP_SITE            "www.ezflash.cn"

/* Kernel version. The first 3 characters are placeholders: Help.c replaces
   s[2]/s[3] with the FPGA version ("FWx" -> "FW15" style), so only the last
   8 characters change. The total length must stay 11.
   The final letter marks the build: e = English, c = Chinese. */
#ifdef LANG_ZH
#define UI_HELP_FWVER           "FWx  K1.06c"
#else
#define UI_HELP_FWVER           "FWx  K1.06e"
#endif

/* mod: the line under the kernel version */
#include "mod_version.h"
#define UI_HELP_MOD             "MOD " MOD_VERSION

/* ---------- time settings (RTC.c) ---------- */
#define UI_RTC_TIME             "TIME:"
#define UI_RTC_SET              "SET"
#define UI_RTC_SAV              "SAV"
#define UI_RTC_AUTOSAVE         "AUTO SAVE:"

/* ---------- boot self-test (main.c) ---------- */
#define UI_ERR_FS               "File system error!"
#define UI_ERR_SD_INIT          "Micro SD init error"
#define UI_OK_SD_INIT           "Micro SD initial OK!"
#define UI_BATTERY              "BATTERY"
#define UI_BATTERY_DRY          "DRY!!!"

/* ============================================================================
   Width check
   ----------------------------------------------------------------------------
   Not a compile-time assertion: SDCC emits sizeof("literal") into every module
   including this header (~290 extra bytes in each of 3 banks). A build script

       a missing python only warns, the build continues).

   checks it instead: python tools/check_ui_text.py (run by build.bat/makefile;
   ========================================================================== */

#endif /* UI_TEXT_H */
