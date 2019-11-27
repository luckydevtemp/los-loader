;===========================================================================
; LoadFile
; --------------------------------------------------------------------------
; DS:AX - InfoFile
; ES:BX - Buffer
; FS:0  - FAT carregada
;===========================================================================

LoadFile:
  push  eax
  push  bx
  push  ecx
  push  edx

  push  si
  push  di

  mov   di, bx                          ; Buffer
  mov   bx, ax                          ; InfoFile

  ; Calcula quantos setores deve carregar
  xor   edx, edx
  mov   eax, [bx + FileInfoStruct.Size]
  mov   ecx, SECTOR_SIZE

  div   ecx

  test  edx, edx
  jz    .0

  inc   eax                             ; EAX = Numero de setores

.0:
  mov   si, [bx + FileInfoStruct.PartitionInfo]

  xor   ecx, ecx
  mov   cl, [si + PartitionInfoStruct.SectorsPerCluster]

  xor   edx, edx
  div   ecx

  test  edx, edx
  jz    .1

  inc   eax                             ; EAX = Numero de clusters

.1:
  cmp   eax, 0x0000_0FF0                ; Valor maximo para clusters
  ja    .Error

  mov   cx, ax                          ; Numero de clusters
  mov   ax, [bx + FileInfoStruct.StartCluster]

.loop:
  cmp   ax, 0x2                         ; Primeiro (1) e segundo (2) entradas sao reservadas
  jbe    .Error

  cmp   ax, 0xFF0                       ; Valor maximo para clusters
  ja    .Error

  push  cx
  push  ax

  ; Calcula posicao na area de dados
  sub   ax, 2                           ; 2 cluster = 0 dados
  mov   cx, [si + PartitionInfoStruct.SectorsPerCluster]

  mul   cx                              ; DX:AX - setor na area de dados
                                        ; CX    - quantidade de setores a ler

  ; Calcula posicao absoluta
  add   ax, [si + PartitionInfoStruct.DataLBA]
  adc   dx, [si + PartitionInfoStruct.DataLBA + 2]

  push  si
  mov   si, [si + PartitionInfoStruct.DiskInfo]

  ; ES:DI = buffer

  call  ReadLBA

  pop   si
  pop   ax                              ; reculpera o numero do cluster

  call  ReadFatEntry                    ; AX = proximo cluster

  pop   cx
loop  .loop

  xor    ax, [si + PartitionInfoStruct.Flag_EOC]
  jnz    .Error

  clc

.End:
  pop   di
  pop   si

  pop   edx
  pop   ecx
  pop   bx
  pop   eax
ret

.Error:
  stc
jmp   .End
