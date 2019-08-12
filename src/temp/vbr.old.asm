
;===========================================================================
;
; ############################ Definições ############################
;
;===========================================================================



  STAGE1_BASE     equ STAGE1_SEG * 0X10


;===========================================================================
;
; ############################ Procedimentos ############################
;
;===========================================================================

;  %include "initdiskinfo-inc.asm"
%include "writewhex-inc.asm"


;===========================================================================
;
; ############################ DATA ############################
;
;===========================================================================

  BOOT_MSG          db  'B', 10, 13, 0
  ERROR_MSG         db  'E', 10, 13, 0

;  NEW_LINE          db  10, 13, 0


  TEST_MSG          db  'OK', 10, 13, 0
;  TEST_MSG          db  'Chegou ate aqui!', 10, 13, 0




;===========================================================================
;
; ############################ BSS ############################
;
;===========================================================================

SECTION .bss
; ### Variaveis criadas pelo bootloader ###


  ;erro_count          resb  1

  current_sector      resb  1
  current_cylinder    resw  1


;===========================================================================
;
; ############################ Definições ############################
;
;===========================================================================


  FAT_BASE        equ 0x0600

  STACK_SIZE      equ 1024              ; 1k de pilha é mais que suficiente





  FREE_LOWER      equ (STAGE1_BASE - STACK_SIZE - FAT_BASE)

  DIRENTRY_SIZE   equ 32      ; Tamanho de uma entrada de diretorio
  FILENAME_SIZE   equ 11      ; Tamanho dos nomes de arquivos


;===========================================================================
;
; ############################ DATA ############################
;
;===========================================================================





  WELCOME_EBS_STR   db  'Extended_Boot carregado!', 10, 13, 0




;===========================================================================
;
; ############################ Assinatura de boot ############################
;
; --------------------------------------------------------------------------
  times (0x200 - 2) - ($ - $$) db 0
  db 0x55,0xAA
;===========================================================================






; ##########################################################################
; ##########################################################################
; ##########################################################################
;
;
; ########################## Extended Boot Sector ##########################
;
;
; ##########################################################################
; ##########################################################################
; ##########################################################################


;===========================================================================
;
; ############################ DATA ############################
;
;===========================================================================

  FileName          db  'BOOT    BIN'



;===========================================================================
;
; ############################ Procedimentos ############################
;
;===========================================================================







;===========================================================================
;
; ############################ Código ############################
;
;===========================================================================



;===========================================================================
; WelcomeEBS
; --------------------------------------------------------------------------
; Continuacao da rotina principal...
; Contida no EBS
;===========================================================================

WelcomeEBS:
  mov   ax, WELCOME_EBS_STR
  call  WriteAnsiStr

  mov   word [free_mem], FREE_LOWER

  ; # Carregar a FAT #

  ; Calcular tamanho da FAT na memória
  mov   ax, SECTOR_SIZE
  mul   word [BPB.SectorsPerFAT]
  and   dx, dx
  jnz   Error

  sub   [free_mem], ax
  jc    Error

  ; Calcula inicio ROOT
  add   ax, FAT_BASE
  mov   [root_base], ax

  ; Calcular a posição da FAT
  mov   ax, [BPB.HiddenSectors]
  mov   dx, [BPB.HiddenSectors + 2]

  add   ax,[BPB.ReservedSectors]
  adc   dx,0

  push  ax                ; Salva para depois
  push  dx                ; fat_lba

  ; Carrega a FAT
  mov   cx, [BPB.SectorsPerFAT]
  mov   di, FAT_BASE

  call  ReadLBA

  ; Le a flag de EOC
  mov   ax, 1
  call  ReadFatEntry
  mov   [flag_eoc], ax

  ; # Carregar ROOT #

  ; Calcula o tamanho do root sector
  mov   ax, DIRENTRY_SIZE
  mul   word [BPB.RootEntries]
  dec   ax
  mov   bx, SECTOR_SIZE
  div   bx
  inc   ax

  mov   cx, ax                 ; Tamanho em setores, usado mais a frente

  mul   bx
  cmp   ax, [free_mem]
  ja    Error

  ; Calcula o tamanho das FATs
  xor   ax, ax
  mov   al, [BPB.FATs]
  mul   word [BPB.SectorsPerFAT]

  ; Calcula a posição do root sector
  mov   bx, ax

  pop   dx                ; Reculpera valores
  pop   ax                ; fat_lba

  add   ax, bx
  adc   dx, 0

  push  ax                ; Salva valores
  push  dx                ; root_lba
  push  cx                ; root_size

  ; Carrega root dir
  mov   di, root_base
  call  ReadLBA

  ; Calcula inicio da area de dados
  pop   cx                ; Reculpera valores
  pop   dx
  pop   ax

  add   ax, cx
  adc   dx, 0
  and   dx, dx
  jnz   Error

  mov   [data_base], ax

  ; # Localizar ARQUIVO #


