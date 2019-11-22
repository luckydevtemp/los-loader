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
; stage1.asm (STUB)
; ------------------------------------------------------------------------------
; LOS-Loader - Stage 1 (STUB)
;
;   Primeiro estagio do bootloader responsável por localizar o stage_2,
; carregá-lo para a memória e, em seguida, executá-lo.
; ------------------------------------------------------------------------------
; Criado em: 04/08/2019
; ------------------------------------------------------------------------------
; Compilar: Compilavel pelo nasm (montar)
; > nasm -f bin stage1.asm
; ------------------------------------------------------------------------------
; Executar: Este arquivo deve ser instalado em um lugar especifico do disco.
;===============================================================================



;===============================================================================
;
; ################################# Definições #################################
;
;===============================================================================

  ; A quantidade de setores (STAGE1_SECTORS) deve ser passada via macro.

  %ifndef CRC_32
    CRC_32          equ 0
  %endif

  EBDA_SEG_VETOR    equ 0x040E

  STACK_SIZE        equ 512

  SEGSIZE_PH        equ 0x1000

  STAGE2_BASE       equ 0x1000      ; 4 kB

  ; Estrutura de informações de disco
  %include "diskinfo-inc.asm"

  ; Assinaturas usadas nos estágios de boot
  %include "losboot_sig-inc.asm"

  ; Estrutura FAT
  %include "fatbpb-inc.asm"

  ; Estrutura de infoções de partição
  %include "partinfo-inc.asm"

  FREEMEM_START     equ (ShareData.End & ~0xF) + 0x10

  ;   Tamanho do setor é usado para calcular o posicionamento memória.
  ; Por enquanto, somente setores de 512 bytes são suportados.
  SECTOR_SIZE     equ 512               ; valor fixo, utilizado p/ evitar erros

  DIRENTRY_SIZE   equ 32          ; Tamanho de uma entrada de diretorio


;===============================================================================
;
; ################################## FIX DATA ##################################
;
;===============================================================================
ABSOLUTE  0x0600

ShareData:
  ; Aqui ficam as variaveis a serem passados ao stage2
  .PhysicalDriveNumber   resb  1
  .CPULevel              resb  1
  .LowerMemory           resd  1
  ; Aqui ficam as variaveis temporarias que nao podem ficar na secao principal
  .CRC32Sum              resd  1

  .End:

;===============================================================================
;
; ################################### Código ###################################
;
;===============================================================================

SECTION .text
[ORG 0x0]
[BITS 16]
[CPU 8086]

Start:
  jmp   Main


; ------------------------------------------------------------------------------
; ### Tabela de informacoes ###
; ------------------------------------------------------------------------------

InfoTable:
  .SelfCRC32   dd CRC_32


;===============================================================================
; Main
; ------------------------------------------------------------------------------
; Funcao principal
;===============================================================================

Main:
  ; ### Ajustes iniciais ###
  ; Garante que os segmentos sejam iguais a CS

  push  cs
  pop   ds

  xor   ax, ax
  mov   es, ax

  ; A pilha fica onde esta por enquanto

  mov   ax, BOOT_MSG
  call  WriteAStr

  ; Copia as informacoes do dispositivo de boot para um lugar na memoria, liberando registradores
  mov   [es:ShareData.PhysicalDriveNumber], dl

  ; Calcula CRC

  mov   ax, CALC_CRC32_MSG
  call  WriteAStr

  ; Para o calculo dar certo, o campo SelfCRC32 tem que esta zerado, por isso ele é copiado para outro lugar
  mov   ax, [InfoTable.SelfCRC32]
  mov   dx, [InfoTable.SelfCRC32 + 2]

  mov   [es:ShareData.CRC32Sum], ax
  mov   [es:ShareData.CRC32Sum + 2], dx

  xor   ax, ax
  mov   dx, ax

  mov   [InfoTable.SelfCRC32], ax
  mov   [InfoTable.SelfCRC32 + 2], dx

  push  es

  push  cs
  pop   es                              ; ES = CS

  mov   si, Start                       ; ES:SI = endereco para o bloco
  mov   cx, End_Img - Start

  call  CalcCRC32

  pop   es

  xor   ax, [es:ShareData.CRC32Sum]
  jnz   .0

  xor   dx, [es:ShareData.CRC32Sum + 2]
  jz   .1

