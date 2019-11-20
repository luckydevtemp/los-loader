;===========================================================================
; InitPartitionInfo
; --------------------------------------------------------------------------
; DX:AX - LBA do inicio da particao
; DS:SI - DiskInfo
; DS:DI - PartitionInfo
; ES:BX - Buffer
;===========================================================================

InitPartitionInfo:
  push  cx

  push  di

  xor   cx, cx
  inc   cx

  mov   di, bx

  call  ReadLBA

















  pop   di


  pop   cx
ret
