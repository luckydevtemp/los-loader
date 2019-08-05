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
; readlbs-inc.asm
; ------------------------------------------------------------------------------
; Arquivo include com a rotina ReadLBA
; ------------------------------------------------------------------------------
; Criado em: 04/08/2019
; ------------------------------------------------------------------------------
; Compilar: Nao compilavel (e utilizado por outro arquivo)
; ------------------------------------------------------------------------------
; Executar: Nao executavel
;===============================================================================


;===============================================================================
; ReadLBA
; ------------------------------------------------------------------------------
; Le setores em LBA
;
; DX:AX - Setor LBA
; CX    - Q
; SI    - DiskInfo
; ES:DI - Buffer
;===============================================================================

ReadLBA:
  push  bx

  push  bp
  mov   bp, sp

.next:
  or    cx, cx
  jz    .exit

  push  cx
  push  ax
  push  dx
  push  es
  push  di

  call  LBA2CHS
  jc    .error

  mov   bx, di

  call  ReadCHS                         ; ax = setores lidos
  jc    .error

  mov   bx, ax                          ; bx = setores lidos

  ; Calcula bytes lidos
  xor   dx, dx
  mov   ax, SECTOR_SIZE
  mul   bx

  ; Corrige endereco do buffer
  pop   di

  add   di, ax
  adc   dx, 0

  mov   cl, 12
  shl   dx, cl
  jc    .error

  pop   ax                              ; Valor de ES

  add   ax, dx
  jc    .error

  mov   es, ax

  ; Calcula novo setor LBA
  pop   dx
  pop   ax

  add   ax, bx
  adc   dx, 0

  pop   cx

  cmp   bx, cx
  ja    .error

  sub   cx, bx
  jmp   .next

.exit:
  mov   sp, bp
  pop   bp

  pop   bx
ret

.error:
  mov   sp, bp
  pop   bp

  pop   bx
  stc
ret
