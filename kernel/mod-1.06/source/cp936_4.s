; cp936_4.s - u2o block 4 -> ROM bank 26
	.module cp936_4
	.area _CODE_26
	.globl _cp936_4
_cp936_4::
	.incbin "source/font/cp936_u2o_4.bin"
