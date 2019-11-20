;===========================================================================
; PrintPartitionInfo
; --------------------------------------------------------------------------
; DS:AX - PartitionInfo
;===========================================================================

PrintPartitionInfo:
  push  si
  push  dx

  mov   si, ax

  ; Imprime Label
  mov   ax, VOLUMELABEL_MSG
  call  WriteAStr

  lea   ax, [si + PartitionInfoStruct.VolumeLabel]
  call  WriteAStr

  ; Imprime ID
  mov   ax, ID_MSG
  call  WriteAStr

  mov   ax, [si + PartitionInfoStruct.ID]
  mov   dx, [si + PartitionInfoStruct.ID + 2]

  push  ax
  mov   ax, dx

  call  WriteWordHex

  pop   ax

  call  WriteWordHex

  ; Imprime OEM
  mov   ax, OEM_MSG
  call  WriteAStr

  lea   ax, [si + PartitionInfoStruct.OEM]
  call  WriteAStr

  ; Imprime Start
  mov   ax, START_MSG
  call  WriteAStr

  mov   eax, [si + PartitionInfoStruct.Start]

  call  WriteUInt32

  ; Imprime Size
  mov   ax, SIZE_MSG
  call  WriteAStr

  mov   eax, [si + PartitionInfoStruct.Size]

  call  WriteUInt32


  ; vReserved Sectors:
  ; Este campo representa o numero de setores que precedem o inicio da primeira
  ; FAT, incluindo o setor de boot. Ele deve sempre ter um valor maior que 1.
;  .ReservedSectors:           resw  1












  pop   dx
  pop   si
ret



struc PartitionInfoStructx     ; FAT






  ; Sectors Per FAT:
  ; Este campo e o numero de setores ocupados por cada uma das FATs do volume.
  ; Com esta informacao, junto com o numero de FATs e setores reservados listados
  ; abaixo, podemos calcular onde inicia o diretorio raiz. Com o numero de
  ; entradas do diretorio raiz, podemos calcular onde inicia a area de dados do
  ; disco.
  .SectorsPerFAT:             resw  1

  ; FATs:
  ; Este campo indica o numero de copias da FAT armazenada no disco.
  ; Tipicamente o valor deste campo e 2.
  .FATs:                      resb  1

  ; Sectors Per Cluster:
  ; Devido a FAT ser limitada em numero de clusters (ou "unidades de alocacao")
  ; que ela pode indexar, volumes grandes sao suportado aumentando o numero de
  ; setores por cluster. Este valor e inteiramente dependente do tamanho do
  ; volume. Valores validos para este campo sao potencia de 2 entre 1 e 128.
  ; Procure na base de conhecimentos da Microsoft sobre o termo
  ; "Tamanho de cluster padrao" para mais informacoes.
  .SectorsPerCluster:         resb  1

  ; Root Entries:
  ; Este campo e o numero total de entradas de nome de arquivos que pode ser
  ; armazenada no diretorio raiz do volume. Em um HD tipico, o valor deste campo
  ; e 512. Note, entretanto, que uma entrada e sempre usada como Nome de Volume,
  ; e que arquivos com nomes logos usam multiplas entradas por arquivo. Desta
  ; forma o maior numero de arquivos no diretorio raiz e, tipicamente, 511. Mas
  ; voce vai descartar entradas se nomes longos sao usados.
  .RootEntries:               resw  1

  ; LBA de inicio da primeira FAT
  .FATLBA:                    resw  1

  ; LBA de inicio do diretorio raiz
  .RootLBA:                   resw  1

  ; LBA de inicio da area de dados
  .DataLBA:                   resw  1

  .End:
endstruc

