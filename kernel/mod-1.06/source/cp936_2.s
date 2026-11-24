; cp936_2.s - u2o block 2 -> ROM bank 24
	.module cp936_2
	.area _CODE_24
	.globl _cp936_2
_cp936_2::
	.incbin "source/font/cp936_u2o_2.bin"
