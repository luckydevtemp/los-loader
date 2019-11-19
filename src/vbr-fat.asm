;===============================================================================
; Este arquivo pertence ao Projeto do Sistema Operacional LuckyOS (LOS).
; ------------------------------------------------------------------------------
; Copyright (C) 2013 - Luciano L. Goncalez
; ------------------------------------------------------------------------------
; eMail : dev.lucianogoncalez@gmail.com
; Home  : http://lucky-labs.blogspot.com.br
;===============================================================================
;   Este programa e software livre; voce pode redistribui-lo e/ou modifica-lo
; sob os termos da Licenca Publica Geral GNU, conforme publicada pela Free
; Software Foundation; na versao 2 da Licenca.
;
; Este programa e distribuido na expectativa de ser util, mas SEM QUALQUER
; GARANTIA; sem mesmo a garantia implicita de COMERCIALIZACAO ou de ADEQUACAO A
; QUALQUER PROPOSITO EM PARTICULAR. Consulte a Licenca Publica Geral GNU para
; obter mais detalhes.
;
; Voce deve ter recebido uma copia da Licenca Publica Geral GNU junto com este
; programa; se nao, escreva para a Free Software Foundation, Inc., 59 Temple
; Place, Suite 330, Boston, MA 02111-1307, USA. Ou acesse o site do GNU e
; obtenha sua licenca: http://www.gnu.org/
;===============================================================================
; vbr-fat.asm (stage_0)
; ------------------------------------------------------------------------------
; LOS Boot Sector - Floppy FAT12/16
;
;   Volume Boot Record, ou stage_0, parte do bootloader responsável por
; localizar o stage_1 e carregá-lo para a memória e, em seguida, executá-lo.
; ------------------------------------------------------------------------------
; Criado em: 04/08/2019
; ------------------------------------------------------------------------------
; Compilar: Compilavel pelo nasm (montar)
; > nasm -f bin vbr-fat.asm
; ------------------------------------------------------------------------------
; Executar: Este arquivo deve ser instalado no VBR de uma partição FAT12/16.
;===============================================================================


