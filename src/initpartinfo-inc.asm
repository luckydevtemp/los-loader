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

  ; Salva ponteiro para DiskInfo
  mov   [di + PartitionInfoStruct.DiskInfo], si
  mov   [di + PartitionInfoStruct.DiskInfo + 2], ds

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
  pop   dx                              ; Reculpera valores
  pop   ax

  mov   [es:di + PartitionInfoStruct.Start], ax
  mov   [es:di + PartitionInfoStruct.Start + 2], dx

  ; Restaura segmentos (inverte)
  pop   es
  pop   ds

  ; Calcula tamanho da partição
  xor   eax, eax
  mov   ax, [es:bx + FAT_BPB.SmallSectors]

  test  ax, ax
  jnz   .1

  mov   eax, [es:bx + FAT_BPB.LargeSectors]

.1:
  mov   [di + PartitionInfoStruct.Size], eax

  ; Copia os setores reservados
  mov   ax, [es:bx + FAT_BPB.ReservedSectors]
  mov   [di + PartitionInfoStruct.ReservedSectors], ax

  ; Copia setores por FAT
  mov   ax, [es:bx + FAT_BPB.SectorsPerFAT]
  mov   [di + PartitionInfoStruct.SectorsPerFAT], ax

  ; Copia a quantidade da FATs
  mov   al, [es:bx + FAT_BPB.FATs]
  mov   [di + PartitionInfoStruct.FATs], al

  ; Copia tamanho dos clusters
  mov   al, [es:bx + FAT_BPB.SectorsPerCluster]
  mov   [di + PartitionInfoStruct.SectorsPerCluster], al

  ; Copia quantidade de entradas no diretorio raiz
  mov   ax, [es:bx + FAT_BPB.RootEntries]
  mov   [di + PartitionInfoStruct.RootEntries], ax

  ; Calcula FATLBA
  mov   ebx, [di + PartitionInfoStruct.Start]

  xor   edx, edx
  mov   dx, [di + PartitionInfoStruct.ReservedSectors]

  add   ebx, edx

  mov   [di + PartitionInfoStruct.FATLBA], ebx

  ; Calcula RootLBA
  mov   ax, [di + PartitionInfoStruct.SectorsPerFAT]

  xor   cx, cx
  mov   cl, [di + PartitionInfoStruct.FATs]

  mul   cx

  shl   edx, 16
  mov   dx, ax

  add   ebx, edx

  mov   [di + PartitionInfoStruct.RootLBA], ebx

  ; Tamanho do RootDir
  mov   ax, [di + PartitionInfoStruct.RootEntries]
  mov   cx, DIRENTRY_SIZE
  mul   cx

  test  ax, ax
  jnz   .2

  dec   dx

.2:
  dec   ax

  mov   cx, SECTOR_SIZE
  div   cx

  inc   ax

  mov   [di + PartitionInfoStruct.RootSectors], ax

  ; Calcula DataLBA
  xor   edx, edx
  mov   dx, ax

  add   ebx, edx

  mov   [di + PartitionInfoStruct.DataLBA], ebx

  ; Calcula total de clusters
  mov   eax, [di + PartitionInfoStruct.Size]
  sub   eax, ebx

  xor   edx, edx
  mov   ecx, edx
  mov   cl, [di + PartitionInfoStruct.SectorsPerCluster]

  div   ecx

  mov   [di + PartitionInfoStruct.Clusters], eax

  pop   cx
ret



