;===========================================================================
; InitDiskInfo
; --------------------------------------------------------------------------
; AL    - DriveNumber
; DS:BX - DiskInfo
;===========================================================================

InitDiskInfo:
  push  cx
  push  dx
  push  es
  push  di

  mov   dl, al

  ; Inicializa registro
  xor   ax, ax
  mov   cx, DISKINFOSIZE

  push  ds
  pop   es

  mov   di, bx
  rep   stosb

  mov   [bx + DiskInfoStruct.DriveNumber], dl

  push  bx

  mov   ah, 0x08
  int   0x13
  jc    .exit

  mov   al, bl
  pop   bx

  mov   [bx + DiskInfoStruct.DriveType], al

  xor   dl, dl
  xchg  dl, dh
  inc   dx
  mov   [bx + DiskInfoStruct.Heads], dx

  mov   al, cl
  and   al, 0x3F
  mov   [bx + DiskInfoStruct.Sectors], al

  mov   ax, cx
  mov   cl, 6
  shr   al, cl
  xchg  ah, al
  inc   ax
  mov   [bx + DiskInfoStruct.Cylinders], ax

  mov   al, DISKINFO_INITFLAG
  mov   [bx + DiskInfoStruct.Flags], al

  push  bx    ; necessário para balancear a pilha se der erro

.exit:
  pop   bx    ; necessário para balancear a pilha se der erro
  pop   di
  pop   es
  pop   dx
  pop   cx
ret


;===========================================================================
; DISK - GET DRIVE PARAMETERS (PC,XT286,CONV,PS,ESDI,SCSI)
;===========================================================================
; AH = 08h
; DL = drive (bit 7 set for hard disk)
; ES:DI = 0000h:0000h to guard against BIOS bugs
; --------------------------------------------------------------------------
; Return:
; CF set on error
; AH = status (07h) (see #00234)
; CF clear if successful
; AH = 00h
; AL = 00h on at least some BIOSes
; BL = drive type (AT/PS2 floppies only) (see #00242)
; CH = low eight bits of maximum cylinder number
; CL = maximum sector number (bits 5-0)
; high two bits of maximum cylinder number (bits 7-6)
; DH = maximum head number
; DL = number of drives
; ES:DI -> drive parameter table (floppies only)
;===========================================================================