;===============================================================================
;
; ################################ Referências #################################
;
; ------------------------------------------------------------------------------
; (https://wiki.osdev.org/FAT)
; (http://www.maverick-os.dk/FileSystemFormats/FAT12_FileSystem.html)
;===============================================================================


;===============================================================================
; FAT12/16 File System Structure Region
;===============================================================================
; Reserved Region (incl. Boot Sector)
; ------------------------------------------------------------------------------
; File Allocation Table (FAT)
; ------------------------------------------------------------------------------
; Root Directory
; ------------------------------------------------------------------------------
; Data Region
;===============================================================================


;===============================================================================
;
; ################################# Definições #################################
;
;===============================================================================

  ;   O STAGE_0 será mínimo e fará a leitura da FAT, devendo carregar o STAGE_1
  ; de algum lugar fixo no disco. O STAGE_1 será autodeslocável, com até 64k de
  ; tamanho e terá todo o código necessário para carregar o STAGE_2.
  STAGE0_BASE     equ 0x7C00

  ; A posição do STAGE_1 é definida em segmentos, com offset 0
  STAGE1_SEG      equ 0x0800

  ; A posição da pilha é logo abaixo do STAGE_0
  STACK_BASE      equ STAGE0_BASE - 4   ; 4 bytes abaixo do vbr

  ;   Tamanho do setor é usado para calcular o posicionamento memória.
  ; Por enquanto, somente setores de 512 bytes são suportados.
  SECTOR_SIZE     equ 512               ; valor fixo, utilizado p/ evitar erros

  ; Quantidade máxima de setores que cabe em um segmento de memória
  MAXSECTORS      equ (0x10000 / SECTOR_SIZE)

  ; A quantidade de setores (STAGE1_SECTORS) deve ser passada via macro.

  %if (STAGE1_SECTORS > MAXSECTORS)
    %error "O tamanho do STAGE_1 não pode ultrapassar UM segmento de memória!"
  %endif

  ; Estrutura de informações de disco
  %include "diskinfo-inc.asm"

  ; Assinaturas usadas nos estágios de boot
  %include "losboot_sig-inc.asm"



;===============================================================================
;
; ################################### Código ###################################
;
;===============================================================================

SECTION .text
[ORG STAGE0_BASE]
[BITS 16]
[CPU 8086]

  jmp   Start
  times 0x03 - ($ - $$) nop


; ------------------------------------------------------------------------------
; ### OEM ###
; ------------------------------------------------------------------------------
OEMID:
  db    'LUCKY_OS'                      ; OEM (DB 8 Bytes)
  times 0x0B - ($ - $$) db 0x20


; ------------------------------------------------------------------------------
; ### BPB [todas as FATs] ###
; ------------------------------------------------------------------------------
; (Os dados aqui são configurados por formatação, antes da instalação do vbr)

BPB:
  ; Bytes Per Sector:
  ; Este é o tamanho do setor fisico, este valor deve ser 512.
  .BytesPerSector:
    dw  0x0000                          ; padrão 0x0200 (512)

  ; Sectors Per Cluster:
  ; Devido a FAT ser limitada em numero de clusters (ou "unidades de alocacao")
  ; que ela pode indexar, volumes grandes sao suportado aumentando o numero de
  ; setores por cluster. Este valor e inteiramente dependente do tamanho do
  ; volume. Valores validos para este campo sao potencia de 2 entre 1 e 128.
  ; Procure na base de conhecimentos da Microsoft sobre o termo
  ; "Tamanho de cluster padrao" para mais informacoes.
  .SectorsPerCluster:
    db  0x00                            ; padrão 0x01

  ; vReserved Sectors:
  ; Este campo representa o numero de setores que precedem o inicio da primeira
  ; FAT, incluindo o setor de boot. Ele deve sempre ter um valor maior que 1.
  .ReservedSectors:
    dw  0x0000                          ; padrão 0x0001

  ; FATs:
  ; Este campo indica o numero de copias da FAT armazenada no disco.
  ; Tipicamente o valor deste campo e 2.
  .FATs:
    db  0x00                            ; padrão 0x02

  ; Root Entries:
  ; Este campo e o numero total de entradas de nome de arquivos que pode ser
  ; armazenada no diretorio raiz do volume. Em um HD tipico, o valor deste campo
  ; e 512. Note, entretanto, que uma entrada e sempre usada como Nome de Volume,
  ; e que arquivos com nomes logos usam multiplas entradas por arquivo. Desta
  ; forma o maior numero de arquivos no diretorio raiz e, tipicamente, 511. Mas
  ; voce vai descartar entradas se nomes longos sao usados.
  .RootEntries:
    dw  0x0000                          ; padrão 0x00E0 (224)

  ; Small Sectors:
  ; Este campo e usado para armazenar o numero de setor de um disco se o tamanho
  ; do volume e pequeno. Para volumes grandes, este campo tem valor 0, e nos
  ; referimos a "Large Secors" ao inves deste.
  .SmallSectors:
    dw  0x0000                          ; padrão 0x0B40 (2880 (LBA))

  ; Media Descriptor:
  ; Este campo informa sobre o tipo de midia usada. A tabela seguinte lista
  ; varios valores de descritores de midia reconhecidos e suas midias associadas.
  ; Note que este campo pode estar associado com mais que uma capacidade de disco.
  ;   Byte   Capacity   Media Size and Type
  ;   F0     2.88 MB    3.5-inch, 2-sided, 36-sector
  ;   F0     1.44 MB    3.5-inch, 2-sided, 18-sector
  ;   F9     720 KB     3.5-inch, 2-sided, 9-sector
  ;   F9     1.2 MB     5.25-inch, 2-sided, 15-sector
  ;   FD     360 KB     5.25-inch, 2-sided, 9-sector
  ;   FF     320 KB     5.25-inch, 2-sided, 8-sector
  ;   FC     180 KB     5.25-inch, 1-sided, 9-sector
  ;   FE     160 KB     5.25-inch, 1-sided, 8-sector
  ;   F8     -----      Fixed disk
  .MediaDescriptor:
    db  0x00                            ; padrão 0xF0

  ; Sectors Per FAT:
  ; Este campo e o numero de setores ocupados por cada uma das FATs do volume.
  ; Com esta informacao, junto com o numero de FATs e setores reservados listados
  ; abaixo, podemos calcular onde inicia o diretorio raiz. Com o numero de
  ; entradas do diretorio raiz, podemos calcular onde inicia a area de dados do
  ; disco.
  .SectorsPerFAT:
    dw  0x0000                          ; padrão 0x0009

  ; Sectors Per Track and Heads:
  ; Este valores sao parte da geometria aparente do disco em uso.

  .SectorsPerTrack:
    dw  0x0000                          ; padrão 0x0012 (18)

  .Heads:
    dw  0x0000                          ; padrão 0x0002

  ; Hidden Sectors:
  ; Este campo e o numero de setores fisicos do disco que precedem o inicio do
  ; volume (antes do setor de boot). Ele e usado durante a sequencia de boot
  ; para calcular o offset absoluto do diretorio raiz e da area de dados.
  .HiddenSectors:
    dd  0x0000_0000

  ; Large Sectors:
  ; Se o campo Small Sectors e 0, este campo contem o numero total de setores do
  ; volume.
  .LargeSectors:
    dd  0x0000_0000                     ; padrão 0x0000_0B40 (2880)


; ------------------------------------------------------------------------------
; ### eBPB [FAT 12/16] ###
; ------------------------------------------------------------------------------

  ; Physical Drive Number:
  ; Este campo e usado para indicar a BIOS o numero do drive fisico. Disquetes
  ; soa numerados iniciando de 0x00 para o drive A:, enquanto HDs sao numerados
  ; iniciando em 0x80. Tipicamente voce deve usar esse valor em uma chamada
  ; da INT 13 da BIOS para especificar o dispositivo a acessar. O valor armazenado
  ; no disco e tipicamente 0x00 para disquetes e 0x80 para HDs independente da
  ; quantidade de discos fisicos existentes, por que o valor somente e relevante
  ; se o dispositivo e usado no boot.
  .PhysicalDriveNumber:
    db  0x00

  ; Current Head:
  ; Este e outro campo tipicamnte usado durante uma chamada da INT13. O valor
  ; deve, originalmente, armazenar  a track em que o boot record esta localizado,
  ; mas o valor usado no disco nao e atualmente usado para isso. Portanto, o
  ; Windows NT usa este campo para armazenar duas flags:
  ;   - O bit de menor ordem e uma flag "sujo", usada para indicar que o autochk
  ;   deve ser executado no volume durante o tempo de boot.
  ;   - O segundo bit de menor ordem e uma flag indicando que o teste de
  ;   superficie tambem deve ser executado.
  .CurrentHead:
    db  0x00        ; CurrentHead / WinNTFlags (01b = chkdsk/ 10b = surface scan)

  ; Signature:
  ; Este valor deve ser 0x28 ou 0x29 para ser reconhecido pelo Windows NT.
  .Signature:
    db  0x00                            ; padrão 0x29

  ; ID:
  ; Este campo e um numero de serie randomico associado ao volume durante a
  ; formatacao para ajudar a distinguir um disco de outro.
  .ID:
    dd  0x0000_0000                     ; VolumeID (Ramdom)

  ; Volume Label:
  ; Este campo era usado para armazenar o nome de volume, mas o nome de volume
  ; e, agora, armazenado em um arquivo especial no diretorio raiz.
  .VolumeLabel:
    times 11 db 0x20          ; VolumeLabel (DB 11 Bytes, definido na formatação)

  ; System ID:
  ; O valor deste campo e "FAT12" ou "FAT16", dependendo do formato do disco.
  .SystemID:
    times 8 db 0x20           ; SystemID (DB 8 Bytes; FAT12 ou FAT16)



; ### start ###

; Valores obtidos no boot do VirtualBox

; AX = 0xAA55
; BX = 0x0000
; CX = 0x0001
; DX = 0x0000

; CS = 0x0000
; DS = 0x0000
; ES = 0x0000
; SS = 0x0000

; SI = 0xF4A0
; DI = 0xFFF0
; SP = 0x7800
; BP = 0x0000



;===============================================================================
; Start
; ------------------------------------------------------------------------------
; Ponto de entrada do VBR
;===============================================================================

Start:
  ; ### Ajustes iniciais ###
  ; Garante que os segmentos sejam zero e configura a pilha dentro deste

  cli
  xor   ax, ax
  mov   ds, ax
  mov   es, ax

  ; Configura a pilha
  mov   ss, ax
  mov   sp, STACK_BASE
  mov   bp, sp
  sti

  ; Normalizando linha de execução
  jmp   0:_normalize                    ; CS, IP


_normalize:
  push  dx                              ; Salva para usar no final

  ; Deixarei a DIPT la na BIOS ja que nao vamos mudar nada aqui

  mov   ax, BOOT_MSG
  call  WriteAStr

  ; Compara tamanho do setor, trabalha somente com 512
  cmp   word [BPB.BytesPerSector], SECTOR_SIZE
  jne   ErrorFS

  ; Inicializa bootdiskinfo
  mov   bx, bootdiskinfo                ; será usado depois

  mov   cx, DISKINFOSIZE
  mov   di, bx

  xor   ax, ax

  cld
  rep   stosb

  mov   [bx + DiskInfoStruct.DriveNumber], dl

  mov   ax, [BPB.Heads]
  mov   [bx + DiskInfoStruct.Heads], ax

  mov   ax, [BPB.SectorsPerTrack]
  test  ah, ah
  jnz   ErrorFS

  mov   [bx + DiskInfoStruct.Sectors], al

  ; ### Carrega o STAGE_1 ###

  ; Numero de setores do STAGE_1 tem que ser menor que o reservado do FS
  mov   cx, STAGE1_SECTORS
  cmp   cx, [BPB.ReservedSectors]
  jae   ErrorFS

  ; ES:DI = endereço de memória = STAGE1_SEG:0
  mov   ax, STAGE1_SEG
  mov   es, ax

  xor   di, di

  mov   ax, [BPB.HiddenSectors]
  mov   dx, [BPB.HiddenSectors + 2]

  add   ax, 1                           ; Pula o vbr
  adc   dx, 0                           ; DX:AX = endereço LBA

  mov   si, bootdiskinfo

  call  ReadLBA
  jc    ErrorES

  ; ### Verifica assinatura do Stage1 ###

  mov   ax, (STAGE1_SECTORS * SECTOR_SIZE) - STAGE1_SIG_SIZE
  mov   di, ax

  mov   si, STAGE1_SIG
  mov   cx, STAGE1_SIG_SIZE

  repz  cmpsb
  jne   ErrorStage1

  pop   dx

  ; ### Salta para o STAGE1 ###
  ; DL = Numero do drive
jmp   STAGE1_SEG:0



;===============================================================================
;
; ############################### Procedimentos ################################
;
;===============================================================================

  %include "writeastr-inc.asm"
  %include "resetdisk-inc.asm"
  %include "lba2chs-inc.asm"
  %include "readlba-inc.asm"
  %include "readchs-inc.asm"


;===============================================================================
; Error
; ------------------------------------------------------------------------------
; Mostra mensagem de erro e poe em modo halt
;===============================================================================

ErrorES:
  mov   ax, ERROR_ES
  jmp   _Error

ErrorFS:
  mov   ax, ERROR_FS
  jmp   _Error

ErrorStage1:
  mov   ax, ERROR_STAGE1

_Error:
  call  WriteAStr

;===============================================================================
; Halt
; ------------------------------------------------------------------------------
; Mantem execucao parada ate que seja resetado
;===============================================================================

Halt:
  hlt
  jmp   Halt



;===============================================================================
;
; #################################### DATA ####################################
;
;===============================================================================

  BOOT_MSG          db  '# LOS-LOADER #', 10, 13, 10
                    db  '* STAGE_0:', 10, 13, 0

  ERROR_ES          db  '  Falha ES!', 0
  ERROR_FS          db  '  Falha FS!', 0
  ERROR_STAGE1      db  '  Falha Stage_1!', 0

  STAGE1_SIG        db  STAGE1_SIG_VALUE



;===============================================================================
;
; ############################# Assinatura de boot #############################
;
; ------------------------------------------------------------------------------
  times (0x200 - 2) - ($ - $$) db 0
  db 0x55,0xAA
;===============================================================================


;===============================================================================
;
; #################################### BSS #####################################
;
;===============================================================================

SECTION .bss
; ### Variaveis criadas pelo bootloader ###

  bootdiskinfo        resb DISKINFOSIZE
