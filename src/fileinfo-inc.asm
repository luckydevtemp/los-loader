struc FileInfoStruct
  ; Ponteiro para Informação da partição
  .PartitionInfo              resw  1

  ; Tamanho em bytes
  .Size                       resd  1

  ; Cluster inicial
  .Cluster                    resw  1

  .End:
endstruc

FILEINFOSIZE    equ (FileInfoStruct.End - FileInfoStruct)
