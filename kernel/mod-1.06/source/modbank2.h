/* mod: a second bank for new features, after modbank.h's filled up. In the
   Chinese build, where every bank from 10 to 29 is fonts and tables, it is
   bank 8, which that build's own text code leaves nearly empty. */
#ifdef LANG_ZH
#pragma bank 8
#else
#pragma bank 12
#endif
