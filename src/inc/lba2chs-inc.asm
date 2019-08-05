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
; Arquivo include com a rotina LBA2CHS
; ------------------------------------------------------------------------------
; Criado em: 04/08/2019
; ------------------------------------------------------------------------------
; Compilar: Nao compilavel (e utilizado por outro arquivo)
; ------------------------------------------------------------------------------
; Executar: Nao executavel
;===============================================================================


;===============================================================================
; LBA2CHS
; ------------------------------------------------------------------------------
; Procedimento para conversao de LBA para CHS
; ------------------------------------------------------------------------------
; Entra:
;
; DX:AX - LBA
; SI    - DiskInfo
; ------------------------------------------------------------------------------
; Retorna:
;
; DX:AX - C:H,S
;===============================================================================

LBA2CHS:
  push  bx
  push  cx

  xor   bx, bx
  mov   bl, [si + DiskInfoStruct.Sectors]

  ; Verfica se divisão provoca carry
  cmp   dx, bx
  jae   .error

  ; Obtem o setor
  div   bx

  inc   dl
  mov   cl, dl                ; Current Sector

  ; Obtem cabeça e cilindro
  xor   dx, dx
  mov   bx, [si + DiskInfoStruct.Heads]

  div   bx

  mov   ch, dl                ; Current Head

  mov   dx, ax                ; Current Cylinder
  mov   ax, cx

.exit:
  pop cx
  pop bx
ret

.error:
  stc
jmp .exit
