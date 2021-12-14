Program MMOD2TXM;

uses dos,strutils;

const
 PremiereRecherche : boolean = true;
 PrintSizeLI = false;

var
 NbTab : integer;
 FRec : SearchRec;
 Fmmod : file;
 Ftxt : text;

Procedure Tab;
var
i : integer;
begin
 for i:=1 to NbTab do write(Ftxt,Chr(9));
end;

Function Keyword(S1 : string) : boolean;
var
 p : longint;
 S2 : string;
begin
 Keyword:=false;
 p:=filepos(Fmmod);
 {$i-}
 BlockRead(Fmmod,S2[1],length(S1));
 {$i+}
 if IOResult<>0 then begin
  seek(FMmod,p);
  exit;
 end;
 S2[0]:=S1[0];
 Keyword:=S1=S2;
 Seek(Fmmod,p);
end;

Function StrLI(LI:longint) : string;
var
 S : string;
begin
 str(LI:8,S);
 StrLI:=S;
end;

Function StrR(R:single) : string;
var
 S : string;
begin
 str(R:13:6,S);
 StrR:=S;
end;

Function StrB(B:Byte) : string;
var
 S : string;
begin
 str(B:4,S);
 StrB:=S;
end;

Procedure WriteCR;
begin
 WriteLN(FTxt);
end;

Procedure WriteTxt(S:string);
begin
 Write(Ftxt,S);
end;

Procedure WriteLNTxt(S:string);
begin
 Writeln(Ftxt,S);Flush(Ftxt);
end;

Function ReadLI : longint;
var
 LI : longint;
begin
 ReadLI:=0;
 {$I-}
 Blockread(Fmmod,LI,4);
 {$I+}
 if IOResult=0 then ReadLI:=LI;
end;

Procedure WriteLI(LI:longint);
var
 S : string;
begin
 WriteTxt(StrLI(LI));
end;

Procedure WriteLNLI(LI:longint);
begin
 WriteLI(LI);
 WriteCR;
end;

Function ReadW : word;
var
 W : word;
begin
 ReadW:=0;
 {$I-}
 BlockRead(FMmod,W,2);
 {$I+}
 if IOResult=0 then ReadW:=W;
end;

Procedure WriteW(W:word);
var
 s : string;
begin
 str(W,S);
 WriteTxt(S);
end;

Procedure WriteLNW(W:word);
var
 s : string;
begin
 WriteW(W);
 WriteCR;
end;

Function ReadR : single;
var
 R : single;
begin
 ReadR:=0;
 {$I-}
 BlockRead(Fmmod,R,4);
 {$I+}
 if IOResult=0 then ReadR:=R;
end;

Function ReadI : Integer;
var
 I : integer;
begin
 ReadI:=0;
 {$I-}
 BlockRead(FMmod,i,2);
 {$I+}
 if IOResult=0 then ReadI:=I;
end;

Procedure WriteI(I : integer);
var
 s : string;
begin
 str(I,S);
 WriteTxt(S);
end;

Procedure WriteLNI(i:integer);
var
 s : string;
begin
 WriteI(I);
 WriteLN(Ftxt);
end;

Procedure WriteR(R:single);
var
 S : string;
begin
 WriteTxt(StrR(R));
end;

Procedure WriteLNR(R:Single);
begin
 WriteR(R);
 WriteCR;
end;

Function ReadB : byte;
var
 B : byte;
begin
 ReadB:=0;
 {$I-}
 Blockread(Fmmod,B,1);
 {$I+}
 if IOResult=0 then Readb:=B;
end;

Procedure WriteB(B:byte);
var
 S : string;
begin
 str(B:3,S);
 Write(Ftxt,S);
end;

Procedure WriteLNB(B:byte);
begin
 WriteB(B);
 WriteCR;
end;

Function StrSizeLI(LI : longint) : string;
var
 S : string;
begin
 if PrintSizeLI then begin
  str(LI,S);
  s:=s+' ';
 end
 else
  S:='';
 StrSizeLI:=S;
end;

Procedure WriteSizeLI(LI : longint);
var
 S : string;
begin
 WriteTxt(StrSizeLI(LI));
end;

Procedure WriteLNSizeLI(LI : longint);
begin
 WriteSizeLI(LI);
 WriteCR;
end;

Procedure SeekPlus(S:string);
 { se déplace du nombre de caractères de S dans FMod }
begin
 {$I-}
 seek(Fmmod,filepos(Fmmod)+length(S));
 {$I+}
end;

Procedure BoundingSphere;
begin
 SeekPlus('BoundingSphere');
 WriteLNTxt(' BoundingSphere '+StrSizeLI(ReadLI));
 Tab; WriteLNTxt(StrR(ReadR)+StrR(ReadR)+StrR(ReadR)+StrR(ReadR));
end;

Procedure BoundingBox;
begin
 SeekPlus('BoundingBox');
 WriteLNTxt(' BoundingBox '+StrSizeLI(ReadLI));
 Tab; WriteLNTxt(StrR(ReadR)+StrR(ReadR)+StrR(ReadR));
 Tab; WriteLNTxt(StrR(ReadR)+StrR(ReadR)+StrR(ReadR));
end;

Procedure ShipMvfm(PLI : longint);
var
 LI : longint;
begin
 SeekPlus('ship.mvfm');
 WriteLNTxt(' ship.mvfm');
 for LI:=1 to PLI do begin
  Tab;
  WriteTxt(StrR(ReadR)+'  '+StrR(ReadR)+'  '+StrR(ReadR)+' /'+'  ');
  WriteTxt(StrR(ReadR)+'  '+StrR(ReadR)+'  '+StrR(ReadR)+' /'+'  ');
  WriteTxt(StrR(ReadR)+'  '+StrR(ReadR)+' /'+'  ');
  WriteTxt(StrR(ReadR)+'  '+StrR(ReadR)+' /'+'  ');
  WriteTxt(StrR(ReadR)+'  '+StrR(ReadR)+'  '+StrR(ReadR)+' /'+'  ');
  WriteLNTxt(StrR(ReadR)+'  '+StrR(ReadR)+'  '+StrR(ReadR)+'  ');
 end;
end;

Procedure ShipVcMvfm(PLI : longint);
var
 LI : longint;
begin
 SeekPlus('shipvc.mvfm');
 WriteLNTxt(' shipvc.mvfm');
 for LI:=1 to PLI do begin
  Tab;
  WriteTxt(StrR(ReadR)+'  '+StrR(ReadR)+'  '+StrR(ReadR)+' /'+'  ');
  WriteTxt(StrR(ReadR)+'  '+StrR(ReadR)+'  '+StrR(ReadR)+' /'+'  ');
  WriteTxt(StrR(ReadR)+'  '+StrR(ReadR)+'  '+' /'+'  ');
  WriteTxt(StrR(ReadR)+'  '+StrR(ReadR)+'  '+' /'+'  ');
  WriteTxt(StrR(ReadR)+'  '+StrR(ReadR)+'  '+StrR(ReadR)+' /'+'  ');
  WriteTxt(StrR(ReadR)+'  '+StrR(ReadR)+'  '+StrR(ReadR)+' /'+'  ');
  WriteLNTxt(StrB(ReadB)+'  '+StrB(ReadB)+'  '+StrB(ReadB)+'  '+StrB(ReadB)+'  ');
 end;
end;

Procedure RopeMvfm(PLI : longint);
var
 LI : longint;
begin
 SeekPlus('rope.mvfm');
 WriteLNTxt(' rope.mvfm');
 for LI:=1 to PLI do begin
  Tab;
  WriteTxt(StrR(ReadR)+'  '+StrR(ReadR)+'  '+StrR(ReadR)+' /'+'  ');
  WriteTxt(StrR(ReadR)+'  '+StrR(ReadR)+'  '+StrR(ReadR)+' /'+'  ');
  WriteLNTxt(StrR(ReadR)+'  '+StrR(ReadR)+'  '+' /'+'  '+StrR(ReadR)+'  ');
 end;
end;

Procedure GunVcMvfm(PLI : longint);
var
 LI : longint;
begin
 SeekPlus('gunvc.mvfm');
 WriteLNTxt(' gunvc.mvfm');
 for LI:=1 to PLI do begin
  Tab;
  WriteTxt(StrR(ReadR)+'  '+StrR(ReadR)+'  '+StrR(ReadR)+'  '+' /'+'  ');
  WriteTxt(StrR(ReadR)+'  '+StrR(ReadR)+'  '+StrR(ReadR)+'  '+' /'+'  ');
  WriteLNTxt(StrR(ReadR)+'  '+StrR(ReadR)+'  '+' /'+'  '+StrB(ReadB)+'  '+StrB(ReadB)+'  '+StrB(ReadB)+'  '+StrB(ReadB)+'  ');
 end;
