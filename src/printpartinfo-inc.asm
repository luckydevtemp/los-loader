;===========================================================================
; PrintPartitionInfo
; --------------------------------------------------------------------------
; DS:AX - PartitionInfo
;===========================================================================

PrintPartitionInfo:
  push  si
  push  dx

  mov   si, ax

  ; Imprime Label
  mov   ax, VOLUMELABEL_MSG
  call  WriteAStr

  lea   ax, [si + PartitionInfoStruct.VolumeLabel]
  call  WriteAStr

  ; Imprime ID
  mov   ax, ID_MSG
  call  WriteAStr

  mov   ax, [si + PartitionInfoStruct.ID]
  mov   dx, [si + PartitionInfoStruct.ID + 2]

  push  ax
  mov   ax, dx

  call  WriteWordHex

  pop   ax

  call  WriteWordHex

  ; Imprime OEM
  mov   ax, OEM_MSG
  call  WriteAStr

  lea   ax, [si + PartitionInfoStruct.OEM]
  call  WriteAStr

  ; Imprime Start
  mov   ax, START_MSG
  call  WriteAStr

  mov   eax, [si + PartitionInfoStruct.Start]

  call  WriteUInt32

  ; Imprime Size
  mov   ax, SIZE_MSG
  call  WriteAStr

  mov   eax, [si + PartitionInfoStruct.Size]

  call  WriteUInt32

  ; Imprime os Setores reservados
  mov   ax, RESERVED_MSG
  call  WriteAStr

  xor   eax, eax
  mov   ax, [si + PartitionInfoStruct.ReservedSectors]

  call  WriteUInt32

  ; Imprime a quantidade de FATs
  mov   ax, FATS_MSG
  call  WriteAStr

  xor   eax, eax
  mov   al, [si + PartitionInfoStruct.FATs]

  call  WriteUInt32

  ; Imprime o tamanho da FAT em setores
  mov   ax, FATSECT_MSG
  call  WriteAStr

  xor   eax, eax
  mov   ax, [si + PartitionInfoStruct.SectorsPerFAT]

  call  WriteUInt32

  ; Imprime quantidade de entradas no diretorio raiz
  mov   ax, ROOTENTRIES_MSG
  call  WriteAStr

  xor   eax, eax
  mov   ax, [si + PartitionInfoStruct.RootEntries]

  call  WriteUInt32

  ; Imprime tamanho do diretorio raiz
  mov   ax, ROOTSECTORS_MSG
  call  WriteAStr

  xor   eax, eax
  mov   ax, [si + PartitionInfoStruct.RootSectors]

  call  WriteUInt32

  ; Imprime Total de Clusters
  mov   ax, CLUSTERS_MSG
  call  WriteAStr

  mov   eax, [si + PartitionInfoStruct.Clusters]

  call  WriteUInt32

  ; Imprime o tamanho dos clusters
  mov   ax, CLUSTERSECT_MSG
  call  WriteAStr

  xor   eax, eax
  mov   al, [si + PartitionInfoStruct.SectorsPerCluster]

  call  WriteUInt32


  ; Imprime FATLBA
  mov   ax, FATLBA_MSG
  call  WriteAStr

  mov   eax, [si + PartitionInfoStruct.FATLBA]

  call  WriteUInt32

  ; Imprime RootLBA
  mov   ax, ROOTLBA_MSG
  call  WriteAStr

  mov   eax, [si + PartitionInfoStruct.RootLBA]

  call  WriteUInt32

  ; Imprime DataLBA
  mov   ax, DATALBA_MSG
  call  WriteAStr

  mov   eax, [si + PartitionInfoStruct.DataLBA]

  call  WriteUInt32

  mov   ax, NEWLINE
  call  WriteAStr

  pop   dx
  pop   si
ret
