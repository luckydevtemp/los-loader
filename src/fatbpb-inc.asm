
;===============================================================================
;
; ################################ Referências #################################
;
; ------------------------------------------------------------------------------
; (https://wiki.osdev.org/FAT)
; (http://www.maverick-os.dk/FileSystemFormats/FAT12_FileSystem.html)
;===============================================================================


;===============================================================================
; FAT12/16 File System Structure Region
;===============================================================================
; Reserved Region (incl. Boot Sector)
; ------------------------------------------------------------------------------
; File Allocation Table (FAT)
; ------------------------------------------------------------------------------
; Root Directory
; ------------------------------------------------------------------------------
; Data Region
;===============================================================================

; ------------------------------------------------------------------------------
; ### BPB [todas as FATs] ###
; ------------------------------------------------------------------------------

struc FAT_BPB
  ; Jump inicial
  .StartJump:                 resb  3

  ; OEM (DB 8 Bytes)
  .OEM:                       resb  8

  ; Bytes Per Sector:
  ; Este é o tamanho do setor fisico, este valor deve ser 512.
  .BytesPerSector:            resw  1             ; padrão 0x0200 (512)

  ; Sectors Per Cluster:
  ; Devido a FAT ser limitada em numero de clusters (ou "unidades de alocacao")
  ; que ela pode indexar, volumes grandes sao suportado aumentando o numero de
  ; setores por cluster. Este valor e inteiramente dependente do tamanho do
  ; volume. Valores validos para este campo sao potencia de 2 entre 1 e 128.
  ; Procure na base de conhecimentos da Microsoft sobre o termo
  ; "Tamanho de cluster padrao" para mais informacoes.
  .SectorsPerCluster:         resb  1             ; padrão 0x01

  ; vReserved Sectors:
  ; Este campo representa o numero de setores que precedem o inicio da primeira
  ; FAT, incluindo o setor de boot. Ele deve sempre ter um valor maior que 1.
  .ReservedSectors:           resw  1             ; padrão 0x0001

  ; FATs:
  ; Este campo indica o numero de copias da FAT armazenada no disco.
  ; Tipicamente o valor deste campo e 2.
  .FATs:                      resb  1             ; padrão 0x02

  ; Root Entries:
  ; Este campo e o numero total de entradas de nome de arquivos que pode ser
  ; armazenada no diretorio raiz do volume. Em um HD tipico, o valor deste campo
  ; e 512. Note, entretanto, que uma entrada e sempre usada como Nome de Volume,
  ; e que arquivos com nomes logos usam multiplas entradas por arquivo. Desta
  ; forma o maior numero de arquivos no diretorio raiz e, tipicamente, 511. Mas
  ; voce vai descartar entradas se nomes longos sao usados.
  .RootEntries:               resw  1             ; padrão 0x00E0 (224)

  ; Small Sectors:
  ; Este campo e usado para armazenar o numero de setor de um disco se o tamanho
  ; do volume e pequeno. Para volumes grandes, este campo tem valor 0, e nos
  ; referimos a "Large Secors" ao inves deste.
  .SmallSectors:              resw  1             ; padrão 0x0B40 (2880 (LBA))

  ; Media Descriptor:
  ; Este campo informa sobre o tipo de midia usada. A tabela seguinte lista
  ; varios valores de descritores de midia reconhecidos e suas midias associadas.
  ; Note que este campo pode estar associado com mais que uma capacidade de disco.
  ;   Byte   Capacity   Media Size and Type
  ;   F0     2.88 MB    3.5-inch, 2-sided, 36-sector
  ;   F0     1.44 MB    3.5-inch, 2-sided, 18-sector
  ;   F9     720 KB     3.5-inch, 2-sided, 9-sector
  ;   F9     1.2 MB     5.25-inch, 2-sided, 15-sector
  ;   FD     360 KB     5.25-inch, 2-sided, 9-sector
  ;   FF     320 KB     5.25-inch, 2-sided, 8-sector
  ;   FC     180 KB     5.25-inch, 1-sided, 9-sector
  ;   FE     160 KB     5.25-inch, 1-sided, 8-sector
  ;   F8     -----      Fixed disk
  .MediaDescriptor:           resb  1             ; padrão 0xF0

  ; Sectors Per FAT:
  ; Este campo e o numero de setores ocupados por cada uma das FATs do volume.
  ; Com esta informacao, junto com o numero de FATs e setores reservados listados
  ; abaixo, podemos calcular onde inicia o diretorio raiz. Com o numero de
  ; entradas do diretorio raiz, podemos calcular onde inicia a area de dados do
  ; disco.
  .SectorsPerFAT:             resw  1             ; padrão 0x0009

  ; Sectors Per Track and Heads:
  ; Este valores sao parte da geometria aparente do disco em uso.
  .SectorsPerTrack:           resw  1             ; padrão 0x0012 (18)
  .Heads                      resw  1             ; padrão 0x0002

  ; Hidden Sectors:
  ; Este campo e o numero de setores fisicos do disco que precedem o inicio do
  ; volume (antes do setor de boot). Ele e usado durante a sequencia de boot
  ; para calcular o offset absoluto do diretorio raiz e da area de dados.
  .HiddenSectors:             resd  1

  ; Large Sectors:
  ; Se o campo Small Sectors e 0, este campo contem o numero total de setores do
  ; volume.
  .LargeSectors:              resd  1             ; padrão 0x0000_0B40 (2880)
  .End:
endstruc

  FAT_BPB_SIZE  equ (FAT_BPB.End - FAT_BPB)


; ------------------------------------------------------------------------------
; ### eBPB [FAT 12/16] ###
; ------------------------------------------------------------------------------

struc FAT1x_eBPB
  ; Estrutura base acessada por FAT_BPB
  .FAT_BPB:                   resb  FAT_BPB_SIZE

  ; Physical Drive Number:
  ; Este campo e usado para indicar a BIOS o numero do drive fisico. Disquetes
  ; soa numerados iniciando de 0x00 para o drive A:, enquanto HDs sao numerados
  ; iniciando em 0x80. Tipicamente voce deve usar esse valor em uma chamada
  ; da INT 13 da BIOS para especificar o dispositivo a acessar. O valor armazenado
  ; no disco e tipicamente 0x00 para disquetes e 0x80 para HDs independente da
  ; quantidade de discos fisicos existentes, por que o valor somente e relevante
  ; se o dispositivo e usado no boot.
  .PhysicalDriveNumber:       resb  1

  ; Current Head:
  ; Este e outro campo tipicamnte usado durante uma chamada da INT13. O valor
  ; deve, originalmente, armazenar  a track em que o boot record esta localizado,
  ; mas o valor usado no disco nao e atualmente usado para isso. Portanto, o
  ; Windows NT usa este campo para armazenar duas flags:
  ;   - O bit de menor ordem e uma flag "sujo", usada para indicar que o autochk
  ;   deve ser executado no volume durante o tempo de boot.
  ;   - O segundo bit de menor ordem e uma flag indicando que o teste de
  ;   superficie tambem deve ser executado.
  ;
  ; Pode armazenar: WinNTFlags (01b = chkdsk/ 10b = surface scan)
  .CurrentHead:               resb  1

  ; Signature:
  ; Este valor deve ser 0x28 ou 0x29 para ser reconhecido pelo Windows NT.
  .Signature:                 resb  1             ; padrão 0x29

  ; ID:
  ; Este campo e um numero de serie randomico associado ao volume durante a
  ; formatacao para ajudaer a distinguir um disco de outro.
  .ID:                        resd  1             ; VolumeID (Ramdom)

  ; Volume Label:
  ; Este campo era usado para armazenar o nome de volume, mas o nome de volume
  ; e, agora, armazenado em um arquivo especial no diretorio raiz.
  .VolumeLabel:               resb  11

  ; System ID:
  ; O valor deste campo e "FAT12" ou "FAT16", dependendo do formato do disco.
  .SystemID:                  resb  1
  .End:
endstruc

  FAT1x_eBPB_SIZE   equ (FAT1x_eBPB.End - FAT1x_eBPB)