end;

Procedure SimpleMvfm(PLI : longint);
var
 LI : longint;
begin
 SeekPlus('simple.mvfm');
 WritelnTxt(' simple.mvfm');
 for LI:=1 to PLI do begin
  Tab;
  WriteTxt(StrR(ReadR)+'  '+StrR(ReadR)+'  '+StrR(ReadR)+'  '+' /'+'  ');
  WriteTxt(StrR(ReadR)+'  '+StrR(ReadR)+'  '+StrR(ReadR)+'  '+' /'+'  ');
  WriteLNTxt(StrR(ReadR)+'  '+StrR(ReadR)+'  ');
 end;
end;

Procedure SimpleIndexedMvfm(PLI : longint);
var
 LI : longint;
begin
 SeekPlus('simpleindexed.mvfm');
 WriteLNTxt(' simpleindexed.mvfm');
 for LI:=1 to PLI do begin
  Tab;
  WriteTxt(StrR(ReadR)+'  '+StrR(ReadR)+'  '+StrR(ReadR)+'  '+' /'+'  ');
  WriteTxt(StrR(ReadR)+'  '+StrR(ReadR)+'  '+StrR(ReadR)+'  '+' /'+'  ');
  WriteLNTxt(StrR(ReadR)+'  '+StrR(ReadR)+'  '+' /'+'  '+StrR(ReadR)+'  ');
 end;
end;

Procedure BTerrain2Mvfm(PLI : longint);
var
 LI : longint;
begin
 SeekPlus('bterrain2.mvfm');
 WriteLNTxt(' bterrain2.mvfm');
 for LI:=1 to PLI do begin
  Tab;
  WriteTxt(StrR(ReadR)+'  '+StrR(ReadR)+'  '+StrR(ReadR)+'  '+' /'+'  ');
  WriteTxt(StrR(ReadR)+'  '+StrR(ReadR)+'  '+StrR(ReadR)+'  '+' /'+'  ');
  WriteLNTxt(StrR(ReadR)+'  '+StrR(ReadR)+'  '+' /'+'  '+StrR(ReadR)+'  '+StrR(ReadR)+'  ');
 end;
end;

Procedure ShoreMvfm(PLI : longint);
var
 LI : longint;
begin
 SeekPlus('shore.mvfm');
 WritelnTxt(' shore.mvfm');
 for LI:=1 to PLI do begin
  Tab;
  WriteTxt(StrR(ReadR)+'  '+StrR(ReadR)+'  '+StrR(ReadR)+'  '+' /'+'  ');
  WriteTxt(StrR(ReadR)+'  '+StrR(ReadR)+'  '+' /'+'  ');
  WriteLNTxt(StrB(ReadB)+'  '+StrB(ReadB)+'  '+StrB(ReadB)+'  '+StrB(ReadB)+'  ');
 end;
end;

Procedure PositionMvfm(PLI : longint);
var
 LI : longint;
begin
 SeekPlus('position.mvfm');
 WriteLNTxt(' position.mvfm');
 for LI:=1 to PLI do begin
  Tab;
  WriteLNTxt(StrR(ReadR)+'  '+StrR(ReadR)+'  '+StrR(ReadR)+'  ');
 end;
end;

Procedure AirPlaneMvfm(PLI : longint);
var
 LI : longint;
begin
 SeekPlus('airplane.mvfm');
 WriteLNTxt(' airplane.mvfm');
 for LI:=1 to PLI do begin
  Tab;
  WriteTxt(StrR(ReadR)+'  '+StrR(ReadR)+'  '+StrR(ReadR)+'  '+' /'+'  ');
  WriteTxt(StrR(ReadR)+'  '+StrR(ReadR)+'  '+StrR(ReadR)+'  '+' /'+'  ');
  WriteTxt(StrR(ReadR)+'  '+StrR(ReadR)+'  '+' /'+'  ');
  WriteTxt(StrR(ReadR)+'  '+StrR(ReadR)+'  '+' /'+'  ');
  WriteTxt(StrR(ReadR)+'  '+StrR(ReadR)+'  '+StrR(ReadR)+'  '+' /'+'  ');
  WriteLNTxt(StrR(ReadR)+'  ');
 end;
end;

Procedure AirFieldMvfm(PLI : longint);
var
 LI : longint;
begin
 SeekPlus('airfield.mvfm');
 WriteLNTxt(' airfield.mvfm');
 for LI:=1 to PLI do begin
  Tab;
  WriteTxt(StrR(ReadR)+'  '+StrR(ReadR)+'  '+StrR(ReadR)+'  '+' /'+'  ');
  WriteTxt(StrR(ReadR)+'  '+StrR(ReadR)+'  '+StrR(ReadR)+'  '+' /'+'  ');
  WriteTxt(StrR(ReadR)+'  '+StrR(ReadR)+'  '+' /'+'  ');
  WriteLNTxt(StrR(ReadR)+'  '+StrR(ReadR)+'  ');
 end;
end;

Procedure SkinedMvfm(PLI : longint);
var
 LI : longint;
begin
 SeekPlus('skined.mvfm');
 WritelnTxt(' skined.mvfm');
 for LI:=1 to PLI do begin
  Tab;
  WriteTxt(StrR(ReadR)+'  '+StrR(ReadR)+'  '+StrR(ReadR)+'  '+' /'+'  ');
  WriteTxt(StrR(ReadR)+'  '+StrR(ReadR)+'  '+StrR(ReadR)+'  '+' /'+'  ');
  WriteTxt(StrR(ReadR)+'  '+StrR(ReadR)+'  '+' /'+'  ');
  WriteTxt(StrR(ReadR)+'  '+StrR(ReadR)+'  '+StrR(ReadR)+'  '+StrR(ReadR)+'  ');
  WriteLNTxt(StrR(ReadR)+'  '+StrR(ReadR)+'  '+StrR(ReadR)+'  '+StrR(ReadR)+'  ');
 end;
end;

Procedure VertexStream;
var
 PLI : longint;
 SizeLI : longint;
 KeyWordFind : boolean;
 S : string;
 BSP : boolean;
begin
 SeekPlus('VertexStream');
 SizeLI:=(ReadLI);
 WriteTxt(' VertexStream '+StrSizeLI(SizeLI)); PLI:=ReadLI; WriteLNSizeLI(PLI);
 inc(NbTab);
 KeyWordFind:=false;
 Tab;
 WriteSizeLI(ReadLI);
 str(filepos(Fmmod),S);
 if KeyWord('ship.mvfm') then begin WriteLN('-- Found a ship.mvfm (VertexStream section) at '+S+' --'); ShipMvfm(PLI);KeyWordFind:=true; end;
 if KeyWord('shipvc.mvfm') then begin WriteLN('-- Found a shipvc.mvfm (VertexStream section) at '+S+' --'); ShipVcMvfm(PLI);KeyWordFind:=true; end;
 if KeyWord('rope.mvfm') then begin WriteLN('-- Found a rope.mvfm (VertexStream section) at '+S+' --'); RopeMvfm(PLI);KeyWordFind:=true; end;
 if KeyWord('simple.mvfm') then begin WriteLN('-- Found a simple.mvfm (VertexStream section) at '+S+' --'); SimpleMvfm(PLI);KeyWordFind:=true; end;
 if KeyWord('gunvc.mvfm') then begin WriteLN('-- Found a gunvc.mvfm (VertexStream section) at '+S+' --'); GunVcMvfm(PLI);KeyWordFind:=true; end;
 if KeyWord('simpleindexed.mvfm') then begin WriteLN('-- Found a simpleindexed.mvfm (VertexStream section) at '+S+' --'); SimpleIndexedMvfm(PLI);KeyWordFind:=true; end;
 if KeyWord('bterrain2.mvfm') then begin WriteLN('-- Found a bterrain2.mvfm (VertexStream section) at '+S+' --'); BTerrain2Mvfm(PLI);KeyWordFind:=true; end;
 if KeyWord('position.mvfm') then begin WriteLN('-- Found a position.mvfm (VertexStream section) at '+S+' --'); PositionMvfm(PLI);KeyWordFind:=true; end;
 if KeyWord('airplane.mvfm') then begin WriteLN('-- Found an airplane.mvfm (VertexStream section) at '+S+' --'); AirPlaneMvfm(PLI);KeyWordFind:=true; end;
 if KeyWord('shore.mvfm') then begin WriteLN('-- Found a shore.mvfm (VertexStream section) at '+S+' --'); ShoreMvfm(PLI);KeyWordFind:=true; end;
 if KeyWord('airfield.mvfm') then begin WriteLN('-- Found an airfield.mvfm (VertexStream section) at '+S+' --'); AirFieldMvfm(PLI);KeyWordFind:=true; end;
 if KeyWord('skined.mvfm') then begin WriteLN('-- Found a skined.mvfm (VertexStream section) at '+S+' --'); SkinedMvfm(PLI);KeyWordFind:=true; end;

 if KeyWord('pssn4nubn4ussn2cc.mvfm')
 or KeyWord('pssn4nubn4ussn2ccif41.mvfm')
 or KeyWord('pssn4nubn4ussn2if41.mvfm')
 or KeyWord('pssn4nubn4ussn2uf41if41.mvfm')
 or KeyWord('pssn4nubn4ussn2ussn2ccif41.mvfm')
 or KeyWord('pssn4nubn4ussn2ussn2if41.mvfm')
 or KeyWord('pssn4nubn4ussn2ussn2.mvfm')
 or KeyWord('pssn4nubn4ussn2.mvfm')
 or KeyWord('pssn4nf24ussn2ussn2ccif41.mvfm')
 or KeyWord('pf24nubn4ussn2ussn2.mvfm')
 or KeyWord('pssn4nubn4ussn2uf22.mvfm')
 or KeyWord('pf43nubn4ussn2ussn2.mvfm')
 or KeyWord('pssn4')
 or KeyWord('pf43')                              then BSP:=true else BSP:=false;

 if BSP then begin
   { il s'agit d'un format BSP }
  KeyWordFind:=true;
  
  WriteLN; 
  WriteLNTxt('-- ERROR! UNKNOWN BSP FORMAT AT '+S+'  (VertexStream section)! --');

   { se repositioner dans le fichier }

  seek(FMmod,FilePos(FMmod)+SizeLI-8);
 end;
 if not KeyWordFind then begin
  WriteCR;
  WriteLNTxt('ERROR! UNKNOWN WORD FROM VertexStream SECTION AT '+S);
  exit;
 end;
 dec(NbTab);