.0:
  mov   ax, FAIL_MSG
  call  WriteAStr

  jmp   Abort

.1:
  mov   ax, OK_MSG
  call  WriteAStr

  call  DetectCPULevel
  call  PrintCPUType

  cmp   al, 3                           ; ve se eh um 80386 ou superior
  jb    ErrorCPU                        ; se nao for termina
  mov   [es:ShareData.CPULevel], al
; ------------------------------------------------------------------------------
; ### Temos pelo menos um 386 ###
; ------------------------------------------------------------------------------
jmp Main_386



;===============================================================================
;
; ############################ Procedimentos 8086 ##############################
;
;===============================================================================


  %include "writeastr-inc.asm"
  %include "calccrc32-inc.asm"
  %include "deteccpu-inc.asm"
  %include "initdiskinfo-inc.asm"
  %include "readlba-inc.asm"
  %include "lba2chs-inc.asm"
  %include "readchs-inc.asm"
  %include "resetdisk-inc.asm"
  %include "printcputype-inc.asm"

  %include "writewhex-inc.asm"

;===============================================================================
; Halt
; ------------------------------------------------------------------------------
; Mantem execucao parada ate que seja resetado
;===============================================================================

Halt:
  hlt
jmp   Halt


;===============================================================================
; Abort
; ------------------------------------------------------------------------------
; Exibe a mensagem de erro e interrompe
;===============================================================================

; modificar aqui para usar errorno
Abort:
  mov   ax, ABORT_MSG
  call  WriteAStr
jmp   Halt



;===============================================================================
; ErrorCPU
; ------------------------------------------------------------------------------
; Exibe a mensagem de erro e interrompe
;===============================================================================

ErrorCPU:
  mov   ax, ERROR_CPULEVEL_MSG
  call  WriteAStr
jmp Abort



;===============================================================================
;
; ################################ Código 386+ #################################
;
;===============================================================================

  [CPU 386]


;===============================================================================
; Main_386
; ------------------------------------------------------------------------------
; Funcao principal com suporte a i386
;===============================================================================

Main_386:
  xor   ax, ax
  mov   gs, ax                          ; utilizando gs para acessar o segmento 0, liberando es

  ; Detectar a memoria baixa (<1M)
  mov   cx, ax                          ; evita erros por funções extras

  int   0x12                            ; ax = kB

  shl   ax, 6                           ; paragrafos total

  mov   cx, [gs:EBDA_SEG_VETOR]         ; paragrafo ebda

  cmp   ax, cx
  jbe   .2

  mov   ax, cx

.2:
  ; ax contem o ultimo paragrafo da memoria

  xor   edx, edx
  mov   dx, ax
  shl   edx, 4
  mov   [gs:ShareData.LowerMemory], edx       ; Quantidade de memoria em bytes

  ; Imprime a quantidade de memoria
  mov   ax, LOWERMEMORY_MSG
  call  WriteAStr

  mov   eax, edx
  call  WriteUInt32

  mov   ax, NEWLINE
  call  WriteAStr

  ; Copia imagem
  mov   ax, COPY_MSG
  call  WriteAStr

  ; Calcula o tamanho total da imagem
  xor   ecx, ecx
  mov   cx, (End - Start)

  ; Calcula inicio do destino
  mov   eax, edx
  sub   eax, ecx
  shr   eax, 4                          ; calcula segmento
  mov   es, ax

  mov   si, (End - 1)
  mov   di, si

  std
  rep   movsb

  ; Confere o CRC
  xor   ax, ax
  mov   dx, ax

  mov   si, Start                       ; ES:SI = endereco para o bloco
  mov   cx, (End_Img - Start)

  call  CalcCRC32

  xor   ax, [gs:ShareData.CRC32Sum]
  jnz   .3

  xor   dx, [gs:ShareData.CRC32Sum + 2]
  jz    .4

