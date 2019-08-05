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
; writeastr-inc.asm
; ------------------------------------------------------------------------------
; Arquivo include com a rotina WriteAStr
; ------------------------------------------------------------------------------
; Criado em: 04/08/2019
; ------------------------------------------------------------------------------
; Compilar: Nao compilavel (e utilizado por outro arquivo)
; ------------------------------------------------------------------------------
; Executar: Nao executavel
;===============================================================================


;===============================================================================
; WriteAStr
; ------------------------------------------------------------------------------
; Imprime a string terminada em zero contida no endereço DS:AX
;===============================================================================

WriteAStr:
  push  si
  push  bx

  mov   si, ax

  mov   ah,0x0E     ; Indica a rotina de teletipo da BIOS
  mov   bx, 0x0007  ; Número da página de vídeo/Texto branco em fundo preto

  cld

.next:
  lodsb
  or    al,al
  jz    .exit       ; Se al=0, string terminou e salta para .exit
  int   0x10        ; Se não, chama INT 10 para por caracter na tela
  jmp   .next
.exit:
  pop   bx
  pop   si
ret                 ; Retorna à rotina principal