end;

Procedure Indices;
var
 PLI, I, J, IndicesType : Longint;
 S, IndicesText : string;
 ToPrint, MultIdx : word;
begin
 SeekPlus('Indices');
 WriteTxT(' Indices '+StrSizeLI(ReadLI)); 
 PLI:=ReadLI; 
 WriteSizeLI(PLI); 
 WriteTxt(' '); 
 IndicesType:=ReadLI;
 IndicesText:=StrSizeLI(IndicesType);
 WriteLNLI(IndicesType);
 inc(NbTab);
 {* Extended Indices format *}
 if IndicesType=102 then begin
  WriteLN('- This Indices is in extended format -');
  for i:=1 to PLI div 3 do begin
   Tab;
   {for j:=1 to 3 do begin
	ToPrint:=ReadW;
	MultIdx:=ReadW;
	WriteW(ToPrint);
	WriteW(MultIdx);
	if j<3 then begin
	  WriteTxt(' / ');
    end;
   end;
   ReadW; 
   Writeln(Ftxt);}
   {WriteW(ReadW); ReadW; WriteTxt(' / '); WriteW(ReadW); ReadW; WriteTxt(' / '); WriteW(ReadW); ReadW; Writeln(Ftxt);}
   WriteW(ReadW); WriteTxt(' / '); WriteW(ReadW); WriteTxt(' / '); WriteW(ReadW); WriteTxt(' / '); WriteW(ReadW); WriteTxt(' / '); WriteW(ReadW); WriteTxt(' / '); WriteLNW(ReadW);
  end;
 end;
 {* Extended Indices format *}
 if IndicesType=101 then begin
  WriteLN('- This Indices is in standard format -');
  for i:=1 to PLI div 3 do begin
   Tab;
   WriteW(ReadW); WriteTxt(' / '); WriteW(ReadW); WriteTxt(' / '); WriteLNW(ReadW);
  end;
 end;
 dec(NbTab);
end;

Procedure IndicesStripPS2;
var
 LI : longint;
begin
 SeekPlus('IndicesStripPS2');
 WriteTxT(' IndicesStripPS2 ');
 LI:=readLI;
 if PrintSizeLI then WriteSizeLI(LI);
 WriteCR;
 Tab;
 WriteLNTxt(' **** NON DECODE *** ');
 inc(LI,FilePos(FMmod));
 Seek(FMmod,LI);
end;

Procedure VertexStreamIndex;
begin
 SeekPlus('VertexStreamIndex');
 WriteLNTxt(' VertexStreamIndex '+StrSizeLI(ReadLI)+StrLI(ReadLI));
end;

Procedure Texture;
var
 LI1, LI2 : longint;
 C : char;
begin
 SeekPlus('Texture');
 WriteTxt(' Texture '+StrSizeLI(ReadLI));
 LI1:=ReadLI;
 WriteSizeLI(LI1);
 for LI2:=1 to LI1 do begin
  BlockRead(FMmod,C,1); WriteTxt(C);
 end;
 WriteLNTxt(' '+StrLI(ReadLI));
end;

Procedure LightingSettings;
begin
 SeekPlus('LightingSettings');
 WriteLNTxt(' LightingSettings '+StrSizeLI(ReadLI)+' '+StrLI(ReadLI));
 inc(NbTab);
 Tab; WriteLNTxt(StrR(ReadR)+StrR(ReadR)+StrR(ReadR)+StrR(ReadR)+StrR(ReadR)+StrR(ReadR));
 Tab; WriteLNTxt(StrR(ReadR)+StrR(ReadR)+StrR(ReadR)+StrR(ReadR)+StrR(ReadR)+StrR(ReadR));
 Tab; WriteLNTxt(StrR(ReadR)+StrR(ReadR)+StrR(ReadR)+StrR(ReadR)+StrR(ReadR)+StrR(ReadR));
 dec(NbTab);
end;

Procedure SubSetPS2;
var
 LI : longint;
begin
 SeekPlus('SubSetPS2');
 WriteTxT(' SubSetPS2 ');
 LI:=readLI;
 WriteLNSizeLI(LI);
 Tab;
 WriteLNTxt(' **** NON DECODE *** ');
 inc(LI,FilePos(FMmod));
 Seek(FMmod,LI);
end;

Procedure MSHD(S:string);
begin
 SeekPlus(S);
 WriteLNTxt(' '+S);
end;

Procedure Subset;
var
 LI : Longint;
 PLI1, PLI2 : longint;
 KeyWordFind : boolean;
 S, S1, S2 : string;
 i : integer;
begin
 SeekPlus('Subset');
 PLI1:=FilePos(Fmmod);
 LI:=ReadLI;
 inc(PLI1,LI);
 WriteTxt(' Subset '+StrSizeLI(LI)+' '+StrLI(ReadLI)+' '+StrLI(ReadLI)+' '+StrLI(ReadLI)+' '+StrLI(ReadLI)+' '+StrLI(ReadLI));
 WriteCR;
 inc(NbTab);
 While FilePos(Fmmod)<PLI1 do begin
  WriteCR;
  KeyWordFind:=false;
  Tab;
  LI:=ReadLI;
  WriteSizeLI(LI);
  PLI2:=FilePos(FMmod);
  S[0]:=chr(LI);
  for i:=1 to LI do S[i]:=Chr(ReadB);
  S1:='';
  for i:=1 to 5 do S1:=S1+S[Length(S)-5+i];
  Seek(FMmod,PLI2);
  str(filepos(Fmmod),S2);
  if S1='.mshd' then begin WriteLN('-- Found an MSHD (Subset section) at '+S2+' --'); MSHD(S); KeyWordFind:=true; end;
  if not KeyWordFind then if KeyWord('VertexStreamIndex') then begin WriteLN('-- Found a VertexStreamIndex (Subset section) at '+S2+' --'); VertexStreamIndex; KeyWordFind:=true; end;
  if not KeyWordFind then if KeyWord('Texture') then begin WriteLN('-- Found a Texture (Subset section) at '+S2+' --'); Texture; KeyWordFind:=true; end;
  if not KeyWordFind then if KeyWord('LightingSettings') then begin WriteLN('-- Found a LightingSettings (Subset section) at '+S2+' --'); LightingSettings; KeyWordFind:=true; end;
  if not KeyWordFind then if KeyWord('BoundingSphere') then begin WriteLN('-- Found a BoundingSphere (Subset section) at '+S2+' --'); BoundingSphere; KeyWordFind:=true; end;
  if not KeyWordFind then begin
   Writeln(Ftxt);
   Writeln(Ftxt,'ERROR! UNKNOWN WORD FROM Subset SECTION AT '+S2);
   exit;
  end;
 end;
 dec(NbTab);
