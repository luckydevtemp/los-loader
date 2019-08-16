PrintDriveInfo:
  push  bx

  push  bp
  mov   bp, sp

  mov   bx, ax
  xor   ax, ax

  mov   al, [bx + DiskInfoStruct.DriveNumber]

  test  al, 0x80
  jnz   .hd                             ; HD

  ; FD
  add   al, '0'
  push  ax

  mov   ax, 'FD'
  push  ax

  mov   ax, '- '
  push  ax

  mov   ax, '  '
  push  ax

  mov   ax, sp

  push  ds

  push  ss
  pop   ds

  call  WriteAStr

  pop   ds

  mov   sp, bp

  mov   al, [bx + DiskInfoStruct.DriveType]

  cmp   al, 1
  je    .fd.1

  cmp   al, 2
  je    .fd.2

  cmp   al, 3
  je    .fd.3

  cmp   al, 4
  je    .fd.4

  mov   ax, FDOTHER_MSG
  jmp   .fdprint

.fd.1:
  mov   ax, FD1_MSG
  jmp   .fdprint

.fd.2:
  mov   ax, FD2_MSG
  jmp   .fdprint

.fd.3:
  mov   ax, FD3_MSG
  jmp   .fdprint

.fd.4:
  mov   ax, FD4_MSG
  jmp   .fdprint

.fdprint:
  call  WriteAStr
  jmp   .1

.hd:
  and   al, ~0x80

  add   al, '0'
  push  ax

  mov   ax, 'HD'
  push  ax

  mov   ax, '- '
  push  ax

  mov   ax, '  '
  push  ax

  mov   ax, sp

  push  ds

  push  ss
  pop   ds

  call  WriteAStr

  pop   ds

  mov   sp, bp

.1:
  mov   ax, CHS_MSG
  call  WriteAStr

  xor   eax, eax

  mov   ax, [bx + DiskInfoStruct.Cylinders]
  push  ax
  call  WriteUInt32

  mov   ax, SLASH_MSG
  call  WriteAStr

  mov   ax, [bx + DiskInfoStruct.Heads]
  push  ax
  call  WriteUInt32

  mov   ax, SLASH_MSG
  call  WriteAStr

  xor   ax, ax
  mov   al, [bx + DiskInfoStruct.Sectors]
  push  ax
  call  WriteUInt32

  pop   ax
  pop   dx

  mul   dx

  mov   cx, dx
  shl   ecx, 16
  mov   cx, ax

  xor   eax, eax
  pop   ax

  mul   ecx

  test  edx, edx
  jz   .2

  mov   ax, ERROR_CALC_LBA
  call  WriteAStr

  jmp   Abort

.2:
  push  eax

  mov   ax, LBA_MSG
  call  WriteAStr

  pop   eax
  call  WriteUInt32

  mov   ax, NEWLINE
  call  WriteAStr

  leave

  pop   bx
ret
