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
; readchs-inc.asm
; ------------------------------------------------------------------------------
; Arquivo include com a rotina ReadCHS
; ------------------------------------------------------------------------------
; Criado em: 04/08/2019
; ------------------------------------------------------------------------------
; Compilar: Nao compilavel (e utilizado por outro arquivo)
; ------------------------------------------------------------------------------
; Executar: Nao executavel
;===============================================================================


  MAXREADERROR    equ 3

;===========================================================================
; ReadCHS
; --------------------------------------------------------------------------
; DX:AX - C:H,S
; CX    - Q
; SI    - DiskInfo
; ES:BX - Buffer
; --------------------------------------------------------------------------
; AX    - Retorna numero de setores lidos
;===========================================================================

ReadCHS:
  mov   byte [si + DiskInfoStruct.ErrorCount], 0

  push  cx                    ; salva para depois  (Q)

  mov   cl, 6
  shl   dh, cl
  xchg  dh, dl

  or    dl, al
  mov   cx, dx

  mov   dh, ah
  mov   dl, [si + DiskInfoStruct.DriveNumber]

  pop   ax                    ; Q

  cmp   ax, 128
  jbe   .1

  mov   al, 128

.1:
  mov   ah, 0x02              ; funcao da BIOS

.2:
  push  ax

  int   0x13

  test  al, al
  jnz   .3

  ; Verifica quantidade de erros
  inc   byte [si + DiskInfoStruct.ErrorCount]
  cmp   byte [si + DiskInfoStruct.ErrorCount], MAXREADERROR
  ja    .error

  mov   al, [si + DiskInfoStruct.DriveNumber]
  call  ResetDisk
  jc    .error

  pop   ax
  jmp   .2

.3:
  pop   cx                    ; descarta pilha
  xor   ah, ah                ; AL retorna setores lidos
ret

.error:
  pop   cx                    ; descarta pilha
  xor   ax, ax
  stc
ret


;===========================================================================
; Procedimento para leitura via int 0x13
; O buffer está em ES:DI
;
; A INT 0x13 usa os seguintes parametros:
;
;   AH = 02
;
;   AL = number of sectors to read  (1-128 dec.)
;   CH = track/cylinder number  (0-1023 dec., see below)
;
;   CL = sector number  (1-17 dec.)
;
;   DH = head number  (0-15 dec.)
;
;   DL = drive number (0=A:, 1=2nd floppy, 80h=drive 0, 81h=drive 1)
;   ES:BX = pointer to buffer
;
; on return:
;   AH = status  (see INT 13,STATUS)
;   AL = number of sectors read
;   CF = 0 if successful
;      = 1 if error
;===========================================================================