end;

Procedure LODPhases;
var
 LI1 : longint;
begin
 SeekPlus('LODPhases');
 WriteTxt(' LODPhases ');
 WriteSizeLI(ReadLI);
 LI1:=ReadLI;
 WriteLNLI(LI1);
 inc(NbTab);
 while LI1>0 do begin
  Tab;
  WriteLNTXT(StrR(ReadR)+' '+StrR(ReadR)+' '+StrLI(ReadLI)+' '+StrLI(ReadLI));
  dec(LI1);
 end;
 dec(NbTab);
end;

Procedure WeightMapNames;
var
 PLI, LI1, LI2 : longint;
begin
 SeekPlus('WeightMapNames');
 WriteTxt(' WeightMapNames ');
 PLI:=ReadLI;
 WriteLNSizeLI(PLI);
 inc(PLI,FilePos(FMmod));
 inc(NbTab);
 while FilePos(FMmod)<PLI do begin
  Tab;
  LI1:=ReadLI;
  WriteTxt(StrSizeLI(LI1));
  for LI2:=1 to LI1 do WriteTxt(char(ReadB));
  WriteCR;
 end;
 Tab; WriteLNTxt('END');
 dec(NbTab);
end;

{* BSP *}
Procedure CompressedVertexFormatData;
var
 LI1 : longint;
begin
 SeekPlus('CompressedVertexFormatData');
 WriteTxt(' CompressedVertexFormatData ');
 LI1:=readLI;
 WriteLNSizeLI(LI1);
 inc(NbTab);
 while LI1>0 do begin
  Tab;
  WriteR(ReadR); WriteR(ReadR); WriteR(ReadR); WriteR(ReadR);
  WriteR(ReadR); WriteR(ReadR); WriteR(ReadR); WriteLNR(ReadR);
  dec(LI1,32);
 end;
 dec(NbTab);
end;
{* BSP *}

Procedure Mesh;
var
 PLI : longint;
 KeyWordFind : boolean;
 S : string;
begin
 SeekPlus('Mesh');
 PLI:=ReadLI;
 writeTxt(' Mesh '+StrSizeLI(PLI));
 inc(PLI,FilePos(FMmod));
 WriteLNLI(ReadLI);
 inc(NbTab);
 while FilePos(FMmod)<PLI do begin
  WriteCR;
  KeyWordFind:=false;
  Tab;
  WriteSizeLI(ReadLI);
  str(filepos(Fmmod),S);
  if not KeyWordFind then if KeyWord('VertexStream') then begin WriteLN('-- Found a VertexStream (Mesh section) at '+S+' --'); VertexStream; KeyWordFind:=true; end;
  if not KeyWordFind then if KeyWord('IndicesStripPS2') then begin WriteLN('-- Found an IndicesStripPS2 (Mesh section) at '+S+' --'); IndicesStripPS2; KeyWordFind:=true; end;
  if not KeyWordFind then if KeyWord('Indices') then begin WriteLN('-- Found an Indices (Mesh section) at '+S+' --'); Indices; KeyWordFind:=true; end;
  if not KeyWordFind then if KeyWord('BoundingSphere') then begin WriteLN('-- Found a BoundingSphere (Mesh section) at '+S+' --'); BoundingSphere; KeyWordFind:=true; end;
  if not KeyWordFind then if KeyWord('BoundingBox') then begin WriteLN('-- Found a BoundingBox (Mesh section) at '+S+' --'); BoundingBox; KeyWordFind:=true; end;
  if not KeyWordFind then if KeyWord('SubSetPS2') then begin WriteLN('-- Found a SubSetPS2 (Mesh section) at '+S+' --'); SubSetPS2; KeyWordFind:=true; end;
  if not KeyWordFind then if KeyWord('Subset') then begin WriteLN('-- Found a Subset (Mesh section) at '+S+' --'); Subset; KeyWordFind:=true; end;
  if not KeyWordFind then if KeyWord('LODPhases') then begin WriteLN('-- Found a LODPhases (Mesh section) at '+S+' --'); LODPhases ; KeyWordFind:=true; end;
  if not KeyWordFind then if KeyWord('WeightMapNames') then begin WriteLN('-- Found a WeightMapNames (Mesh section) at '+S+' --'); WeightMapNames ; KeyWordFind:=true; end;
  {* BSP *}
  if not KeyWordFind then if KeyWord('CompressedVertexFormatData') then begin WriteLN('-- Found a CompressedVertexFormatData (Mesh section) at '+S+' --'); CompressedVertexFormatData ; KeyWordFind:=true; end;
  {* BSP *}
  if not KeyWordFind then begin
   Writeln(Ftxt);
   Writeln(Ftxt,'ERROR! UNKNOWN WORD FROM Mesh SECTION AT '+S);
   exit;
  end;
 end;
 dec(NbTab);
end;

Procedure Points;
var
 LI1, LI2 : longint;
begin
 SeekPlus('Points');
 WriteTxt(' Points '); LI1:=ReadLI; WriteLNSizeLI(LI1);
 inc(NbTab);
 for LI2:=1 to LI1 div 12 do begin
  Tab;
  writeR(ReadR); WriteR(ReadR);WriteLNR(ReadR);
 end;
 dec(NbTab);
end;

Procedure Category;
var
 LI1, LI2 : longint;
begin
 SeekPlus('Category');
 WriteLNTxt(' Category '+StrSizeLI(ReadLI));
 inc(NbTab);
 Tab;
 LI1:=readLI;
 WriteTxt(' '+StrSizeLI(LI1));
 for LI2:=1 to LI1 do WriteTxt(chr(ReadB));
 WriteCR;
 dec(NbTab);
end;

Procedure Identifier;
var
 LI1, LI2 : longint;
begin
 SeekPlus('Identifier');
 WriteTxt(' Identifier '); WriteLNSizeLI(ReadLI);
 inc(NbTab);
 Tab;
 LI1:=readLI;
 WriteTxt(' '+StrSizeLI(LI1));
 for LI2:=1 to LI1 do WriteTxt(chr(ReadB));
 inc(NbTab);
 WriteCR;
 Tab; WriteLNTxt(StrLI(ReadLI));
 dec(NbTab);
 dec(NbTab);
end;

Procedure SceneError;
var
 PLI : longint;
begin
 Seekplus('SceneError');
 WriteTxt(' SceneError ');
 PLI:=ReadLI;
 WriteLNSizeLI(PLI);
 WriteLNTxt(' ========== LOOK IN SOURCE FILE == SEARCH "SceneError" ===============================');
 inc(PLI,FilePos(FMmod));
 seek(FMmod,PLI);
end;

Procedure Aux;
const
 KeyWordFind : boolean = false;
var
 S : String;
 PLI : longint;
begin
 SeekPlus('Aux');
 Write(Ftxt,' Aux ');
 PLI:=ReadLI;
 WriteLNSizeLI(PLI);
 inc(PLI,FilePos(FMmod));
 inc(NbTab);
 while FilePos(FMmod)<PLI do begin
  WriteCR;
  KeyWordFind:=false;
  Tab;
  WriteSizeLI(ReadLI);
  str(filepos(Fmmod),S);
  if KeyWord('Identifier') then begin WriteLN('-- Found an Identifier (Aux section) at '+S+' --'); Identifier; KeyWordFind:=true; end;
  if KeyWord('Category') then begin WriteLN('-- Found a Category (Aux section) at '+S+' --'); Category; KeyWordFind:=true; end;
  if KeyWord('Points') then begin WriteLN('-- Found a Points (Aux section) at '+S+' --'); Points; KeyWordFind:=true; end;
  if not KeyWordFind then begin
   Writeln(Ftxt);Flush(Ftxt);
   Writeln(Ftxt,'ERROR! UNKNOWN WORD FROM Aux SECTION AT '+S);Flush(Ftxt);
   exit;
  end;
 end;
 dec(NbTab);
end;

Procedure GeomMesh;
const
 KeyWordFind : boolean = false;
var
 S : String;
 LI1, LI2, LI3, LI4 : longint;
