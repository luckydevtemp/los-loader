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

  EBDA_SEG_VETOR  equ 0x040E


;===============================================================================
;
; ################################## FIX DATA ##################################
;
;===============================================================================
ABSOLUTE  0x0600
  ; Aqui ficam as variaveis a serem passados ao stage2
  PhysicalDriveNumber   resb  1
  CPULevel              resb  1
  LowerMemory           resd  1
  ; Aqui ficam as variaveis temporarias que nao podem ficar na secao principal
  CRC32Sum              resd  1


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

  mov   ax, cs
  mov   ds, ax

  xor   ax, ax
  mov   es, ax

  mov   ax, BOOT_MSG
  call  WriteAStr

  ; Copia as informacoes do dispositivo de boot para um lugar na memoria, liberando registradores
  mov   [es:PhysicalDriveNumber], dl

  ; Calcula CRC
  ; Para o calculo dar certo, o campo SelfCRC32 tem que esta zerado, por isso ele é copiado para outro lugar
  mov   ax, [InfoTable.SelfCRC32]
  mov   dx, [InfoTable.SelfCRC32 + 2]

  mov   [es:CRC32Sum], ax
  mov   [es:CRC32Sum + 2], dx

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

  xor   ax, [es:CRC32Sum]
  jnz   ErrorCRCStage1

  xor   dx, [es:CRC32Sum + 2]
  jnz   ErrorCRCStage1

  mov   ax, STAGE1_CRCOK_MSG
  call  WriteAStr

  call  DetectCPULevel
  call  PrintCPUType

  cmp   al, 3                           ; ve se eh um 80386 ou superior
  jb    ErrorCPU                        ; se nao for termina
  mov   [es:CPULevel], al

  ; Temos um 386, pelo menos
  [CPU 386]

  ; Detectar a memoria baixa (<1M)
  xor   ax, ax
  mov   cx, ax

  int   0x12

  mov   cl, 6
  shl   ax, cl                          ; paragrafos total

  mov   cx, [es:EBDA_SEG_VETOR]         ; paragrafo ebda

  cmp   ax, cx
  jbe   .0

  mov   ax, cx

.0:
  ; ax contem o ultimo paragrafo da memoria

  xor   edx, edx
  mov   dx, ax
  shl   edx, 4
  mov   [es:LowerMemory], edx       ; Quantidade de memoria em bytes

  ; Imprime a quantidade de memoria
  mov   ax, LOWERMEMORY_MSG
  call  WriteAStr

  mov   eax, edx
  call  WriteUInt32

  mov   ax, NEWLINE
  call  WriteAStr

  ; Calcula o tamanho total da imagem
  xor   ecx, ecx
  mov   cx, (End - Start)

  ; Calcula inicio do destino
  mov   eax, edx
  sub   eax, ecx

  shr   eax, 4

  push  es
  mov   es, ax
  mov   si, End
  mov   di, End

  std
  rep   movsb

  xor   ax, ax
  mov   dx, ax

  mov   si, Start                       ; ES:SI = endereco para o bloco
  mov   cx, End_Img - Start

  call  CalcCRC32

  pop   es

  xor   ax, [es:CRC32Sum]
  jnz   ErrorCRCStage1

  xor   dx, [es:CRC32Sum + 2]
  jnz   ErrorCRCStage1

  mov   ax, STAGE1_CRCOK_MSG
  call  WriteAStr
































  mov   ax, TEST_MSG
  call  WriteAStr
  call  Halt


;===============================================================================
;
; ############################ Procedimentos 8086 ##############################
;
;===============================================================================

[CPU 8086]


  %include "writeastr-inc.asm"
  %include "calccrc32-inc.asm"
  %include "deteccpu-inc.asm"

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
; ErrorCRCStage1
; ------------------------------------------------------------------------------
; Exibe a mensagem de erro e interrompe
;===============================================================================

ErrorCRCStage1:
  mov   ax, ERROR_CRCSTAGE1_MSG
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
jmp  Halt








;===============================================================================
; PrintCPUType
; ------------------------------------------------------------------------------
; Exibe o tipo de CPU
;===============================================================================

PrintCPUType:
  push  ax

  cmp   ax, 5
  jae   .5

  cmp   ax, 4
  jae   .4

  cmp   ax, 3
  jae   .3

  cmp   ax, 2
  jae   .2

  mov   ax, CPU8086_MSG
  jmp   .print

.2:
  mov   ax, CPU286_MSG
  jmp   .print

.3:
  mov   ax, CPU386_MSG
  jmp   .print

.4:
  mov   ax, CPU486_MSG
  jmp   .print

.5:
  mov   ax, CPU586_MSG

.print:
  call  WriteAStr

  mov   ax, NEWLINE
  call  WriteAStr

  pop   ax
ret







;===============================================================================
;
; ############################# Procedimentos 386 ##############################
;
;===============================================================================

[CPU 386]

  %include "writeuint32-inc.asm"



;===============================================================================
;
; #################################### DATA ####################################
;
;===============================================================================

  NEWLINE               db 10, 13, 0

  BOOT_MSG              db  10, '* STAGE_1:', 10, 13, 0
  STAGE1_CRCOK_MSG      db '  Integridade do Stage_1 OK', 10, 13, 0

  ERROR_CRCSTAGE1_MSG   db '  Soma de verificacao do Stage_1 nao confere. ABORTANDO!', 0
  ERROR_CPULEVEL_MSG    db '  O sistema necessita de uma CPU 80386 ou superior. ABORTANDO!', 0

  CPU8086_MSG           db '  CPU 8086 detectada', 0
  CPU286_MSG            db '  CPU 80286 detectada', 0
  CPU386_MSG            db '  CPU 80386 detectada', 0
  CPU486_MSG            db '  CPU 80486 detectada', 0
  CPU586_MSG            db '  CPU 80586 ou superior detectada', 0

  LOWERMEMORY_MSG       db '  Memoria inferior detectada (bytes): ',0






  TEST_MSG          db  10, 13, 'Chegou ate aqui!', 10, 13, 0

; O endereco inicial da BSS e esse, o restante dos dados da imagem pode ser sobrescrito por ela.
BSS:

;===============================================================================
;
; ############################# Assinatura de boot #############################
;
; ------------------------------------------------------------------------------
; A assinatura deve ser alinhada com setores

  times ((0x200 * STAGE1_SECTORS) - 8) - ($ - $$) db 0
  db 'LOS-BOOT'
;===============================================================================

End_Img


;===============================================================================
;
; #################################### BSS #####################################
;
;===============================================================================
; Criando a secao dessa forma consigo utilizar o espaco final da imagem com a BSS

ABSOLUTE BSS
; ### Variaveis criadas pelo bootloader ###

  Teste   resb 2

BSS_End:

; Define o tamanho final da imagem em memoria
  %if (End_Img >= BSS_End)
    End   equ   End_Img
  %else
    End   equ   BSS_End
  %endif
