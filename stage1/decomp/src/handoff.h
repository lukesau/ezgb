#ifndef HANDOFF_H
#define HANDOFF_H

#include "gb.h"

void LoadKernel(UBYTE *cmd) BANKED;
void HandoffPoll(void);

/* HandoffPoll where it is stored, 01:4000; it is linked to run at $D100.
 * tools/link.py defines it. */
void HandoffPollRom(void);

#endif