begin
 SeekPlus('GeomMesh');
 WriteTxt(' GeomMesh '+StrSizeLI(ReadLI));
 LI1:=ReadLI;
 WriteLNSizeLI(LI1);
 inc(NbTab);
 for LI2:=1 to LI1 do begin
  Tab;
  LI3:=ReadLI;
  WriteSizeLI(LI3);
  for LI4:=1 to LI3 do WriteTxt(chr(ReadB));
  WriteCR;
  inc(NbTab);
  Tab; WriteLNTxt(' '+StrLI(ReadLI));
  dec(NbTab);
 end;
 Tab; WriteLNTxt('END');
 Tab;
 LI1:=ReadLI;
 WriteLNSizeLI(LI1);
 inc(NbTab);
 for LI2:=1 to LI1 do begin
  Tab;
  WriteR(ReadR); WriteR(ReadR); WriteLNR(ReadR);
 end;
 Tab; WriteLNTxt('END');
 dec(NbTab);
 LI1:=ReadLI;
 Tab;
 WriteLNSizeLI(LI1);
 inc(NbTab);
 for LI2:=1 to LI1 do begin
  Tab; WriteLNTxt(StrLI(ReadLI)+' '+StrLI(ReadLI));
 end;
 Tab; WriteLNTxt('END');
 dec(NbTab);
 Tab;
 LI1:=ReadLI;
 WriteLNSizeLI(LI1);
 inc(NbTab);
 for LI2:=1 to LI1 do begin
  Tab; WriteLNTxt(StrLI(ReadLI)+StrLI(ReadLI)+StrLI(ReadLI)+StrLI(ReadLI)
  +StrLI(ReadLI)+StrLI(ReadLI)+StrLI(ReadLI)+StrLI(ReadLI));
 end;
 dec(NbTab);
 dec(NbTab);
end;

Procedure ConvexObject;
var
 i : integer;
 PLI,
 LI1, LI2, LI3, LI4 : longint;
begin
 SeekPlus('ConvexObject');
 WriteTxt(' ConvexObject ');
 PLI:=ReadLI;
 WriteSizeLI(PLI);
 inc(PLI,FilePos(FMMod));
 LI1:=ReadLI;
 if (LI1=0) or (LI1=1) or (LI1=2) then begin
  WriteTxt(' '+StrLI(LI1));
  LI1:=ReadLI;
 end;
 WriteCR;
 inc(NbTab);
 Tab; WriteLNSizeLI(LI1);
 inc(NbTab);
 for LI2:=1 to LI1 do begin  { read 1st section }
  Tab; WriteLNTxt(StrR(ReadR)+StrR(ReadR)+StrR(ReadR));
  for i:=1 to 3 do begin
   LI3:=readLI;
   Tab; WriteSizeLI(LI3);
   for LI4:=1 to LI3 do WriteTxt(StrLI(ReadLI));
   writeCR;
  end;
  writeCR;
 end;
 Tab; WriteLNTxt('END');
 dec(NbTab);


 LI1:=ReadLI;   { 2nd section }
 Tab; WriteLNSizeLI(LI1);
 inc(NbTab);
 for LI2:=1 to LI1 do begin

  Tab; WriteLNTxt(StrR(ReadR)+StrR(ReadR)+StrR(ReadR));
  for i:=1 to 2 do begin
   LI3:=readLI;
   Tab; WriteSizeLI(LI3);
   for LI4:=1 to LI3 do WriteTxt(StrLI(ReadLI));
   writeCR;
  end;
  writeCR;

 end;
 Tab; WriteLNTxt('END');
 dec(NbTab);
 LI1:=ReadLI;
 Tab; WriteLNSizeLI(LI1);
 inc(NbTab);
 for LI2:=1 to LI1 do begin
  Tab;
  WriteLNTxt(StrR(ReadR)+StrR(ReadR)+StrR(ReadR)+StrR(ReadR)+StrR(ReadR));
 end;
 Tab; WriteLNTxt('END');
 dec(NbTab);
 LI1:=ReadLI;
 Tab;
 WriteLNSizeLI(LI1);
 inc(NbTab);
 for LI2:=1 to LI1 do begin
  Tab;
  WriteLNTxt(StrR(ReadR)+StrR(ReadR)+StrR(ReadR));
 end;
 dec(NbTab);
 dec(NbTab);
end;

Procedure Note;
var
 LI1, LI2 : longint;
begin
 SeekPlus('Note');
 WriteTxt(' Note '); WriteSizeLI(ReadLI);
 LI1:=ReadLI;
 WriteSizeLI(LI1);
 for LI2:=1 to LI1 do WriteTxt(chr(ReadB));
 WriteCR;
end;

Procedure GroupParams;
begin
 SeekPlus('GroupParams');
 WriteLNTxt(' GroupParams '+StrSizeLI(ReadLI)+StrR(ReadR));
end;

Procedure Index;
begin
 SeekPlus('Index');
 WriteTxt(' Index '); WriteLNTxt(StrSizeLI(ReadLI)+' '+StrLI(ReadLI));
end;

Procedure Armor;
begin
 SeekPlus('Armor');
 WriteTxt(' Armor '); WriteLNTxt(StrSizeLI(ReadLI)+' '+StrLI(ReadLI));
end;

Procedure Mesh2;
var
 LI1, LI2 : longint;
begin
 SeekPlus('Mesh');
 WriteTxt(' Mesh '); WriteLNSizeLI(ReadLI);
 Tab;
 LI1:=ReadLI;
 WriteLNLI(LI1);
 inc(NbTab);
 for LI2:=1 to LI1 do begin
  Tab;
  WriteR(ReadR); WriteR(ReadR); WriteLNR(ReadR);
 end;
 dec(NbTab);
 LI1:=ReadLI;
 Tab;
 WriteLNLI(LI1);
 inc(NbTab);
 for LI2:=1 to LI1 do begin
  Tab; WriteLNTxt(StrLI(ReadLI)+' '+StrLI(ReadLI));
 end;
 dec(NbTab);
 Tab;
 LI1:=ReadLI;
 WriteLNLI(LI1);
 inc(NbTab);
 for LI2:=1 to LI1 do begin
  Tab; WriteLNTxt(StrLI(ReadLI)+' / '+StrLI(ReadLI)+' / '+StrLI(ReadLI)+' / '
  +StrLI(ReadLI)+' / '+StrLI(ReadLI)+' / '+StrLI(ReadLI));
 end;
 dec(NbTab);
end;

Procedure Geom;
var
 PLI : longint;
 KeyWordFind : boolean;
 S : string;
begin
 SeekPlus('Geom');
 Write(Ftxt,' Geom ');
 PLI:=ReadLI;
 WriteLNSizeLI(PLI);
 inc(PLI,FilePos(FMmod));
 inc(NbTab);
 while FilePos(FMmod)<PLI do begin
  WriteCR;
  KeyWordFind:=false;
  Tab;
  WriteSizeLI(ReadLI);
  str(filepos(Fmmod),S);
  if not KeyWordFind then if KeyWord('Category') then begin WriteLN('-- Found a Category (Geom section) at '+S+' --'); Category; KeyWordFind:=true; end;
  if not KeyWordFind then if KeyWord('Index') then begin WriteLN('-- Found a Index (Geom section) at '+S+' --'); Index; KeyWordFind:=true; end;
  if not KeyWordFind then if KeyWord('Armor') then begin WriteLN('-- Found a Armor (Geom section) at '+S+' --'); Armor; KeyWordFind:=true; end;
  if not KeyWordFind then if KeyWord('Mesh') then begin WriteLN('-- Found a Mesh (Geom section) at '+S+' --'); Mesh2; KeyWordFind:=true; end;
  if not KeyWordFind then begin
   Writeln(Ftxt);Flush(Ftxt);
   Writeln(Ftxt,'ERROR! UNKNOWN WORD FROM Geom SECTION AT '+S);Flush(Ftxt);
   exit;
  end;
 end;
 dec(NbTab);
end;

Procedure MatrixIndexedMesh;
var
 PLI : longint;
 KeyWordFind : boolean;
 S : string;
