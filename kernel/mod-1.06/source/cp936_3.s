; cp936_3.s - u2o block 3 -> ROM bank 25
	.module cp936_3
	.area _CODE_25
	.globl _cp936_3
_cp936_3::
	.incbin "source/font/cp936_u2o_3.bin"
