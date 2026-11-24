@echo off
setlocal enabledelayedexpansion
rem ======================================================================
rem  ezgb (new_kernel_en)  build script
rem  Toolchain : GBDK-2020 / SDCC 4.5.1  (..\SDCC\gbdk)
rem  Build dir : build\    intermediates only (.o/.asm/.lst/.sym)
rem  Release   : release\  ezgb.gbc + ezgb.dat (deliverables)
rem
rem  Usage     : build.bat             build and publish to release\
rem              build.bat clean       remove intermediates in build\
rem              build.bat cleandist   remove deliverables in release\
rem ======================================================================
cd /d "%~dp0"

set "GBDK=%~dp0..\SDCC\gbdk"
set "LCC=%GBDK%\bin\lcc.exe"
set "OUT=build"
set "REL=release"

if /i "%~1"=="clean" (
  if exist "%OUT%" (
    del /q "%OUT%\*.o"    2>nul
    del /q "%OUT%\*.gbc"  2>nul
    del /q "%OUT%\*.dat"  2>nul
    del /q "%OUT%\*.map"  2>nul
    del /q "%OUT%\*.ihx"  2>nul
    del /q "%OUT%\*.sym"  2>nul
    del /q "%OUT%\*.asm"  2>nul
    del /q "%OUT%\*.lst"  2>nul
    del /q "%OUT%\*.noi"  2>nul
    del /q "%OUT%\*.cdb"  2>nul
    del /q "%OUT%\*.log"  2>nul
  )
  echo [OK] build cleaned
  exit /b 0
)

if /i "%~1"=="cleandist" (
  if exist "%REL%" (
    del /q "%REL%\*.gbc"  2>nul
    del /q "%REL%\*.dat"  2>nul
    del /q "%REL%\en\*.dat"  2>nul
    del /q "%REL%\zh\*.dat"  2>nul
  )
  echo [OK] release cleaned
  exit /b 0
)

if not exist "%LCC%" (
  echo [ERROR] lcc.exe not found: %LCC%
  echo         expected toolchain at ..\SDCC\gbdk
  exit /b 1
)
if not exist "%OUT%" mkdir "%OUT%"

rem ---- UI text width check (optional: only if python is on PATH) ----
where python >nul 2>nul
if errorlevel 1 goto :uicheck_skip
python tools\check_ui_text.py
if !errorlevel! neq 0 (
  echo [ERROR] ui_text.h: text does not fit the dialog ^(10 chars max^)
  exit /b 1
)
:uicheck_skip

rem ---- modules, order = link order (do not reorder) ----
rem  all sources live in source\ ; build tools and this script stay at the root
rem  -Wf--include=port_types.h : force BYTE back to unsigned (GBDK-2020
rem                              defines it as signed char, which breaks
rem                              FatFs' DDEM (0xE5) directory checks)
set MODULES=main ezgb_hw diskio ff ff_1 ff_2 ff_3 ff_4 ffunicode SD_operate GBcard_OP RTC Help UI Bank_fun

set "OBJS="
for %%M in (%MODULES%) do (
  echo [CC] %%M.c
  rem lcc returns 0 even when the compiler subprocess fails, so check both the
  rem produced object and the log: a stale .o must never be linked silently.
  if exist %OUT%\%%M.o del /q %OUT%\%%M.o
  "%LCC%" -c -o %OUT%\%%M.o source\%%M.c -Isource -Wf--include=port_types.h > %OUT%\%%M.log 2>&1
  if not exist %OUT%\%%M.o (
    echo [ERROR] compile failed: %%M.c
    type %OUT%\%%M.log
    goto :build_fail
  )
  findstr /C:"subprocess error" %OUT%\%%M.log >nul
  if not errorlevel 1 (
    echo [ERROR] compile failed: %%M.c
    type %OUT%\%%M.log
    goto :build_fail
  )
  set "OBJS=!OBJS! %OUT%\%%M.o"
)

echo [LD] %OUT%\ezgb.gbc
rem  -Wm-yo10        10 ROM banks (163840 bytes)
rem  -Wm-yt0x01      MBC1
rem  -Wm-yn"EZGB"    cartridge title
rem  -Wl-b_CODE=0x600 keep 0x0200-0x05FF reserved (layout of the original ROM)
"%LCC%" -o %OUT%\ezgb.gbc %OBJS% -Wm-yo10 -Wm-yt0x01 -Wm-yn"EZGB" -Wl-b_CODE=0x600
if errorlevel 1 (
  echo [ERROR] link failed
  exit /b 1
)

rem ---- publish to release\en\ (card-ready name ezgb.dat; no dat in release root) ----
if not exist "%REL%" mkdir "%REL%"
if not exist "%REL%\en" mkdir "%REL%\en"
copy /y "%OUT%\ezgb.dat" "%REL%\en\ezgb.dat" >nul
if errorlevel 1 (
  echo [ERROR] cannot write %REL%\en\ezgb.dat
  exit /b 1
)

for %%F in ("%REL%\en\ezgb.dat") do (
  echo [OK] %REL%\en\ezgb.dat   size = %%~zF bytes
)

endlocal & exit /b 0

rem ---- failure exit: cmd loses the code of `exit /b` inside a for-block, so
rem      every in-loop failure jumps here instead
:build_fail
endlocal & exit /b 1
