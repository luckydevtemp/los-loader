;===========================================================================
; LoadFile
; --------------------------------------------------------------------------
; DS:AX - InfoFile
; ES:BX - Buffer
; FS:0  - FAT carregada
;===========================================================================

LoadFile:













;===============================================================================
; ReadLBA
; ------------------------------------------------------------------------------
; Le setores em LBA
;
; DX:AX - Setor LBA
; CX    - Q
; DS:SI - DiskInfo
; ES:DI - Buffer
;===============================================================================





















ret





_LoadFile:
  ; Calcula quantos setores deve carregar
  mov   ax, [bootfile_size]
  mov   dx, [bootfile_size + 2]

  mov   bx, [BPB.BytesPerSector]
  div   bx

  or    dx, dx
  jz    .0

  inc   ax

.0:
  xor   bx, bx
  mov   cx, bx
  mov   di, bx

  mov   bl, [BPB.SectorsPerCluster]

  dec   ax
  div   bl                              ; AL = resultado

  mov   cl, al
  inc   cx                              ; numero de clusters

  mov   es, [stage2_ph]                 ; seta buffer pelo paragrafo
  mov   ax, [bootfile_cluster]

.loop:
  cmp   ax, 0x2
  jbe   Error                           ; Primeiro e segundo clusters sao reservados

  cmp   ax, 0xFF0                       ; Valor maximo para clusters
  ja    Error

  push  cx
  push  ax

  ; Calcula posicao na area de dados
  sub   ax, 2                           ; 2 cluster = 0 dados
  mov   cx, bx                          ; BX    - BPB.SectorsPerCluster

  mul   cx                              ; DX:AX - setor na area de dados
                                        ; CX    - quantidade de setores a ler

  ; Calcula posicao absoluta
  add   ax, [data_lba]
  adc   dx, [data_lba + 2]

  call  ReadLBA

  pop   ax                              ; reculpera o numero do cluster

  call  ReadFatEntry                    ; AX = proximo cluster

  pop   cx
  loop  .loop

  xor    ax, [flag_eoc]
  jnz    Error

  xor   ax, ax

  push  word [stage2_ph]
  push  ax

  ; Alguns parametros nao podem ser obtidos pelo stage2, nesse caso TEMOS que passar ao stage2
  ;
  ; DX, AX  Inicio da particao
  ; CL      Disco fisico

  mov   ax, [BPB.HiddenSectors]
  mov   dx, [BPB.HiddenSectors + 2]
  mov   cl, [BPB.PhysicalDriveNumber]   ; Coloca o driver para o stage2 saber de onde veio
retf                                    ; <---- salta para o stage2

