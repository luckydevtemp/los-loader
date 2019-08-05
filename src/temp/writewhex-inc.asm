WriteWordHex:
  push  bx
  mov   cl, 4
  rol   al, cl
  rol   ah, cl
  xchg  ah, al

  mov   cx, 4

.loop:
  push  cx
  push  ax

  and   al, 0xF
  cmp   al, 0x9
  ja    .0

  add   al, '0'
  jmp   .1

.0:
  add   al, ('A' - 10)

.1:
  mov   ah,0x0E         ; Indica a rotina de teletipo da BIOS
  mov   bx, 0x0007      ; Número da página de vídeo/Texto branco em fundo preto

  int   0x10            ; Se não, chama INT 10 para por caracter na tela

  pop   ax
  mov   cl, 4
  shr   ax, cl

  pop   cx
  loop  .loop

  pop   bx
ret
