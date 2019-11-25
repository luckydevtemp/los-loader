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

  jmp   .Error2

.FoundedFile:
  ; Verifica tipo do arquivo
  test  byte [es:bx + 11], 0x18            ; Diretorio e volumeid
  jnz   .Error2

  pop   di

  ; Pega o primeiro cruster do arquivo
  mov   ax, [es:bx + 26]
  mov   [di + FileInfoStruct.Cluster], ax

  ; Pega o tamanho em bytes
  mov   eax, [es:bx + 28]
  mov   [di + FileInfoStruct.Size], eax

  ; Calcula o tamanho em setores
  dec   eax
  xor   edx, edx
  mov   ebx, SECTOR_SIZE

  div   ebx
  inc   eax

  cmp   eax, 0xFFFF
  jna    .1

  jmp   .Error1

.1:
  mov   [di + FileInfoStruct.Sectors], ax
  clc

.End:
  pop   si

  pop   bx
  pop   cx
  pop   dx
  pop   ax
ret

.Error2:
  pop   di
.Error1:
  stc
jmp .End
