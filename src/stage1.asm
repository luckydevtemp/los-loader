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
  ; ### Ajustes iniciais ###
  ; Garante que os segmentos sejam iguais a CS

  mov   ax, cs
  mov   ds, ax
  mov   es, ax

  mov   ax, BOOT_MSG
  call  WriteAStr

  mov   ax, TEST_MSG
  call  WriteAStr
  call  Halt



;===============================================================================
;
; ############################### Procedimentos ################################
;
;===============================================================================


  %include "writeastr-inc.asm"

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

  BOOT_MSG          db  10, '* STAGE_1:', 10, 13, 0
  TEST_MSG          db  'Chegou ate aqui!', 10, 13, 0



;===============================================================================
;
; ############################# Assinatura de boot #############################
;
; ------------------------------------------------------------------------------
  times ((0x200 * STAGE1_SECTORS) - 8) - ($ - $$) db 0
  db 'LOS-BOOT'
;===============================================================================
