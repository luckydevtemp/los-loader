  MAXREADERROR    equ 3



  %define   TINY
;===========================================================================
; ReadCHS
; --------------------------------------------------------------------------
; DX:AX - C:H,S
; CL    - Q
; SI    - DiskInfo
; ES:BX - Buffer
;===========================================================================

ReadCHS:
  mov   byte [si + DiskInfoStruct.ErrorCount], 0

  push  bx

  %ifndef TINY
    ; Verifica se CHS estão corretos
    cmp   dx, [si + DiskInfoStruct.Cylinders]
    jae   .error

    xor   bx, bx
    mov   bl, ah
    cmp   bx, [si + DiskInfoStruct.Heads]
    jae   .error

    mov   bl, [si + DiskInfoStruct.Sectors]
    cmp   al, bl
    ja    .error

    ; Verifica quantidade a ler
    sub   bl, al
    inc   bl

    cmp   bl, cl                ; compara quantidade passada com o restante de setores
    jae   .1

    mov   cl, bl

  .1:
    push  ax
    push  dx
    xor   ax, ax
    mov   dx, 1

    sub   ax, di
    sbb   dx, 0

    mov   bx, SECTOR_SIZE
    div   bx

    xor   ch, ch
    cmp   ax, cx
    jae   .2

    mov   cl, al

  .2:
    pop   dx
    pop   ax

    test  cl, cl
    jz    .error
  %endif

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
  jbe   .3

  mov   al, 128

.3:
  mov   ah, 0x02              ; funcao da BIOS
  pop   bx

.4:
  push  ax
  int   0x13

  test  al, al
  jnz   .5

  ; Verifica quantidade de erros
  inc   byte [si + DiskInfoStruct.ErrorCount]
  cmp   byte [si + DiskInfoStruct.ErrorCount], MAXREADERROR
  ja    Error

  mov   al, [si + DiskInfoStruct.DriveNumber]
  call  ResetDisk
  jc    Error

  pop   ax
  jmp   .4

.5:
  pop   cx
ret

%ifndef TINY
  .error:
    pop   bx
    xor   ax, ax
    stc
  ret
%endif


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
