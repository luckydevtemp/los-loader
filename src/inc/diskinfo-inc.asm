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
; diskinfo-inc.asm
; ------------------------------------------------------------------------------
; Arquivo include com a estrutura DiskInfoStruct
; ------------------------------------------------------------------------------
; Criado em: 04/08/2019
; ------------------------------------------------------------------------------
; Compilar: Nao compilavel (e utilizado por outro arquivo)
; ------------------------------------------------------------------------------
; Executar: Nao executavel
;===============================================================================


;===============================================================================
; ### DriveInfoStruct ###
;===============================================================================

DISKINFOSIZE        equ (DiskInfoStruct.End - DiskInfoStruct)
DISKINFO_INITFLAG   equ 0x01
DISKINFO_LBAFLAG    equ 0x02

struc DiskInfoStruct
  ; DriveNumber b[0..7]
  ; b7 = 0  : floppies
  ; b7 = 1  : HDs
  ; b[0..6] : id
  .DriveNumber:   resb  1

  ; Define o tipo de floppy
  .DriveType:     resb  1

  ; Cylinders b[0..15]
  ; b[0..10] : Cilindros (0..1023 = 1024)
  .Cylinders:     resw  1

  ; Heads b[0..15]
  ; b[0..8] : Heads (0..255 = 256)
  .Heads:         resw  1

  ; Sectors b[0..7]
  ; b[0..5] : Setores (1..63 = 63)
  .Sectors:       resb  1

  ; Flags b[0..7]
  ; b[0]    : Drive inicializado
  ; b[1]    : Modo LBA
  .Flags:         resb  1

  .ErrorCount:    resb  1
  .End:
endstruc
