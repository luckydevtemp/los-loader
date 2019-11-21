struc PartitionInfoStruct     ; FAT
  ; OEM (8+1)
  .OEM:                       resb  9

  ; Volume Label (11+1)
  .VolumeLabel:               resb  12

  ; ID:
  ; Este campo e um numero de serie randomico associado ao volume durante a
  ; formatacao para ajudar a distinguir um disco de outro.
  .ID:                        resd  1

  ; Ponteiro FAR para a estrutura de disco
  .DiskInfo:                  resd  1

  ; LBA de inicio da particao
  .Start:                     resd  1

  ; Size (LBA)
  ; Este campo contem o numero total de setores do volume.
  .Size:                      resd  1

  ; vReserved Sectors:
  ; Este campo representa o numero de setores que precedem o inicio da primeira
  ; FAT, incluindo o setor de boot. Ele deve sempre ter um valor maior que 1.
  .ReservedSectors:           resw  1

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

  .RootSectors:               resw  1

  ; LBA de inicio da primeira FAT
  .FATLBA:                    resd  1

  ; LBA de inicio do diretorio raiz
  .RootLBA:                   resd  1

  ; LBA de inicio da area de dados
  .DataLBA:                   resd  1

  ; Total de clusters na FAT
  .Clusters:                  resd  1

  .End:
endstruc

PARTITIONINFOSIZE   equ (PartitionInfoStruct.End - PartitionInfoStruct)
