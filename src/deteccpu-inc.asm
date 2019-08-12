;===========================================================================
;
; ################################# CPU 386 ################################
;
;===========================================================================

DetectCPULevel:
  ; Detectar o tipo de processador
  cli

  ; ------------------------------------------------------------------------
  ; Pega os Flags para teste
  ; ------------------------------------------------------------------------
  pushf
  pop   ax                              ; poe flags em ax

  mov   dx, ax                          ; mantem flags em dx para uso posterior

  ; ------------------------------------------------------------------------
  ; 8086 ou superior
  ; ------------------------------------------------------------------------
  xor   cx, cx                          ; cx = 0, cpu 8086

  ; para debug, simula 8086
  ; or ax, 0x8000                       ; seta o bit 15 (Flags,Reserved)
  ; ^ debug

  and   ax, 0x8000                      ; testa o bit 15
  jnz   .detectado                      ; se bit 15<>0, cpu 8086

  ; ------------------------------------------------------------------------
  ; 80186 ou superior
  ; nao implementado :/
  ; ------------------------------------------------------------------------

  ; ------------------------------------------------------------------------
  ; 80286 ou superior
  ; ------------------------------------------------------------------------
  mov   cl, 2                           ; cpu 80286

  mov   ax, dx                          ; pega os flags no backup
  xor   ax, 0x4000                      ; inverte o bit 14 (Flags.NT)

  push  ax
  popf                                  ; poe novo valore em flags

  ; para debug, simula 80286
  ; push dx
  ; popf
  ; ^ debug

  pushf
  pop   ax                              ; pega os flags da CPU

  xor   ax, dx                          ; compara com os originais
  jz    .detectado                      ; se iguais nao pode complementar o bit 14, cpu 80286

  push  dx
  popf                                  ; volta os flags originais

  ; ------------------------------------------------------------------------
  ; Como eh um 80386 ou superior podemos usar instrucoes 386+ para testar
  ;   os bits ;)
  ; ------------------------------------------------------------------------
  [CPU 386]
  ; ------------------------------------------------------------------------
  ; Pega EFlags para teste
  ; ------------------------------------------------------------------------
  pushfd
  pop   eax                             ; poe EFlags em eax

  mov   edx, eax                        ; mantem EFlags em edx para uso posterior

  ; ------------------------------------------------------------------------
  ; 80386 ou superior
  ; ------------------------------------------------------------------------
  inc   cl                              ; cx = 3, cpu 80386

  xor   eax, 0x40000                    ; inverte o bit 18 (EFlags.AC)

  push  eax
  popfd                                 ; poe novo valor em EFlags

  ; para debug, simula 80386
  ; push edx
  ; popfd
  ; ^ debug

  pushfd
  pop   eax                             ; pega os EFlags da CPU

  xor   eax, edx                        ; compara com os originais
  jz    .detectado                      ; se iguais nao pode complementar o flag 18, cpu 80386

  ; ------------------------------------------------------------------------
  ; 80486 ou superior
  ; ------------------------------------------------------------------------
  inc   cl                              ; cx = 4, cpu 80486

  mov   eax, edx                        ; pega os EFlags originais

  xor   eax, 0x200000                   ; inverte o bit 21 (EFlags.ID)

  push  eax
  popfd                                 ; poe novo valor em EFlags

  ; para debug, simula 80486
  ; push edx
  ; popfd
  ; ^ debug

  pushfd
  pop   eax                             ; pega os EFlags da CPU

  xor   eax, edx                        ; compara com os originais
  jz    .detectado                      ; se iguais nao pode complementar o flag 21, cpu 80486

  ; ------------------------------------------------------------------------
  ; 80586 ou superior
  ; Alguns processadores 80486 possuem CPUID, o que pode confundir, no teste
  ; acima, use CPUID para testar daqui em diante
  ; ------------------------------------------------------------------------
  inc   cl                              ; cx = 5, cpu 80586 ou 80486 com CPUID

  push  edx
  popfd                                 ; Devolve os EFlags originais

  [CPU 8086]                            ; Evita que o restante do codigo fique em 386
.detectado:
  mov   ax, cx
ret