.3:
  mov   ax, FAIL_MSG
  call  WriteAStr

  jmp   Abort

.4:
  mov   ax, OK_MSG
  call  WriteAStr

  push  es
  push  Main_High
retf                                    ; salta para a cópia no topo da memória baixa


;===============================================================================
; Main_High
; ------------------------------------------------------------------------------
; Funcao principal no topo da memoria
;===============================================================================

Main_High:
  ; Ajusta segmento de dados
  push  cs
  pop   ds

  ; Ajusta a pilha logo abaixo desse segmento
  cli
  mov   ax, cs
  sub   ax, SEGSIZE_PH
  mov   ss, ax

  xor   ax, ax
  sub   ax, 4
  mov   sp, ax
  mov   bp, ax
  sti

  ; calcula o espaco livre para o Stage_2
  xor   eax, eax

  mov   ax, cs
  shl   eax, 4
  sub   eax, STACK_SIZE

  mov   [FreeMemory], eax

  ; Verifica se disquete
  xor   ax, ax
  mov   al, [gs:ShareData.PhysicalDriveNumber]

  mov   dx, ax
  and   al, 0x80
  jz    .0

  mov   ax, ERROR_HD
  call  WriteAStr

  jmp   Abort

.0:
  mov   ax, DISKINIT_MSG
  call  WriteAStr

  ; Inicializar o disco
  mov   ax, dx
  mov   bx, DiskInfo

  call  InitDiskInfo
  jnc   .1

  mov   ax, ERROR_DISK_INIT
  call  WriteAStr

  jmp   Abort

.1:
  mov   ax, DiskInfo
  mov   si, ax

  call  PrintDiskInfo

  ; Carregar VBR para obter informacoes do FS (fara diferenca quando for HD)
  mov   ax, LOADVBR_MSG
  call  WriteAStr

  ; Inicio da particao LBA
  xor   ax, ax
  mov   dx, ax

  mov   si, DiskInfo
  mov   di, BootPart

  ; Buffer
  mov   es, ax                          ; ES = 0
  mov   bx, FREEMEM_START

  call  InitPartitionInfo

  mov   ax, di
  call  PrintPartitionInfo

  ;Carrega FAT (usa o segmento FS para manter em memoria, começando no offset 0)
  mov   ax, [BootPart + PartitionInfoStruct.SectorsPerFAT]
  mov   cx, SECTOR_SIZE
  mul   cx

  shl   edx, 16
  mov   dx, ax

  mov   eax, [FreeMemory]
  sub   eax, edx

  shr   eax, 4
  mov   fs, ax
  shl   eax, 4

  mov   [FreeMemory], eax

  mov   si, di

  call  LoadFAT






















































Test:


  mov   ax, TEST_MSG
  call  WriteAStr
  call  Halt



;===============================================================================
;
; ############################# Procedimentos 386 ##############################
;
;===============================================================================

[CPU 386]

  %include "writeuint32-inc.asm"
  %include "printdiskinfo-inc.asm"
  %include "initpartinfo-inc.asm"
  %include "printpartinfo-inc.asm"
  %include "loadfat-inc.asm"


