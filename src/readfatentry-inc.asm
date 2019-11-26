;===========================================================================
; ReadFatEntry
; --------------------------------------------------------------------------
; Le a entrada N da FAT
;
; AX    - Entrada N - Retorno
; FS:0  - Buffer (permanente)
;===========================================================================

ReadFatEntry:
  push  dx
  push  cx
  push  bx

  xor   dx, dx
  mov   cx, ax      ; faz bak

  shr   ax, 1       ; /2
  mov   bx, 3       ; *3
  mul   bx

  ; FAT_BASE = 0
  mov   bx, ax

  mov   ax, [fs:bx]
  mov   dx, [fs:bx + 2]

  test  cx, 1
  jz    .0

  and   dx, 0x00FF
  mov   bx, 0x1000
  div   bx

.0:
  and   ax, 0xFFF

  pop   bx
  pop   cx
  pop   dx
ret
