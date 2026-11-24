; cp936_1.s - u2o block 1 -> ROM bank 23
	.module cp936_1
	.area _CODE_23
	.globl _cp936_1
_cp936_1::
	.incbin "source/font/cp936_u2o_1.bin"
