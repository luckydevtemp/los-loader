;===========================================================================
; SearchFile
; --------------------------------------------------------------------------
; Localiza o stage2 na FAT
;===========================================================================

_SearchFile:
  mov   dx, [BPB.RootEntries]
  mov   bx, root_base

  mov   cx, FILENAME_SIZE
  mov   si, FileName

.loop:
  mov   di, bx

  push  cx
  push  si

  repz  cmpsb
  je    .FoundedFile

  pop   si
  pop   cx

  add   bx, DIRENTRY_SIZE
  dec   dx
  jnz   .loop

  jmp   Error