begin
 SeekPlus('MatrixIndexedMesh');
 Write(Ftxt,' MatrixIndexedMesh ');
 PLI:=ReadLI;
 WriteSizeLI(PLI);
 inc(PLI,FilePos(FMmod));
 WriteLNTxt(StrLI(ReadLI));
 inc(NbTab);
 while FilePos(FMmod)<PLI do begin
  WriteCR;
  KeyWordFind:=false;
  Tab;
  WriteSizeLI(ReadLI);
  str(filepos(Fmmod),S);
  if not KeyWordFind then if KeyWord('VertexStream') then begin WriteLN('-- Found a VertexStream (MatrixIndexedMesh section) at '+S+' --'); VertexStream; KeyWordFind:=true; end;
  if not KeyWordFind then if KeyWord('Indices') then begin WriteLN('-- Found an Indices (MatrixIndexedMesh section) at '+S+' --'); Indices; KeyWordFind:=true; end;
  if not KeyWordFind then if KeyWord('BoundingSphere') then begin WriteLN('-- Found a BoundingSphere (MatrixIndexedMesh section) at '+S+' --'); BoundingSphere; KeyWordFind:=true; end;
  if not KeyWordFind then if KeyWord('BoundingBox') then begin WriteLN('-- Found a BoundingBox (MatrixIndexedMesh section) at '+S+' --'); BoundingBox; KeyWordFind:=true; end;
  if not KeyWordFind then if KeyWord('SubSetPS2') then begin WriteLN('-- Found a SubSetPS2 (MatrixIndexedMesh section) at '+S+' --'); SubSetPS2; KeyWordFind:=true; end;
  if not KeyWordFind then if KeyWord('Subset') then begin WriteLN('-- Found a Subset (MatrixIndexedMesh section) at '+S+' --'); Subset; KeyWordFind:=true; end;
  if not KeyWordFind then if KeyWord('LODPhases') then begin WriteLN('-- Found a LODPhases (MatrixIndexedMesh section) at '+S+' --'); LODPhases ; KeyWordFind:=true; end;
  if not KeyWordFind then if KeyWord('WeightMapNames') then begin WriteLN('-- Found a WeightMapNames (MatrixIndexedMesh section) at '+S+' --'); WeightMapNames ; KeyWordFind:=true; end;
  {* BSP *}
  if not KeyWordFind then if KeyWord('CompressedVertexFormatData') then begin WriteLN('-- Found a CompressedVertexFormatData (MatrixIndexedMesh section) at '+S+' --'); CompressedVertexFormatData ; KeyWordFind:=true; end;
  {* BSP *}
  if not KeyWordFind then begin
   Writeln(Ftxt);Flush(Ftxt);
   Writeln(Ftxt,'ERROR! UNKNOWN WORD FROM MatrixIndexedMesh SECTION AT '+S);Flush(Ftxt);
   exit;
  end;
 end;
 dec(NbTab);
end;

Procedure CloudSystem;
var
 LI1, LI2 : longint;
begin
 SeekPlus('CloudSystem');
 WriteTxt(' CloudSystem ');
 WriteSizeLI(ReadLI);
 LI1:=ReadLI;
 WriteLNSizeLI(LI1);
 inc(NbTab);
 for LI2:=1 to LI1 do begin
  Tab;
  WriteLNTxt(StrR(ReadR)+StrR(ReadR)+StrR(ReadR)+StrR(ReadR));
 end;
 dec(NbTab);
end;

Procedure AnimationGroupName;
var
 LI1, LI2 : longint;
begin
 SeekPlus('AnimationGroupName');
 WriteLNTxt(' AnimationGroupName '+StrSizeLI(ReadLI));
 inc(NbTab);
 Tab;
 LI1:=readLI;
 WriteTxt(' '+StrSizeLI(LI1));
 for LI2:=1 to LI1 do WriteTxt(chr(ReadB));
 WriteCR;
 dec(NbTab);
end;

Procedure PositionX;
begin
 SeekPlus('Position.X');
 WriteLNTxt(' Position.X '+StrLI(ReadLI)+StrLI(ReadLI));
end;

Procedure PositionY;
begin
 SeekPlus('Position.Y');
 WriteLNTxt(' Position.Y '+StrLI(ReadLI)+StrLI(ReadLI));
end;

Procedure PositionZ;
begin
 SeekPlus('Position.Z');
 WriteLNTxt(' Position.Z '+StrLI(ReadLI)+StrLI(ReadLI));
end;

Procedure RotationH;
begin
 SeekPlus('Rotation.H');
 WriteLNTxt(' Rotation.H '+StrLI(ReadLI)+StrLI(ReadLI));
end;

Procedure RotationP;
begin
 SeekPlus('Rotation.P');
 WriteLNTxt(' Rotation.P '+StrLI(ReadLI)+StrLI(ReadLI));
end;

Procedure RotationB;
begin
 SeekPlus('Rotation.B');
 WriteLNTxt(' Rotation.B '+StrLI(ReadLI)+StrLI(ReadLI));
end;

Procedure ScaleX;
begin
 SeekPlus('Scale.X');
 WriteLNTxt(' Scale.X '+StrLI(ReadLI)+StrLI(ReadLI));
end;

Procedure ScaleY;
begin
 SeekPlus('Scale.Y');
 WriteLNTxt(' Scale.Y '+StrLI(ReadLI)+StrLI(ReadLI));
end;

Procedure ScaleZ;
begin
 SeekPlus('Scale.Z');
 WriteLNTxt(' Scale.Z '+StrLI(ReadLI)+StrLI(ReadLI));
end;

Procedure AnimationKey;
begin
 SeekPlus('AnimationKey');
 WriteLNTxt(' AnimationKey '+StrSizeLI(ReadLI)+StrLI(ReadLI));
 inc(NbTab);
 Tab;
 WriteLNTxt(StrR(ReadR)+StrR(ReadR)+StrR(ReadR)+StrR(ReadR)+StrR(ReadR)+StrR(ReadR)+StrR(ReadR)+StrR(ReadR)+StrR(ReadR));
 dec(NbTab);
end;

Procedure ChannelAnimation;
var
 PLI : longint;
 KeyWordFind : boolean;
 S : string;
begin
 SeekPlus('ChannelAnimation');
 Write(Ftxt,' ChannelAnimation ');
 PLI:=ReadLI;
 WriteLNSizeLI(PLI);
 inc(PLI,FilePos(FMmod));
 inc(NbTab);
 while FilePos(FMmod)<PLI do begin
  WriteLN(Ftxt);Flush(Ftxt);
  KeyWordFind:=false;
  Tab;
  WriteSizeLI(ReadLI);
  str(filepos(Fmmod),S);
  if not KeyWordFind then if KeyWord('Position.X') then begin WriteLN('-- Found a Position.X (ChannelAnimation section) at '+S+' --'); PositionX; KeyWordFind:=true; end;
  if not KeyWordFind then if KeyWord('Position.Y') then begin WriteLN('-- Found a Position.Y (ChannelAnimation section) at '+S+' --'); PositionY; KeyWordFind:=true; end;
  if not KeyWordFind then if KeyWord('Position.Z') then begin WriteLN('-- Found a Position.Z (ChannelAnimation section) at '+S+' --'); PositionZ; KeyWordFind:=true; end;
  if not KeyWordFind then if KeyWord('Rotation.H') then begin WriteLN('-- Found a Rotation.H (ChannelAnimation section) at '+S+' --'); RotationH; KeyWordFind:=true; end;
  if not KeyWordFind then if KeyWord('Rotation.P') then begin WriteLN('-- Found a Rotation.P (ChannelAnimation section) at '+S+' --'); RotationP; KeyWordFind:=true; end;
  if not KeyWordFind then if KeyWord('Rotation.B') then begin WriteLN('-- Found a Rotation.B (ChannelAnimation section) at '+S+' --'); RotationB; KeyWordFind:=true; end;
  if not KeyWordFind then if KeyWord('Scale.X') then begin WriteLN('-- Found a Scale.X (ChannelAnimation section) at '+S+' --'); ScaleX; KeyWordFind:=true; end;
  if not KeyWordFind then if KeyWord('Scale.Y') then begin WriteLN('-- Found a Scale.Y (ChannelAnimation section) at '+S+' --'); ScaleY; KeyWordFind:=true; end;
  if not KeyWordFind then if KeyWord('Scale.Z') then begin WriteLN('-- Found a Scale.Z (ChannelAnimation section) at '+S+' --'); ScaleZ; KeyWordFind:=true; end;
  if not KeyWordFind then if KeyWord('AnimationKey') then begin WriteLN('-- Found an AnimationKey (ChannelAnimation section) at '+S+' --'); AnimationKey; KeyWordFind:=true; end;
  if not KeyWordFind then begin
   Writeln(Ftxt);Flush(Ftxt);
   Writeln(Ftxt,'ERROR! UNKNOWN WORD FROM ChannelAnimation SECTION AT '+S);Flush(Ftxt);
   exit;
  end;
 end;
 dec(NbTab);
end;

Procedure AnimationChannels;
var
 PLI : longint;
 KeyWordFind : boolean;
 S : string;