;===============================================================================
;
; #################################### DATA ####################################
;
;===============================================================================

  NEWLINE               db 10, 13, 0

  BOOT_MSG              db  10, '* STAGE_1:', 10, 13, 0
  CALC_CRC32_MSG        db '  Calculando Integridade do Stage_1...', 0
  COPY_MSG              db '  Copiando Stage_1 para o topo da memoria...', 0

  FAIL_MSG              db ' [ Falha ]', 10, 13, 0
  OK_MSG                db ' [ OK ]', 10, 13, 0

  ABORT_MSG             db 10, '  ABORTANDO!', 0

  ERROR_CRCSTAGE1_MSG   db '  Soma de verificacao do Stage_1 nao confere. ABORTANDO!', 0
  ERROR_CPULEVEL_MSG    db '  O sistema necessita de uma CPU 80386 ou superior', 10, 13, 0

  CPU8086_MSG           db '  CPU 8086 detectada', 0
  CPU286_MSG            db '  CPU 80286 detectada', 0
  CPU386_MSG            db '  CPU 80386 detectada', 0
  CPU486_MSG            db '  CPU 80486 detectada', 0
  CPU586_MSG            db '  CPU 80586 ou superior detectada', 0

  LOWERMEMORY_MSG       db '  Memoria inferior detectada (bytes): ',0

  ERROR_HD              db '  O boot por HD ainda nao eh suportado!', 10, 13, 0
  ERROR_DISK_INIT       db '  Nao foi possivel inicializar o disco de boot!', 10, 13, 0

  DISKINIT_MSG          db 10, 13, '  Incializando disco:', 10, 13, 0

  FDOTHER_MSG           db ' (Outro...)', 10, 13, 0
  FD1_MSG               db ' (5.25 - 360kB)', 10, 13, 0
  FD2_MSG               db ' (5.25 - 1,2MB)', 10, 13, 0
  FD3_MSG               db ' (3.5 - 720kB)', 10, 13, 0
  FD4_MSG               db ' (3.5 - 1,44MB)', 10, 13, 0

  CHS_MSG               db '  - CHS: ', 0
  LBA_MSG               db 10, 13, '  - LBA: ', 0
  SLASH_MSG             db '/', 0

  ERROR_CALC_LBA        db 10, 13, 'Houve um erro no calculo do LBA', 0

  LOADVBR_MSG           db 10, 13, '  Carregando particao de boot:', 10, 13, 0

  VOLUMELABEL_MSG       db '  - Volume: ', 0
  ID_MSG                db '; ID: ', 0
  OEM_MSG               db '; OEM: ', 0

  START_MSG             db 10, 13, '  - Setores (LBA) => Inicio: ', 0
  SIZE_MSG              db '; Tamanho: ', 0
  RESERVED_MSG          db '; Reservados: ', 0

  FATS_MSG              db 10, 13, '  - FATs => Quantidade: ', 0
  FATSECT_MSG           db '; Setores por FAT: ', 0

  ROOTENTRIES_MSG       db 10, 13, '  - Diretorio raiz => Entradas: ', 0
  ROOTSECTORS_MSG       db '; Setores: ', 0

  CLUSTERS_MSG          db 10, 13, '  - Clusters => Total: ', 0
  CLUSTERSECT_MSG       db '; Setores por cluster: ', 0


  FATLBA_MSG            db 10, 13, '  - Enderecos (LBA) => FAT: ', 0
  ROOTLBA_MSG           db '; Diretorio Raiz: ', 0
  DATALBA_MSG           db '; Areas de Dados: ', 0


  TEST_MSG          db  10, 13, 'Chegou ate aqui!', 10, 13, 0

; O endereco inicial da BSS e esse, o restante dos dados da imagem pode ser sobrescrito por ela.
BSS:

;===============================================================================
;
; ############################# Assinatura de boot #############################
;
; ------------------------------------------------------------------------------
; A assinatura deve ser alinhada com setores

  times ((0x200 * STAGE1_SECTORS) - STAGE1_SIG_SIZE) - ($ - $$) db 0
  db STAGE1_SIG_VALUE
;===============================================================================

End_Img:


;===============================================================================
;
; #################################### BSS #####################################
;
;===============================================================================
; Criando a secao dessa forma consigo utilizar o espaco final da imagem com a BSS

ABSOLUTE BSS
; ### Variaveis criadas pelo bootloader ###

  ; Memoria livre de 0 até o limite usavel
  FreeMemory    resd  1
  DiskInfo      resb  DISKINFOSIZE
  BootPart      resb  PARTITIONINFOSIZE

BSS_End:

; Define o tamanho final da imagem em memoria
  %if (End_Img >= BSS_End)
    End   equ   End_Img
  %else
    End   equ   BSS_End
  %endif
