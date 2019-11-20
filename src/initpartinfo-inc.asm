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
  push  ds
  push  es

  push  ax                              ; salva para usar depois
  push  dx

  ; Le VBR
  xor   cx, cx
  inc   cx                              ; CX = 1

  push  di
  mov   di, bx

  call  ReadLBA

  pop   di

  ; Inicializar PartitionInfo
  push  di

  xor   ax, ax
  mov   cx, PARTITIONINFOSIZE

  cld
  rep   stosb

  pop   di

  ; Inverte DS e ES para usar movs e stos
  mov   ax, ds
  push  es
  pop   ds
  mov   es, ax

  ; Copia OEM
  mov   cx, 8
  lea   si, [bx + FAT_BPB.OEM]

  push  di
  lea   di, [di + PartitionInfoStruct.OEM]

  rep   movsb

  pop   di

  ; Copia Label
  mov   cx, 11
  lea   si, [bx + FAT1x_eBPB.VolumeLabel]

  push  di
  lea   di, [di + PartitionInfoStruct.VolumeLabel]

  rep   movsb

  pop   di

  ; Copia ID
  lea   si, [bx + FAT1x_eBPB.ID]

  push  di
  lea   di, [di + PartitionInfoStruct.ID]

  movsd

  pop   di

  ; Salva LBA inicio
  pop   dx
  pop   ax

  mov   [es:di + PartitionInfoStruct.Start], ax
  mov   [es:di + PartitionInfoStruct.Start + 2], dx





  ; vReserved Sectors:
  ; Este campo representa o numero de setores que precedem o inicio da primeira
  ; FAT, incluindo o setor de boot. Ele deve sempre ter um valor maior que 1.
;  .ReservedSectors:           resw  1















  pop   es
  pop   ds
  pop   cx
ret




  ; Size (LBA)
  ; Este campo contem o numero total de setores do volume.
  ;.Size:                      resd  1


