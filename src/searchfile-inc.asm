;===========================================================================
; SearchFile
; --------------------------------------------------------------------------
; DS:AX - Ponteiro para nome
; DS:SI - PartitionInfo
; DS:DI - InfoFile
; ES:BX - Buffer
;===========================================================================

SearchFile:
  push  ax
  push  dx
  push  cx
  push  bx

  push  si
  push  di
  push  ax

  ; Carrega root dir
  mov   ax, [si + PartitionInfoStruct.RootLBA]
  mov   dx, [si + PartitionInfoStruct.RootLBA + 2]

  mov   cx, [si + PartitionInfoStruct.RootSectors]

  push  si
  mov   si, [si + PartitionInfoStruct.DiskInfo]
  mov   di, bx                                  ; ES já está correto

  call  ReadLBA

  pop   si

  ; Procura arquivo
  mov   dx, [si + PartitionInfoStruct.RootEntries]
  ; BX já contem o buffer

  pop   ax

.loop:
  mov   si, ax                ; FileName
  mov   di, bx
  mov   cx, FILENAME_SIZE

  repz  cmpsb
  je    .FoundedFile

  add   bx, DIRENTRY_SIZE
  dec   dx
  jnz   .loop

  jmp   .Error

.FoundedFile:
  ; Verifica tipo do arquivo
  test  byte [es:bx + 11], 0x18            ; Diretorio e volumeid
  jnz   .Error

  pop   di

  ; Pega o primeiro cruster do arquivo
  mov   ax, [es:bx + 26]
  mov   [di + FileInfoStruct.StartCluster], ax

  ; Pega o tamanho em bytes
  mov   eax, [es:bx + 28]
  mov   [di + FileInfoStruct.Size], eax

  ; Salva informação do PartitionInfo
  pop   si
  mov   [di + FileInfoStruct.PartitionInfo], si

  clc

.End:
  pop   bx
  pop   cx
  pop   dx
  pop   ax
ret

.Error:
  pop   di
  pop   si
  stc
jmp .End
