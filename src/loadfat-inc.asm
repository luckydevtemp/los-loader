;===========================================================================
; LoadFAT
; --------------------------------------------------------------------------
; DS:SI - PartitionInfo
; FS:0  - Buffer (permanente)
;===========================================================================

LoadFAT:
  push  ax
  push  cx
  push  dx
  push  si
  push  di
  push  ds
  push  es

  ; Endereço LBA
  mov   ax, [si + PartitionInfoStruct.FATLBA]
  mov   dx, [si + PartitionInfoStruct.FATLBA + 2]

  ; Quantidade de setores
  mov   cx, [si + PartitionInfoStruct.SectorsPerFAT]

  ; DiskInfo
  lds   si, [si + PartitionInfoStruct.DiskInfo]

  ; Buffer
  push  fs
  pop   es

  xor   di, di

  call  ReadLBA






  call  ReadFatEntry






  pop   es
  pop   ds
  pop   di
  pop   si
  pop   dx
  pop   cx
  pop   ax
ret