begin
 SeekPlus('AnimationChannels');
 Write(Ftxt,' AnimationChannels ');
 PLI:=ReadLI;
 WriteLNSizeLI(PLI);
 inc(PLI,FilePos(FMmod));
 inc(NbTab);
 while FilePos(FMmod)<PLI do begin
  WriteLN(Ftxt);Flush(Ftxt);
  KeyWordFind:=false;
  Tab;
  WriteSizeLI(ReadLI);
  str(filepos(Fmmod),S);
  if not KeyWordFind then if KeyWord('AnimationGroupName') then begin WriteLN('-- Found an AnimationGroupName (AnimationChannels section) at '+S+' --'); AnimationGroupName; KeyWordFind:=true; end;
  if not KeyWordFind then if KeyWord('ChannelAnimation') then begin WriteLN('-- Found a ChannelAnimation (AnimationChannels section) at '+S+' --'); ChannelAnimation; KeyWordFind:=true; end;
  if not KeyWordFind then begin
   Writeln(Ftxt);Flush(Ftxt);
   Writeln(Ftxt,'ERROR! UNKNOWN WORD FROM AnimationChannels SECTION AT '+S);Flush(Ftxt);
   exit;
  end;
 end;
 dec(NbTab);
end;

Procedure SkinedMesh;
var
 PLI : longint;
 KeyWordFind : boolean;
 S : string;
begin
 SeekPlus('SkinedMesh');
 PLI:=ReadLI;
 writeTxt(' SkinedMesh '+StrSizeLI(PLI));
 inc(PLI,FilePos(FMmod));
 WriteLNLI(ReadLI);
 inc(NbTab);
 while FilePos(FMmod)<PLI do begin
  WriteCR;
  KeyWordFind:=false;
  Tab;
  WriteSizeLI(ReadLI);
  str(filepos(Fmmod),S);
  if not KeyWordFind then if KeyWord('VertexStream') then begin WriteLN('-- Found a VertexStream (SkinedMesh section) at '+S+' --'); VertexStream; KeyWordFind:=true; end;
  if not KeyWordFind then if KeyWord('IndicesStripPS2') then begin WriteLN('-- Found an IndicesStripPS2 (SkinedMesh section) at '+S+' --'); IndicesStripPS2; KeyWordFind:=true; end;
  if not KeyWordFind then if KeyWord('Indices') then begin WriteLN('-- Found an Indices (SkinedMesh section) at '+S+' --'); Indices; KeyWordFind:=true; end;
  if not KeyWordFind then if KeyWord('BoundingSphere') then begin WriteLN('-- Found a BoundingSphere (SkinedMesh section) at '+S+' --'); BoundingSphere; KeyWordFind:=true; end;
  if not KeyWordFind then if KeyWord('BoundingBox') then begin WriteLN('-- Found a BoundingBox (SkinedMesh section) at '+S+' --'); BoundingBox; KeyWordFind:=true; end;
  if not KeyWordFind then if KeyWord('SubSetPS2') then begin WriteLN('-- Found a SubSetPS2 (SkinedMesh section) at '+S+' --'); SubSetPS2; KeyWordFind:=true; end;
  if not KeyWordFind then if KeyWord('Subset') then begin WriteLN('-- Found a Subset (SkinedMesh section) at '+S+' --'); Subset; KeyWordFind:=true; end;
  if not KeyWordFind then if KeyWord('LODPhases') then begin WriteLN('-- Found a LODPhases (SkinedMesh section) at '+S+' --'); LODPhases ; KeyWordFind:=true; end;
  if not KeyWordFind then if KeyWord('WeightMapNames') then begin WriteLN('-- Found a WeightMapNames (SkinedMesh section) at '+S+' --'); WeightMapNames ; KeyWordFind:=true; end;
  {* BSP *}
  if not KeyWordFind then if KeyWord('CompressedVertexFormatData') then begin WriteLN('-- Found a CompressedVertexFormatData (SkinedMesh section) at '+S+' --'); CompressedVertexFormatData ; KeyWordFind:=true; end;
  {* BSP *}
  if not KeyWordFind then begin
   Writeln(Ftxt);Flush(Ftxt);
   Writeln(Ftxt,'ERROR! UNKNOWN WORD FROM SkinedMesh SECTION AT '+S);Flush(Ftxt);
   exit;
  end;
 end;
 dec(NbTab);
end;

Procedure SkinedMeshAnimation;
var
 LI : longint;
begin
 seekPlus('SkinedMeshAnimation');
 LI:=ReadLI;
 Seek(FMmod,LI+FilePos(FMmod));
 WriteLNTxt(' SkinedMeshAnimation '+StrSizeLI(LI));
 inc(NbTab);
 Tab; WriteLNTxt(' Unknown BSP section');
 dec(NbTab);
end;

Procedure Resource;
var
 PLI : longint;
 KeyWordFind : boolean;
 S : string;
begin
 SeekPlus('Resource');
 Write(Ftxt,' Resource ');
 PLI:=ReadLI;
 WriteLNSizeLI(PLI);
 inc(PLI,FilePos(FMmod));
 inc(NbTab);
 while FilePos(FMmod)<PLI do begin
  WriteLN(Ftxt);Flush(Ftxt);
  KeyWordFind:=false;
  Tab;
  WriteSizeLI(ReadLI);
  str(filepos(Fmmod),S);
  if not KeyWordFind then if KeyWord('Mesh') then begin WriteLN('-- Found a Mesh (Resource section) at '+S+' --'); Mesh; KeyWordFind:=true; end;
  if not KeyWordFind then if KeyWord('Aux') then begin WriteLN('-- Found a Aux (Resource section) at '+S+' --'); Aux; KeyWordFind:=true; end;
  if not KeyWordFind then if KeyWord('GeomMesh') then begin WriteLN('-- Found a GeomMesh (Resource section) at '+S+' --'); GeomMesh; KeyWordFind:=true; end;
  if not KeyWordFind then if KeyWord('ConvexObject') then begin WriteLN('-- Found a ConvexObject (Resource section) at '+S+' --'); ConvexObject; KeyWordFind:=true; end;
  if not KeyWordFind then if KeyWord('Note') then begin WriteLN('-- Found a Note (Resource section) at '+S+' --'); Note; KeyWordFind:=true; end;
  if not KeyWordFind then if KeyWord('GroupParams') then begin WriteLN('-- Found a GroupParams (Resource section) at '+S+' --'); GroupParams ; KeyWordFind:=true; end;
  if not KeyWordFind then if KeyWord('Geom') then begin WriteLN('-- Found a Geom (Resource section) at '+S+' --'); Geom ; KeyWordFind:=true; end;
  if not KeyWordFind then if KeyWord('SceneError') then begin WriteLN('-- Found a SceneError (Resource section) at '+S+' --'); SceneError ; KeyWordFind:=true; end;
  if not KeyWordFind then if KeyWord('MatrixIndexedMesh') then begin WriteLN('-- Found a MatrixIndexedMesh (Resource section) at '+S+' --'); MatrixIndexedMesh ; KeyWordFind:=true; end;
  if not KeyWordFind then if KeyWord('CloudSystem') then begin WriteLN('-- Found a CloudSystem (Resource section) at '+S+' --'); CloudSystem ; KeyWordFind:=true; end;
  if not KeyWordFind then if KeyWord('AnimationChannels') then begin WriteLN('-- Found a AnimationChannels (Resource section) at '+S+' --'); AnimationChannels ; KeyWordFind:=true; end;
  if not KeyWordFind then if KeyWord('SkinedMeshAnimation') then begin WriteLN('-- Found a SkinedMeshAnimation (Resource section) at '+S+' --'); SkinedMeshAnimation; KeyWordFind:=True; end;
  if not KeyWordFind then if KeyWord('SkinedMesh') then begin WriteLN('-- Found a SkinedMesh (Resource section) at '+S+' --'); SkinedMesh ; KeyWordFind:=true; end;
  if not KeyWordFind then begin
   Writeln(Ftxt);Flush(Ftxt);
   Writeln(Ftxt,'ERROR! UNKNOWN WORD FROM Resource SECTION AT '+S);Flush(Ftxt);
   exit;
  end;
 end;
 dec(NbTab);
end;

Procedure Name;
var
 LI1, LI2 : longint;
begin
 SeekPlus('Name');
 WriteTxt(' Name '); WriteSizeLI(ReadLI);
 LI1:=ReadLI;
 WriteSizeLI(LI1);
 for LI2:=1 to LI1 do WriteTxt(Chr(ReadB));
 WriteCR;
end;

Procedure Matrix;
var
 LI : longint;
 i,j,M : integer;
