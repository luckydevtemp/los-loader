;===========================================================================
; CalcCRC32
; --------------------------------------------------------------------------
; Calcula o CRC32 do bloco informado
;
; DX:AX       CRC inicial
; CX          Tamanho do bloco
; ES:SI       Ponteiro para o bloco
;===========================================================================

CalcCRC32:
  push  ds
  push  bx

  not   dx
  not   ax
  mov   bx, ax

  push  es
  pop   ds

.loop1:
  lodsb

  xor   bl, al

  push  cx
  mov   cx, 8

.loop2:
  test  bl, 1
  jz    .1

  shr   bx, 1
  shr   dx, 1
  jnc   .0

  or    bx, 0x8000

.0:
  xor   dx, 0xEDB8
  xor   bx, 0x8320

  jmp .2

.1:
  shr   bx, 1
  shr   dx, 1
  jnc   .2

  or    bx, 0x8000

.2:
  loop  .loop2
  pop   cx
  loop  .loop1

  mov   ax, bx
  not   ax
  not   dx

  pop  bx
  pop  ds
ret
