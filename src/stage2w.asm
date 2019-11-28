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
; stage2w.asm
; ------------------------------------------------------------------------------
;   Arquivo escrito em Assembly que "envolve" o código escrito em linguagem
; de alto nivel, ele server para fazer a inicializacao inicial do stage2.
; ------------------------------------------------------------------------------
; Criado em: 13/02/2018
; ------------------------------------------------------------------------------
; Compilar: Compilavel pelo nasm (montar)
; > nasm -f bin stage2w.asm
; ------------------------------------------------------------------------------
; Executar: Este arquivo precisa ser linkado com o LD para ser carregado
;   pelo bootloader.
;===========================================================================

; não possui configurações ainda

GLOBAL start

; informacoes da imagem em memoria
EXTERN bootloader_start, bootloader_end
EXTERN bootloader_code, bootloader_data, bootloader_bss

; rotina principal do kernel
EXTERN bootinit


SECTION .text

[BITS 32]

start:
  ; Ajustando valor da base da pilha passada a bootinit
  mov   eax, ebp
  add   eax, 4
  push  eax

  call  bootinit
