{===========================================================================
  Este arquivo pertence ao Projeto do Sistema Operacional LuckyOS (LOS).
  --------------------------------------------------------------------------
  Copyright (C) 2013 - Luciano L. Goncalez
  --------------------------------------------------------------------------
  eMail : dev.lucianogoncalez@gmail.com
  Home  : http://lucky-labs.blogspot.com.br
============================================================================
  Este programa e software livre; voce pode redistribui-lo e/ou modifica-lo
  sob os termos da Licenca Publica Geral GNU, conforme publicada pela Free
  Software Foundation; na versao 2 da Licenca.

  Este programa e distribuido na expectativa de ser util, mas SEM QUALQUER
  GARANTIA; sem mesmo a garantia implicita de COMERCIALIZACAO ou de
  ADEQUACAO A QUALQUER PROPOSITO EM PARTICULAR. Consulte a Licenca Publica
  Geral GNU para obter mais detalhes.

  Voce deve ter recebido uma copia da Licenca Publica Geral GNU junto com
  este programa; se nao, escreva para a Free Software Foundation, Inc., 59
  Temple Place, Suite 330, Boston, MA 02111-1307, USA. Ou acesse o site do
  GNU e obtenha sua licenca: http://www.gnu.org/
============================================================================
  Unit Stage2.pas
  --------------------------------------------------------------------------
  Unit principal do bootloader.
  --------------------------------------------------------------------------
  Criado em: 13/02/2018
  --------------------------------------------------------------------------
  Compilar: Compilavel FPC
  > fpc boot.pas
  ------------------------------------------------------------------------
  Executar: Nao executavel diretamente; Unit.
===========================================================================}

unit Stage2;

interface

  procedure Init(StackBase : DWord);


implementation

uses SystemDef, TTYsDef, GrossTTY, ConsoleIO, StdLib, StdIO, CoreLib;
// , HeapMM;


const
  cLoaderName = 'LOS-LOADER';
  cLoaderVersion = '0.1';
  cLoaderDate = {$I %DATE%};
  cLoaderTime = {$I %TIME%};
  cFPCVersion = {$I %FPCVERSION%};
  cTargetCPU = {$I %FPCTARGETCPU%};

  cMDASeg = $B000;
  cCGASeg = $B800;

  cBDAAddr6845 = $0463;

  cStackSize = 16384; // 16K

  { Enderecos criados pelo linker, usar @ antes dos nomes}
  procedure LoaderStart; external name 'loader_start';
  procedure LoaderCode; external name 'loader_code';
  procedure LoaderData; external name 'loader_data';
  procedure LoaderBSS; external name 'loader_bss';
  procedure LoaderEnd; external name 'loader_end';

  { Procedimentos internos (forward) }
  procedure Idle; forward;


var
  vStackBase, vStackLimit : Pointer;


procedure Init(StackBase : DWord); alias : 'bootinit';

var
  vAddr6845 : Word absolute cBDAAddr6845;
  vCRTSeg : Word;
  vCRTRows : Byte;
  vCRTCols : Byte;
  vHeapBase, vHeapLimit : Pointer;
//  vMemStatus : TMemStatus;

begin
  // Inicializa driver de video/terminal
  case vAddr6845 of
    $03B4 :
      begin
        vCRTSeg := cMDASeg;
        vCRTRows := 25;
        vCRTCols := 40;
      end;

    $03D4 :
      begin
        vCRTSeg := cCGASeg;
        vCRTRows := 25;
        vCRTCols := 80;
      end;
  else
    asm hlt end;
  end;

  GrossTTYInit(vAddr6845, vCRTSeg, vCRTRows, vCRTCols, True);

  // Abre StdIn : fd = 0
  if (FOpen('/dev/null', [fmRead, fmWrite]) <> StdIn) or not CAssign(StdIn) then
    Abort;

  // Abre StdOut : fd = 1
  if (FOpen('/dev/grosstty', [fmRead, fmWrite]) <> StdOut) or not CAssign(StdOut) then
    Abort;

  // Abre StdErr : fd = 2
  if (FOpen('/dev/grosstty', [fmRead, fmWrite]) <> StdErr) or not CAssign(StdErr) then
    Abort;

  CSetColor(Yellow);
  CSetBackground(Red);
  CClrLine;

  CWrite('Bootloader UP: ' + cLoaderName + '.' + cTargetCPU + '(v' + cLoaderVersion + ')');
  CWrite(' [Build: ' + cLoaderDate + '-' + cLoaderTime + ' FPC:' + cFPCVersion + ']');

  CSetNormVideo;
  CLineFeed(2);

  CWriteln;
  CSetColor(Yellow);
  CWriteln('Parametros internos do Bootloader:');
  CSetNormVideo;

  CWrite('Loader_Start: ');
  CSetColor(LightGreen);
  CWriteln(@LoaderStart);
  CSetNormVideo;

  CWrite('Loader_End:   ');
  CSetColor(LightGreen);
  CWriteln(@LoaderEnd);
  CSetNormVideo;

  CWriteln;

  CWrite('Loader_Code:  ');
  CSetColor(LightGreen);
  CWriteln(@LoaderCode);
  CSetNormVideo;

  CWrite('Loader_Data:  ');
  CSetColor(LightGreen);
  CWriteln(@LoaderData);
  CSetNormVideo;

  CWrite('Loader_BSS:   ');
  CSetColor(LightGreen);
  CWriteln(@LoaderBSS);


  CSetNormVideo;

{

  vStackBase := Pointer(StackBase);
  TPtrUInt(vStackLimit) := TPtrUInt(StackBase) - cStackSize;
  vHeapBase := @LoaderEnd;
  TPtrUInt(vHeapLimit) := TPtrUInt(vStackLimit) - 1;

  CWriteln;
  CWrite('Pilha: ');

  CSetColor(LightGreen);
  CWrite(vStackBase);

  CSetNormVideo;
  CWrite(' - ');

  CSetColor(LightGreen);
  CWrite(vStackLimit);

  CSetNormVideo;
  CWrite(' = ');

  CSetColor(Yellow);
  CWriteln(UInt(TPtrUInt(vStackBase) - TPtrUInt(vStackLimit)));

  CSetNormVideo;
  CWrite('Heap:  ');

  CSetColor(LightGreen);
  CWrite(vHeapBase);

  CSetNormVideo;
  CWrite(' - ');

  CSetColor(LightGreen);
  CWrite(vHeapLimit);

  CSetNormVideo;
  CWrite(' = ');

  CSetColor(Yellow);
  CWriteln(UInt(TPtrUInt(vHeapLimit) - TPtrUInt(vHeapBase) + 1));
  CSetNormVideo;

  HeapMMInit(vHeapBase, vHeapLimit);


  vMemStatus := GetMemStatus;

  CWriteln;

  CSetColor(Yellow);
  CWrite('Heap Inicializado');

  CSetNormVideo;
  CWrite(' (Free = ');

  CSetColor(LightGreen);
  CWrite(vMemStatus.HeapFree);

  CSetNormVideo;
  CWriteln(' bytes)');


}

  Idle;
end;


  { Procedimentos internos }

procedure Idle;
var
  X, Y : Byte;
  vContador : LongWord;

begin
  CWriteln;
  CSetColor(LightRed);
  CWriteln('Entrando em IDLE...');
  CSetNormVideo;
  CWrite('Contador: ');

  X := CWhereX;
  Y := CWhereY;

  CSetColor(Yellow);
  vContador := 0;

  while True do
  begin
    CGotoXY(X, Y);
    CWrite(vContador);
    Inc(vContador);
  end;
end;


end.