begin
 SeekPlus('Matrix');
 WriteTxt(' Matrix '); LI:=ReadLI; WriteLNSizeLI(LI);
 LI:=LI div 4;
 if LI=1 then M:=1;
 if LI=4 then M:=2;
 if LI=9 then M:=3;
 if LI=16 then M:=4;
 if LI=25 then M:=5;
 if LI=36 then M:=6;
 if LI=49 then M:=7;
 if LI=64 then M:=8;
 if LI=81 then M:=9;
 if LI=100 then M:=10;
 inc(NbTab);
 for i:=1 to M do begin
  Tab;
  for j:=1 to M do WriteR(ReadR);
  WriteLNTxt('');
 end;
 dec(NbTab);
end;

Procedure Resource2;
begin
 SeekPlus('Resource');
 WriteLNTxt(' Resource '+StrSizeLI(ReadLI)+StrLI(ReadLI));
end;

Procedure Flags;
begin
 SeekPlus('Flags');
 WriteLNTxt(' Flags '+StrSizeLI(ReadLI)+StrLI(ReadLI));
end;

Procedure Parent;
begin
 SeekPlus('Parent');
 WriteLNTxt(' Parent '+StrSizeLI(ReadLI)+StrLI(ReadLI));
end;

Procedure Item;
var
 PLI : longint;
 KeyWordFind : boolean;
 S : string;
begin
 SeekPlus('Item');
 WriteTxt(' Item ');
 PLI:=ReadLI;
 WriteLNSizeLI(PLI);
 inc(PLI,FilePos(FMmod));
 inc(NbTab);
 while FilePos(FMmod)<PLI do begin
  WriteLN(Ftxt);Flush(Ftxt);
  KeyWordFind:=false;
  Tab;
  WriteSizeLI(ReadLI);
  str(filepos(Fmmod),S);
  if not KeyWordFind then if KeyWord('Name') then begin WriteLN('-- Found a Name (Item section) at '+S+' --'); Name; KeyWordFind:=true; end;
  if not KeyWordFind then if KeyWord('Matrix') then begin WriteLN('-- Found a Matrix (Item section) at '+S+' --'); Matrix; KeyWordFind:=true; end;
  if not KeyWordFind then if KeyWord('Resource') then begin WriteLN('-- Found a Resource (Item section) at '+S+' --'); Resource2; KeyWordFind:=true; end;
  if not KeyWordFind then if KeyWord('Flags') then begin WriteLN('-- Found a Flags (Item section) at '+S+' --'); Flags; KeyWordFind:=true; end;
  if not KeyWordFind then if KeyWord('BoundingSphere') then begin WriteLN('-- Found a BoundingSphere (Item section) at '+S+' --'); BoundingSphere; KeyWordFind:=true; end;
  if not KeyWordFind then if KeyWord('BoundingBox') then begin WriteLN('-- Found a BoundingBox (Item section) at '+S+' --'); BoundingBox; KeyWordFind:=true; end;
  if not KeyWordFind then if KeyWord('Parent') then begin WriteLN('-- Found a Parent (Item section) at '+S+' --'); Parent; KeyWordFind:=true; end;
  if not KeyWordFind then begin
   Writeln(Ftxt);Flush(Ftxt);
   Writeln(Ftxt,'ERROR! UNKNOWN WORD FROM Item SECTION AT '+S);Flush(Ftxt);
   exit;
  end;
 end;
 dec(NbTab);
end;

Procedure Hierarchy;
var
 PLI : longint;
 KeyWordFind : boolean;
 S : string;
begin
 SeekPlus('Hierarchy');
 Write(Ftxt,' Hierarchy ');
 PLI:=ReadLI;
 WriteLNSizeLI(PLI);
 inc(PLI,FilePos(FMmod));
 inc(NbTab);
 while FilePos(FMmod)<PLI do begin
  WriteLN(Ftxt);Flush(Ftxt);
  KeyWordFind:=false;
  Tab;
  WriteSizeLI(ReadLI);
  str(filepos(Fmmod),S);
  if KeyWord('Item') then begin WriteLN('-- Found an Item (Hierarchy section) at '+S+' --'); Item; KeyWordFind:=true; end;
  if not KeyWordFind then begin
   Writeln(Ftxt);Flush(Ftxt);
   Writeln(Ftxt,'ERROR! UNKNOWN WORD FROM Hierarchy SECTION AT '+S);Flush(Ftxt);
   exit;
  end;
 end;
 dec(NbTab);
end;

Procedure ReadFmmod(NameF:string);
var
 PLI : longint;
 KeyWordFind : boolean;
 S : string;
 B : byte absolute NameF;
begin
 WriteLN;
 Write('Found '+NameF+', converting to ');
 assign(FMmod,NameF);

 dec(b,4);

 NameF:=NameF+'TXM';
 Writeln(NameF);
 assign(Ftxt,NameF);
 Rewrite(Ftxt);

 {$I-}
 Reset(Fmmod,1);
 {$I+}

 If IOResult=0 then begin
 {while IOResult=0 do begin}
  NbTab:=0;
  WriteSizeLI(ReadLI);
  if keyword('MMOD') then begin
   SeekPlus('MMOD');
   Write(Ftxt,' MMOD ');
   PLI:=ReadLI;
   WriteSizeLI(PLI);
   inc(PLI,FilePos(FMmod));
   WriteTxt(' '); WriteLNLI(ReadLI);
   inc(NbTab);
   str(PLI,S);
   WriteLN('MMOD size: '+S+'');
   WriteLN;
   WriteLN('-----------------------------');
   WriteLN('---- STARTING CONVERSION ----');
   WriteLN('-----------------------------');
   WriteLN;
   while (FilePos(FMmod)<PLI) and not EOF(FMmod)do begin
	WriteCR;
    KeyWordFind:=false;
    Tab;
    WriteSizeLI(ReadLI);
	str(filepos(Fmmod),S);
    if not KeyWordFind then if KeyWord('BoundingSphere') then begin WriteLN('-- Found a BoundingSphere (No section) at '+S+' --'); BoundingSphere; KeyWordFind:=true; end;
    if not KeyWordFind then if KeyWord('BoundingBox') then begin WriteLN('-- Found a BoundingBox (No section) at '+S+' --'); BoundingBox; KeyWordFind:=true; end;
    if not KeyWordFind then if KeyWord('Resource') then begin WriteLN('-- Found a Resource (No section) at '+S+' --'); Resource; KeyWordFind:=true; end;
    if not KeyWordFind then if KeyWord('Hierarchy') then begin WriteLN('-- Found a Hierarchy (No section) at '+S+' --'); Hierarchy; KeywordFind:=true; end;
    if not KeyWordFind then begin
	 WriteLN;
	 WriteLN('-----------------------------------');
     WriteLN('- UNKNOWN WORD AT '+S+'! -');
     WriteLN('- CHECK CONVERTED TXM FOR DETAILS -');
     WriteLN('-----------------------------------');
	 WriteLN;
     WriteLN('Conversion stopped. Press "ENTER" to go on.');
     ReadLN(S);
     close(FMmod);
     close(Ftxt);
     halt;
    end;
   end;
  end;
  close(FMmod);
 end;
 close(Ftxt);

end;

Function StrMajuscule(s:string):string; { retourne la même chaine de caractère que S mais tout en majuscules }
var
 i :integer;
 s2 : string;
begin
 S2:='';
 for i:= 1 to length(s) do begin
  case s[i] of
   'a'..'z' : S2:=S2+chr(ord(S[i])-32);
   else
    S2:=S2+S[i]
  end;
 end;
 StrMajuscule:=S2;
end;

Function FindNextMmodFile(var NameF : string):boolean;
var
 W : word;
 i : integer;
 Error : integer;
begin
 if PremiereRecherche then FindFirst('*.mmod',W,FRec) else FindNext(FRec);
 PremiereRecherche:=false;
 Error:=DosError;
 while (Error=0) and (StrMajuscule(RightStr(FRec.Name,5))<>'.MMOD') do begin
  FindNext(FRec);
  Error:=DosError;
 end;
 if Error=0 then NameF:=FRec.Name;
 FindNextMmodFile:=Error=0;

end;

var
 NameF : String;
 NbFile : integer ;                   { Nb de fichiers convertis }
 S : string;

begin
 WriteLN('MMOD to TXM Converter v1.1');
 WriteLN;

 NbFile := 0;
 while FindNextMmodFile(NameF) do begin
  ReadFMmod(NameF);
  inc(NbFile);
 end;
 str(NbFile,S);
 WriteLN;
 if NbFile=0 then
  WriteLN('NO MMOD FILE FOUND !')
 else
  if NbFile=1 then
    WriteLN('1 file succesfully converted')
   else
    WriteLN(S+' files successfully converted');
 WriteLN('Press "ENTER" to go on.');
 ReadLN(S);

end.