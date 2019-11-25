struc FileInfoStruct
  ; Tamanho em bytes
  .Size                       resd  1

  ; Cluster inicial
  .Cluster                    resw  1

  ; Quantidade de setores
  .Sectors                    resw  1

  .End:
endstruc

FILEINFOSIZE    equ (FileInfoStruct.End - FileInfoStruct)