.FoundedFile:
  ; Verifica tipo do arquivo
  test  byte [bx + 0x0B], 0x18
  jnz   Error

  ; Pega o primeiro cruster do arquivo
  mov   ax, [bx + 0x1A]
  mov   [file_cluster], ax

  ; Pega o tamanho em bytes
  mov   ax, [bx + 0x1C]
  mov   dx, [bx + 0x1E]

  mov   [file_size], ax
  mov   [file_size + 2], dx
























;  mov   ax, [free_mem]

  call  WriteWordHex
  mov   ax, NEW_LINE
  call  WriteAnsiStr



































;===========================================================================
;
; ############################ BSS ############################
;
;===========================================================================

; Evita que a BSS seja sobreescrita pela carga do EBS
  times (0x200 * STAGE1_SECTORS) - ($ - $$) db 0  ; Tem 0 bytes livres


SECTION .bss
; ### Variaveis criadas pelo bootloader ###



  free_mem            resw  1
  root_base           resw  1

  flag_eoc            resw  1

  data_base           resd  1

  file_cluster        resw  1
  file_size           resd  1











































  ; # Carregar ARQUIVO #



















  DIRENTRY_SIZE   equ 32      ; Tamanho de uma entrada de diretorio













  ; # Calcular se FAT + ROOT cabem antes do VBR (deveriam) #

  ; Calcular tamanho do ROOT
  mov   ax, DIRENTRY_SIZE
  mul   word [BPB.RootEntries]
  dec   ax
  mov   bx, [BPB.BytesPerSector]
  div   bx
  inc   ax

  push  ax                            ; Tamanho do ROOT em setores (salvo para depois)

  ; Verificar se cabem antes do vbr
  mov   dx, [BPB.SectorsPerFAT]
  add   ax, dx
  jc    Error








  cmp   dx, FREE_LOWER_SEC
  jae   Error






  ; # Calcular inicio da FAT #

  ; # Ler FAT #

  ; # Calcular inicio do ROOT #
    ; Calcular tamanho da FAT

  ; # Ler ROOT #

  ; # Procurar arquivo #

  ; # Ler arquivo #






























































  MAXREADERROR    equ 3

  FILENAME_SIZE   equ 11      ; Tamanho dos nomes de arquivos




















_start:


  ; Calcular a posição da FAT
  mov   ax, [BPB.HiddenSectors]
  add   ax, [BPB.ReservedSectors]

  ; Carrega a FAT
  ; ax = lba
  ; dx = 0

  push  ax  ; salva para usar depois

  mov   cx, [BPB.SectorsPerFAT]
  mov   di, FAT_BASE

  call  ReadLBA

  mov   ax, es
  cmp   ax, 0
  jne   Error

  cmp   di, STAGE1_BASE
  jae   Error


  mov   cx, ax                 ; Em setores Root


  ; Calcula o tamanho das FATs
  xor   ax, ax
  mov   al, [BPB.FATs]
  mul   word [BPB.SectorsPerFAT]

  ; Calcula inicio do Root Sector
  pop   dx
  add   ax, dx
  jc    Error

  push  ax                      ; LBA Root
  push  cx                      ; Root Size
  push  di                      ; Memptr

  ; Carrega root dir
  call  ReadLBA

  mov   ax, es
  cmp   ax, 0
  jne   Error

  cmp   di, STAGE1_BASE
  jae   Error



.FoundedFile:
  ; Verifica tipo do arquivo
  test  byte [bx + 11], 0x18              ; Diretorio e volumeid
  jnz   Error

  ; Pega o primeiro cruster do arquivo
  mov   ax, [bx + 26]
  mov   [bootfile_cluster], ax

  ; Pega o tamanho em bytes
  mov   ax, [bx + 28]
  mov   dx, [bx + 30]

  mov   [bootfile_size], ax
  mov   [bootfile_size + 2], dx





halt:
  jmp halt
































;===========================================================================
;
; ############################ Procedimentos ############################
;
;===========================================================================




;===========================================================================
; Error
; --------------------------------------------------------------------------
; Mostra mensagem de erro e poe em modo halt
;===========================================================================

Error:
  mov   si, ERROR_MSG

  mov   ah,0x0E               ; Indica a rotina de teletipo da BIOS
  mov   bx, 0x0007            ; Número da página de vídeo/Texto branco em fundo preto

  cld

.next:
  lodsb
  or    al,al
  jz    Halt                  ; Se al=0, string terminou e salta para Halt
  int   0x10                  ; Se não, chama INT 10 para por caracter na tela
  jmp   .next
.exit:


;===========================================================================
; Halt
; --------------------------------------------------------------------------
; Mantem execucao parada ate que seja resetado
;===========================================================================

Halt:
  hlt
  jmp   Halt










;===========================================================================
;
; ############################ DATA ############################
;
;===========================================================================

  ERROR_MSG         db  'Disco sem sistema ou sistema defeituoso!', 0

  FileName          db  'BOOT    BIN'






;===========================================================================
;
; ############################ BSS ############################
;
;===========================================================================

SECTION .bss
; ### Variaveis criadas pelo bootloader ###

  erro_count          resb  1

  root_mem            resw  1
