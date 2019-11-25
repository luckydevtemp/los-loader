;===========================================================================
; ReadFatEntry
; --------------------------------------------------------------------------
; Le a entrada N da FAT
;
; AX    - Entrada N
; CX    - Q
; DS:SI - DiskInfo
; ES:DI - Buffer
;===========================================================================

ReadFatEntry:
  push  dx
  push  bx





  xor   dx, dx
  mov   cx, ax

  shr   ax, 1       ; /2
  mov   bx, 3       ; *3
  mul   bx

  add   ax, FAT_BASE
  mov   bx, ax

  mov   ax, [bx]
  mov   dx, [bx + 2]

  and   cx, 1
  jz    .0

  and   dx, 0x00FF
  mov   bx, 0x1000
  div   bx

.0:
  and   ax, 0xFFF







  pop   bx
  pop   dx
ret
