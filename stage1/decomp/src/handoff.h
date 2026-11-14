#ifndef HANDOFF_H
#define HANDOFF_H

#include "gb.h"

void LoadKernel(UBYTE *cmd) BANKED;
void HandoffPoll(void);

/* where HandoffPoll's bytes are in ROM: its link address is $D100 */
extern const UBYTE HandoffPollRom[];

#endif
