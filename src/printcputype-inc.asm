;===============================================================================
; PrintCPUType
; ------------------------------------------------------------------------------
; Exibe o tipo de CPU
;===============================================================================

PrintCPUType:
  push  ax

  cmp   ax, 5
  jae   .5

  cmp   ax, 4
  jae   .4

  cmp   ax, 3
  jae   .3

  cmp   ax, 2
  jae   .2

  mov   ax, CPU8086_MSG
  jmp   .print

.2:
  mov   ax, CPU286_MSG
  jmp   .print

.3:
  mov   ax, CPU386_MSG
  jmp   .print

.4:
  mov   ax, CPU486_MSG
  jmp   .print

.5:
  mov   ax, CPU586_MSG

.print:
  call  WriteAStr

  mov   ax, NEWLINE
  call  WriteAStr

  pop   ax
ret
