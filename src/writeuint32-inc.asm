; EAX = UInt32

WriteUInt32:
  push  ecx
  push  edx
  push  di

  push  bp
  mov   bp, sp

  mov   di, sp
  dec   di
  mov   byte [di], 0

  xor   ecx, ecx
  mov   cl, 10

.loop:
  xor   edx, edx
  div   ecx

  add   dl, '0'

  dec   di
  mov   [ss:di], dl

  or    eax, eax
  jnz   .loop

.print:
  mov   ax, di
  and   al, 0xFE
  mov   sp, ax

  push  ds

  push  ss
  pop   ds

  mov   ax, di
  call  WriteAStr

  pop   ds

  leave

  pop   di
  pop   edx
  pop   ecx
ret
