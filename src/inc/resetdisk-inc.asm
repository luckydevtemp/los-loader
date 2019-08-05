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
; lba2chs-inc.asm
; ------------------------------------------------------------------------------
; Arquivo include com a rotina ResetDisk
; ------------------------------------------------------------------------------
; Criado em: 04/08/2019
; ------------------------------------------------------------------------------
; Compilar: Nao compilavel (e utilizado por outro arquivo)
; ------------------------------------------------------------------------------
; Executar: Nao executavel
;===============================================================================


;===============================================================================
; ResetDisk
; ------------------------------------------------------------------------------
; Provoca um reset no disco em AL
;===============================================================================

ResetDisk:
  push  dx

  mov   dl, al
  xor   ax, ax

  ; INT 13,0000 = reset de disco
  int   0x13

  pop   dx
ret
