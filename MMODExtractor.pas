program MMODExtractor;

 {==============================================================================================}
 {                                                                                              }
 { ce programme ouvre tous les fichiers .mmod se trouvant dans son répertoire et retrouve tous  }
 { les LODs dans chacun d'eux pour en faire un fichier OBJ - 1 fichier OBJ part LOD             }
 {                                                                                              }
 {==============================================================================================}

uses sysutils, dos,strutils, Bin_Util, math;

const
 PrintSizeLI = false;

var
 FMmod,                             { fichier Mmod source }
 FVertex        : file;             { fichier des vertexs }
 FRapport       : Text;             { Rapport du travail fait }
 FOBJ           : Text;             { fichier destination }
 FMatLib        : Text;
 FSDCObj        : Text;
 FSDCMatLib     : Text;
 FPath          : Text;
 KeyWordIterations, IndicesTrackerGlobal, ItemNamesTracker, ItemNamesTracker2, GlobalSubsetTracker, LocalSubsetTracker, NoTextureTracker : longint;
 GlobalName, TexturesPath : string;
 ItemNames      : array of string;
 LODsTable      : array of longint;
 SubsetsTable   : array of longint;
 LODsPassed, LODsAdded, GlobalIndicesInc, GlobalIndicesTracker, GlobalSubsetTracker2, GlobalSubsetSpecialTracker, GlobalMatrixTracker, NbSubset : longint;
 IncIndicesYes, IsModelBSP, CanMatrix, DoExtractLOD4, FlipModel, IsPlane, IsGun, KeepSettings, AskedSettings, PassNextThrow : boolean;
 MatrixMoveXList, MatrixMoveYList, MatrixMoveZList : array of single;

 {*****************************************************************************************************}
 { lit le mot clef dans le fichier source                                                              }
 {*****************************************************************************************************}

Function ReadKeyWord : string;
var
 LI : longint;
 S : string;
begin
 KeyWordIterations:=0;
 ReadKeyWord:='';                       { valeur par défaut }
  {$I-}
 BlockRead(FMmod,LI,4);                 { lit la longueur du mot }
  {$I+}
  
 KeyWordIterations:=KeyWordIterations+4;

 if IOResult<>0 then exit;

  {$I-}
 BlockRead(FMmod,S[1],LI);                 { lit le mot clef }
  {$I+}
 S[0]:=chr(LI);
 
 KeyWordIterations:=KeyWordIterations+LI;

 if IOResult=0 then ReadKeyWord:=S;     { met à jour la valeur de la fonction }

end;

 {*****************************************************************************************************}
 { retourne la même chaine de caractère que S mais tout en majuscules                                  }
 {*****************************************************************************************************}

Function StrMajuscule(s:string):string;
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

 { IMPORTED FUNCTIONS FROM OTHER MMOD CONVERTERS START }

Function StrR(R:single) : string;
var
 S : string;
begin
 str(R:13:6,S);
 StrR:=S;
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

Function StrLI(LI:longint) : string;
var
 S : string;
begin
 str(LI:8,S);
 StrLI:=S;
end;

Function KeywordFind(S1 : string) : boolean;
var
 p : longint;
 S2 : string;
begin
 KeyWordIterations:=0;
 KeywordFind:=false;
 p:=filepos(Fmmod);
 {$i-}
 BlockRead(Fmmod,S2[1],length(S1));
 {$i+}
 KeyWordIterations:=KeyWordIterations+length(S1);
 if IOResult<>0 then begin
  seek(FMmod,p);
  exit;
 end;
 S2[0]:=S1[0];
 KeywordFind:=S1=S2;
 Seek(Fmmod,p);
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

Function ReadLI(readNums:longint): longint;
var
 LI : longint;
begin
 ReadLI:=0;
 {$I-}
 Blockread(Fmmod,LI,readNums);
 {$I+}
 if IOResult=0 then ReadLI:=LI;
end;

Procedure WriteW(W:word);
var
 s : string;
begin
 str(W,S);
 Writeln(S);
end;

 { IMPORTED FUNCTIONS FROM OTHER MMOD CONVERTERS END }

 {*****************************************************************************************************}
 { Constriut le fichier OBJ pour le subset demandé                                                     }
 { PosBeginIndices est la position du début de la section 'Indices' dans le ficjier mmod source        }
 { NFirstVertex est le N° du premier vertex pour un indice valant 0 (le premier a le N° 0)             }
 { dans le cas ou il y a plusieurs vertexstream dans le même mesh - VertexStreamindex<>0 dans subset   }
 {*****************************************************************************************************}

Procedure BuildSubset(name:string; PosBeginIndices, NFirstVertex, IndicesType : longint; TexName : string; IsLOD4 : boolean; MSHD : string; LocalSubsetTracker : longint);
var
 LI,
 FirstVertex,
 NbVertex,
 FirstIndice,
 NbIndice        : longint;
 TR3             : array[1..3] of single;  { stockage temporaire d'une composante des vertexs }
 TW3             : array[1..3] of word;    { stockage temporaire d'un indice }
 TW3_ext         : array[1..6] of word;    { stockage temporaire d'un indice }
 inc1            : longint;
 inc2            : longint;
 inc3            : longint;
 S, OtherFileName : string;
 int1            : longint;
 int2            : longint;
 int3            : longint;
 OBJFile         : text;
 OBJMtlFile      : text;
 {IsGlass, IsFoliage, IsDefault, IsSoldiers, }IsOther, CanProceed{, OtherMSHD} : boolean;
 OtherMSHDs      : array of string;
 MatrixX, MatrixY, MatrixZ : single;
begin
 
  { Lire les valeur de position et de nombre de vertex et d'incices }
 BlockRead(FMmod,LI,4);
 BlockRead(FMmod,FirstVertex,4);
 BlockRead(FMmod,NbVertex,4);
 BlockRead(FMmod,FirstIndice,4); FirstIndice:=FirstIndice div 3;
 BlockRead(FMmod,NbIndice,4);
 
 if DoExtractLOD4 = false then begin
 
  IsLOD4:=false;
  
 end;
 
 CanProceed:=true;
 OBJFile:=FOBJ;
 
 if NbIndice = 0 then begin
 
  IsLOD4:=false;
  CanProceed:=false;
  
  Writeln('---- ERROR: NO INDICES FOUND FOR "'+name+' '+MSHD+'"! ----');
  
  WriteLN(OBJFile);Flush(OBJFile);
  WriteLN(OBJFile,'# ---- ERROR: NO INDICES FOUND FOR "'+name+' '+MSHD+'"! ----');Flush(OBJFile);
  WriteLN(OBJFile);Flush(OBJFile);
 
 end;
 
 if CanProceed = true then begin
 
   { SUBSET INDICE DIFFERENTIATION START }
  
  IsOther:=false;
  //OtherMSHD:=false;
   
  //if GlobalSubsetTracker2<>0 then begin
  
   int2:=FilePos(FMmod);
   
   //Writeln(TexName);
   
   SetLength(OtherMSHDs, 50);
   
   OtherMSHDs[0]:='shipalphatestindexed.mshd';
   OtherMSHDs[1]:='shipvcindexed.mshd';
   OtherMSHDs[2]:='shipwindowindexed.mshd';
   OtherMSHDs[3]:='ropeindexed.mshd';
   OtherMSHDs[4]:='shipnumberindexed.mshd';
   OtherMSHDs[5]:='texturedindexed.mshd';
   OtherMSHDs[6]:='soldiers.mshd';
   OtherMSHDs[7]:='soldier.mshd';
   OtherMSHDs[8]:='cockpitwin.mshd';
   OtherMSHDs[9]:='foliage.mshd';
   OtherMSHDs[10]:='default.mshd';
   
   if IndicesType=102 then begin
    
    seek(FMmod, PosBeginIndices+(FirstIndice*2*6));
    
    Blockread(FMmod,TW3_ext,12);
    
    str(TW3_ext[1],S);
    int1:=StrToInt(S);
    str(TW3_ext[2],S);
    inc1:=StrToInt(S);
	str(TW3_ext[3],S);
    int2:=StrToInt(S);
    str(TW3_ext[4],S);
    inc2:=StrToInt(S);
	str(TW3_ext[5],S);
    int3:=StrToInt(S);
    str(TW3_ext[6],S);
    inc3:=StrToInt(S);
    
    if IsLOD4=true then begin
    
     dec(int1,FirstVertex);
     dec(int2,FirstVertex);
     dec(int3,FirstVertex);
    
    end;
    
    inc(int1);
    inc(int2);
    inc(int3);
    
    int1:=int1+(65535*inc1)+inc1;
    int2:=int2+(65535*inc2)+inc2;
    int3:=int3+(65535*inc3)+inc3;
    
    {str(int1,S);
    Writeln('First indice: '+S);
    
    str(inc1,S);
    Writeln('Second indice: '+S);}
    
   end;
   if IndicesType=101 then begin
    
    seek(FMmod, PosBeginIndices+(FirstIndice*2*3));
    
    Blockread(FMmod,TW3,6);
    
    str(TW3[1],S);
    int1:=StrToInt(S);
	str(TW3[2],S);
    int2:=StrToInt(S);
	str(TW3[3],S);
    int3:=StrToInt(S);
    
    if IsLOD4=true then begin
    
     dec(int1,FirstVertex);
     dec(int2,FirstVertex);
     dec(int3,FirstVertex);
    
    end;
    
    inc(int1);
    inc(int2);
    inc(int3);
    
    //str(int1,S);
    //Writeln('First indice: '+S);
    
   end;
   
   {IsGlass:=((CompareText('cockpitwin.mshd',MSHD)=0) and (int1=1));
   IsFoliage:=((CompareText('foliage.mshd',MSHD)=0) and (int1=1));
   IsDefault:=((CompareText('default.mshd',MSHD)=0) and (int1=1));
   IsSoldiers:=((CompareText('soldiers.mshd',MSHD)=0) and (int1=1));}
   
   if IsLOD4 = true then begin
   
    LocalSubsetTracker:=LocalSubsetTracker - 1;
   
   end;
   
   if ((int1 = 1) or (int2 = 1) or (int3 = 1)) and (LocalSubsetTracker > 0) then begin
	
	if PassNextThrow = false then begin
	
     IsOther:=true;
     
	end else begin
	
	 PassNextThrow:=false;
	 
	end;
	
   end;
   
   if IsOther = false then begin
   
    for int3:=1 to Length(OtherMSHDs) do begin
	 
     if CompareText(OtherMSHDs[int3-1],MSHD) = 0 then begin
      
 	  if IsLOD4 = false then begin
		
        IsOther:=true;
        
		if LocalSubsetTracker = 0 then begin
		 
		 PassNextThrow:=true;
		
		end;
		
        break;
       
 	  end;
 	 
     end;
    
    end;
   
   end;
   
   str(GlobalSubsetSpecialTracker,S);
   
   if IsLOD4 = true then begin
    
    name:=name+'_LOD4';
    
    assign(OBJFile,name+'.OBJ');
    Rewrite(OBJFile);
    assign(OBJMtlFile,name+'.mtl');
    Rewrite(OBJMtlFile);
    
    Writeln('-- "'+name+'.OBJ" created --');
    Writeln('-- "'+name+'.mtl" created --');
    
    WriteLN(OBJFile,'# File created by MMOD Model Extractor v1.0 for Battlestations: Pacific');Flush(OBJFile);
    WriteLN(OBJFile);Flush(OBJFile);
    
    WriteLN(OBJFile,'mtllib '+name+'.mtl');Flush(OBJFile);
    WriteLN(OBJFile);Flush(OBJFile);
    
    WriteLN(OBJMtlFile,'newmtl '+name+' '+MSHD);Flush(OBJMtlFile);
    WriteLN(OBJMtlFile,'Kd 0.502 0.502 0.502');Flush(OBJMtlFile);
    WriteLN(OBJMtlFile,'Ks 0.25 0.25 0.25');Flush(OBJMtlFile);
    WriteLN(OBJMtlFile,'Ns 30');Flush(OBJMtlFile);
    
    WriteLN(OBJMtlFile,'map_Kd '+TexturesPath+'\'+TexName+'.dds');Flush(OBJMtlFile);
    
   end else if IsOther=true then begin
    
    OtherFileName:=MSHD;
    Delete(OtherFileName,(Length(OtherFileName)-4),5);
    
    assign(OBJFile,name+'_'+OtherFileName+'_'+S+'.OBJ');
    Rewrite(OBJFile);
    
    Writeln('-- "'+name+'_'+OtherFileName+'_'+S+'.OBJ" created --');
    
    WriteLN(OBJFile,'# File created by MMOD Model Extractor v1.0 for Battlestations: Pacific');Flush(OBJFile);
    WriteLN(OBJFile);Flush(OBJFile);
    
    WriteLN(OBJFile,'mtllib '+name+'.mtl');Flush(OBJFile);
    WriteLN(OBJFile);Flush(OBJFile);
    
    GlobalSubsetSpecialTracker:=GlobalSubsetSpecialTracker+1;
   
   end;
   
   seek(FMmod, int2);
  
  //end;
  
   { SUBSET INDICE DIFFERENTIATION END }
  
  TexName:=TexName+' '+MSHD;
  
  {Writeln('LI: '+IntToStr(LI));
  Writeln('FirstVertex: '+IntToStr(FirstVertex));
  Writeln('NbVertex: '+IntToStr(NbVertex));
  Writeln('FirstIndice: '+IntToStr(FirstIndice));
  Writeln('NbIndice: '+IntToStr(NbIndice));}
  
  WriteLN(OBJFile,'# ---- OBJECT START ----');Flush(OBJFile);
  WriteLN(OBJFile);Flush(OBJFile);
  
   { lire la composante 'V' des vertexs et les écrire dans le fichier destination }
  for LI:=FirstVertex+NFirstVertex to pred(FirstVertex+NFirstVertex+NbVertex) do begin
   seek(FVertex,LI*8*4);                                                     { se positionner dans le fichier de vertex }
   BlockRead(FVertex,TR3,3*4);                                               { Lire les 3 réels }
   
   if IsNan(TR3[1]) or IsInfinite(TR3[1]) then begin
   
    TR3[1]:=0;
   
   end;
   if IsNan(TR3[2]) or IsInfinite(TR3[2]) then begin
   
    TR3[2]:=0;
   
   end;
   if IsNan(TR3[3]) or IsInfinite(TR3[3]) then begin
   
    TR3[3]:=0;
   
   end;
   
   MatrixX:=0;
   MatrixY:=0;
   MatrixZ:=0;
   
   if CanMatrix = true then begin
    
    MatrixX:=MatrixMoveXList[GlobalMatrixTracker - 1];
    MatrixY:=MatrixMoveYList[GlobalMatrixTracker - 1];
    MatrixZ:=MatrixMoveZList[GlobalMatrixTracker - 1];
    
   end;
    
   if FlipModel = true then begin
   
    TR3[3]:=-(TR3[3]);
    MatrixZ:=-(MatrixZ);
   
   {end else begin
   
    TR3[1]:=-(TR3[1]);
    MatrixX:=-(MatrixX);}
   
   end;
    
   TR3[1]:=TR3[1] + MatrixX;
   TR3[2]:=TR3[2] + MatrixY;
   TR3[3]:=TR3[3] + MatrixZ;
    
   WriteLN(OBJFile,'v',' ',TR3[1]:1:6,' ',TR3[2]:1:6,' ',TR3[3]:1:6);  { écrire dans le fichier destination }
   Flush(OBJFile);
  end;
  
   { lire la composante 'Vt' des vertexs et les écrire dans le fichier destination }
  for LI:=FirstVertex+NFirstVertex to pred(FirstVertex+NFirstVertex+NbVertex) do begin
   seek(FVertex,LI*8*4+6*4);                                                 { se positionner dans le fichier de vertex }
   BlockRead(FVertex,TR3,2*4);                                               { Lire les 2 réels }
   
   if IsNan(TR3[1]) or IsInfinite(TR3[1]) then begin
   
    TR3[1]:=0;
   
   end;
   if IsNan(TR3[2]) or IsInfinite(TR3[2]) then begin
   
    TR3[2]:=0;
   
   end;
   
   if IsModelBSP = false then begin
   
    TR3[1]:=TR3[1];
    TR3[2]:=-TR3[2];
   
   end else begin
   
    TR3[1]:=-TR3[1];
    TR3[2]:=-TR3[2];
   
   end;
   
   WriteLN(OBJFile,'vt',' ',TR3[1]:1:6,' ',TR3[2]:1:6);                   { écrire dans le fichier destination }
   Flush(OBJFile);
  end;
  
   { lire la composante 'Vn' des vertexs et les écrire dans le fichier destination }
  for LI:=FirstVertex+NFirstVertex to pred(FirstVertex+NFirstVertex+NbVertex) do begin
   seek(FVertex,LI*8*4+3*4);                                                 { se positionner dans le fichier de vertex }
   BlockRead(FVertex,TR3,3*4);                                               { Lire les 3 réels }
   
   if IsNan(TR3[1]) or IsInfinite(TR3[1]) then begin
   
    TR3[1]:=0;
   
   end;
   if IsNan(TR3[2]) or IsInfinite(TR3[2]) then begin
   
    TR3[2]:=0;
   
   end;
   if IsNan(TR3[3]) or IsInfinite(TR3[3]) then begin
   
    TR3[3]:=0;
   
   end;
   
   MatrixX:=0;
   MatrixY:=0;
   MatrixZ:=0;
   
   if CanMatrix = true then begin
    
    MatrixX:=MatrixMoveXList[GlobalMatrixTracker - 1];
    MatrixY:=MatrixMoveYList[GlobalMatrixTracker - 1];
    MatrixZ:=MatrixMoveZList[GlobalMatrixTracker - 1];
    
   end;
   
   if FlipModel = true then begin
   
    TR3[3]:=-(TR3[3]);
    MatrixZ:=-(MatrixZ);
   
   {end else begin
   
    TR3[1]:=-(TR3[1]);
    MatrixX:=-(MatrixX);}
   
   end;
   
   TR3[1]:=TR3[1] + MatrixX;
   TR3[2]:=TR3[2] + MatrixY;
   TR3[3]:=TR3[3] + MatrixZ;
   
   WriteLN(OBJFile,'vn',' ',TR3[1]:1:6,' ',TR3[2]:1:6,' ',TR3[3]:1:6); { écrire dans le fichier destination }
   Flush(OBJFile);
  end;
  
  if IsLOD4=true then begin
  
   WriteLN(OBJFile);Flush(OBJFile);
   WriteLN(OBJFile,'g '+name+' '+MSHD);Flush(OBJFile);
   WriteLN(OBJFile,'usemtl '+name+' '+MSHD);Flush(OBJFile);
  
  end else begin
  
   WriteLN(OBJFile);Flush(OBJFile);
   WriteLN(OBJFile,'g '+TexName);Flush(OBJFile);
   WriteLN(OBJFile,'usemtl '+TexName);Flush(OBJFile);
  
  end;
  
   {* Extended Indices format *}
  if IndicesType=102 then begin
    { lire les indices et mettre à jour leur valeur avant d'écrire dans le fichier destination }
   for LI:=FirstIndice to pred(Firstindice+NbIndice) do begin
    seek(FMmod,PosBeginIndices+(LI*2*6));                                     { se positionner dans le fichier source }
    Blockread(FMmod,TW3_ext,12);                                                   { lire 6 entiers }
    
    str(TW3_ext[1],S);
    int1:=StrToInt(S);
    str(TW3_ext[3],S);
    int2:=StrToInt(S);
    str(TW3_ext[5],S);
    int3:=StrToInt(S);
    
    str(TW3_ext[2],S);
    inc1:=StrToInt(S);
    str(TW3_ext[4],S);
    inc2:=StrToInt(S);
    str(TW3_ext[6],S);
    inc3:=StrToInt(S);
    
     { ajuster la valeur des indices }
    
    if (IsLOD4 = true) or (IsOther = true) then begin
     
     dec(int1,FirstVertex);
     dec(int2,FirstVertex);
     dec(int3,FirstVertex);
    
    end;
    
    inc(int1);
    inc(int2);
    inc(int3);
    
    {if CompareText('foliage.mshd',MSHD)=0 then begin
    
     Writeln('FOLIAGE!!!!!!!');
 	
 	GlobalIndicesTracker:=int3+(65535*inc3)+inc3;
 	
 	int1:=int1+GlobalIndicesInc;
 	int2:=int2+GlobalIndicesInc;
 	int3:=int3+GlobalIndicesInc;
 	
    end else begin
     
 	GlobalIndicesInc:=int3+(65535*inc3)+inc3;
 	
 	int1:=int1+GlobalIndicesTracker;
     int2:=int2+GlobalIndicesTracker;
     int3:=int3+GlobalIndicesTracker;
 	
    end;}
    
    {if TW3_ext[2]>0 then begin
    
     inc1:=1;
 	
    end;
    if TW3_ext[4]>0 then begin
    
     inc2:=1;
 	
    end;
    if TW3_ext[6]>0 then begin
    
     inc3:=1;
 	
    end;}
    
     { écrire les indices dans le fichier destination }
	if FlipModel = true then begin
	
	 Writeln(OBJFile,'f ',
      int3+(65535*inc3)+inc3,'/',int3+(65535*inc3)+inc3,'/',int3+(65535*inc3)+inc3,' ',
      int2+(65535*inc2)+inc2,'/',int2+(65535*inc2)+inc2,'/',int2+(65535*inc2)+inc2,' ',
      int1+(65535*inc1)+inc1,'/',int1+(65535*inc1)+inc1,'/',int1+(65535*inc1)+inc1
     );
     Flush(OBJFile);
	
	end else begin
	
     Writeln(OBJFile,'f ',
      int1+(65535*inc1)+inc1,'/',int1+(65535*inc1)+inc1,'/',int1+(65535*inc1)+inc1,' ',
      int2+(65535*inc2)+inc2,'/',int2+(65535*inc2)+inc2,'/',int2+(65535*inc2)+inc2,' ',
      int3+(65535*inc3)+inc3,'/',int3+(65535*inc3)+inc3,'/',int3+(65535*inc3)+inc3
     );
     Flush(OBJFile);
    
	end;
	
    {Writeln(OBJFile,'f ',
     TW3_ext[1]+(65535*TW3_ext[2])+inc1,'/',TW3_ext[1]+(65535*TW3_ext[2])+inc1,'/',TW3_ext[1]+(65535*TW3_ext[2])+inc1,' ',
     TW3_ext[3]+(65535*TW3_ext[4])+inc2,'/',TW3_ext[3]+(65535*TW3_ext[4])+inc2,'/',TW3_ext[3]+(65535*TW3_ext[4])+inc2,' ',
     TW3_ext[5]+(65535*TW3_ext[6])+inc3,'/',TW3_ext[5]+(65535*TW3_ext[6])+inc3,'/',TW3_ext[5]+(65535*TW3_ext[6])+inc3
    );}
    
    {Writeln(OBJFile,'f ',
     TW3_ext[1],'/',TW3_ext[1],'/',TW3_ext[1],' ',
     TW3_ext[3],'/',TW3_ext[3],'/',TW3_ext[3],' ',
     TW3_ext[5],'/',TW3_ext[5],'/',TW3_ext[5]
    );}
    
    {Writeln(OBJFile,'f ',
     int1,'/',TW3_ext[2],'/',int2,'/',TW3_ext[4],'/',int3,'/',TW3_ext[6]
    );}
     
    //GlobalIndicesInc:=int3+(65535*inc3)+inc3;
    //GlobalIndicesInc:=GlobalIndicesInc+3;
 	
   end;
  end;
   {* Extended Indices format *}
  if IndicesType=101 then begin
    { lire les indices et mettre à jour leur valeur avant d'écrire dans le fichier destination }
   for LI:=FirstIndice to pred(Firstindice+NbIndice) do begin
    seek(FMmod,PosBeginIndices+(LI*2*3));                                     { se positionner dans le fichier source }
    Blockread(FMmod,TW3,6);                                                    { lire 3 entiers }
    
     { lire 3 entiers }
    {TW3[1]:=ReadLI(2);
    TW3[2]:=ReadLI(2);
    TW3[3]:=ReadLI(2);}
    
     { ajuster la valeur des indices }
 	
    if (IsLOD4 = true) or (IsOther = true) then begin
 	
     dec(TW3[1],FirstVertex);
     dec(TW3[2],FirstVertex);
     dec(TW3[3],FirstVertex);
    
    end;
    
    inc(TW3[1]);
    inc(TW3[2]);
    inc(TW3[3]);
    
     { écrire les indices dans le fichier destination }
	if FlipModel = true then begin
	 
	 Writeln(OBJFile,'f ',
      TW3[3],'/',TW3[3],'/',TW3[3],' ',
      TW3[2],'/',TW3[2],'/',TW3[2],' ',
      TW3[1],'/',TW3[1],'/',TW3[1]
     );
     Flush(OBJFile);
	 
	end else begin
	 
     Writeln(OBJFile,'f ',
      TW3[1],'/',TW3[1],'/',TW3[1],' ',
      TW3[2],'/',TW3[2],'/',TW3[2],' ',
      TW3[3],'/',TW3[3],'/',TW3[3]
     );
     Flush(OBJFile);
	 
	end;
    
    //GlobalIndicesInc:=TW3[3];
    //GlobalIndicesInc:=GlobalIndicesInc+3;
    
   end;
  end;
  
  WriteLN(OBJFile);Flush(OBJFile);
  WriteLN(OBJFile,'# ---- OBJECT END ----');Flush(OBJFile);
  WriteLN(OBJFile);Flush(OBJFile);
  
  if IsLOD4=true then begin
 
  Close(OBJFile);
  Close(OBJMtlFile);
 
 end else if IsOther=true then begin
 
  Close(OBJFile);
 
 end;
 
 end;
 
 GlobalSubsetTracker2:=GlobalSubsetTracker2+1;
 
end;

 {*********************************************************************************************}
 { lit la chaine S contenant les 3 indices, et le retournes dans W1, W2 et W3                  }
 {*********************************************************************************************}

Procedure ReadIndice(S : string; var W1,W2,W3 : word);
var
 S2 : string;
 i,
 j :integer;
begin

  {ejecter les 2 premiers caractères }
 S2:='';
 for i:=3 to length(S) do S2:=S2+S[i];
 S:=S2;

  { trouver le premier '/' }
 i:=1;
 while S[i]<>'/' do inc(i);

  { lire le premier nombre }
 val(LeftStr(S,pred(i)),W1,j);

  { trouver le ' ' suivant }
 while S[i]<>' ' do inc(i);

  {ejecter les i premiers caractères }
 S2:='';
 for j:=succ(i) to length(S) do S2:=S2+S[j];
 S:=S2;

  { trouver le '/' suivant}
 i:=1;
 while S[i]<>'/' do inc(i);

  { lire le second nombre }
 val(LeftStr(S,pred(i)),W2,j);

  { trouver le ' ' suivant }
 while S[i]<>' ' do inc(i);

  {ejecter les i premiers caractères }
 S2:='';
 for j:=succ(i) to length(S) do S2:=S2+S[j];
 S:=S2;

  { trouver le '/' suivant}
 i:=1;
 while S[i]<>'/' do inc(i);

  { lire le troisieme nombre }
 val(LeftStr(S,pred(i)),W3,j);

end;



 {*********************************************************************************************}
 { construit le fichier OBJ pour les LODPhase utilisant les subset de FirstSubset à LastSubset }
 {*********************************************************************************************}

Procedure BuildLODPhase(Name : string; NLOD,FirstSubset,LastSubset:integer);
var
 W1, W2, W3            : word;
 i,
 Subset                : integer;
 NbVertexDebutSection,               { mémorise le nombre de vertex avant de commencer un nouveau subset }
 NbVertex              : longint;
 FV, FVt, FVn,                       { fichier provisoir des vertexs }
 FIndices,                           { fichier provisoir des indices }
 FSubset,                            { fichier source subset }
 FOBJ                  : Text;       { fichier OBJ destination }
 S                     : string;
begin

  { initialiser les fichiers temporaires }
 assign(FV,'FV.TXT');               Rewrite(FV);
 assign(FVt,'FVt.TXT');             Rewrite(FVt);
 assign(FVn,'FVn.TXT');             Rewrite(FVn);
 assign(FIndices,'Indices.TXT');    Rewrite(FIndices);

 NbVertexDebutSection:=0;

 for Subset:=FirstSubset to LastSubset do begin

   { assigner et initialiser le fichier subset source }
  str(Subset,S);
  assign(FSubset,Name+'_Subset_'+S+'.OBJ');
  Reset(FSubset);
  
  Writeln('-- "'+Name+'_Subset_'+S+'.OBJ" created --');
  
  NbVertex:=0;

   { lire le fichier source, et écrire dans les fichiers provisoirs }
  while not EOF(FSubset) do begin
   ReadLN(FSubset,S);
   if (S[1]='v') and ((S[2]=chr(9)) or (S[2]=' ')) then begin           { vertex 'v' }
    inc(NbVertex);
    WriteLN(FV,S);
   end;
   if (S[1]='v') and (S[2]='t') then WriteLN(FVt,S);                   { vertex 'vt'}
   if (S[1]='v') and (S[2]='n') then WriteLN(FVn,S);                   { vertex 'vn'}

   if S[1]='f' then begin
     { il s'agit d'un indice : le lire, ajuster ses valeurs et l'écrire dans le fichier provisoir }
    ReadIndice(S,W1,W2,W3);
    inc(W1,NbVertexDebutSection);
    inc(W2,NbVertexDebutSection);
    inc(W3,NbVertexDebutSection);

    Writeln(FIndices,'f ',
     W1,'/',W1,'/',W1,' ',
     W2,'/',W2,'/',W2,' ',
     W3,'/',W3,'/',W3
    );
   end;
  end;

  close(FSubset);

  inc(NbVertexDebutSection,NbVertex);

 end;

  { initialiser le fichier destination }
 str(NLod:2,S);
 assign(FOBJ,Name+'_LOD'+S+'.OBJ'); Rewrite(FOBJ);

 Writeln('-- "'+Name+'_LOD'+S+'.OBJ" created --');

  { Copier les fichiers temporaires dans le fichier destinaion }
 reset(FV);
 reset(FVt);
 reset(FVn);
 reset(FIndices);

 while not EOF(FV)        do begin ReadLN(FV,S);        WriteLN(FOBJ,S); end;
 while not EOF(FVt)       do begin ReadLN(FVt,S);       WriteLN(FOBJ,S); end;
 while not EOF(FVn)       do begin ReadLN(FVn,S);       WriteLN(FOBJ,S); end;
 while not EOF(FIndices)  do begin ReadLN(FIndices,S);  WriteLN(FOBJ,S); end;

  { fermer les fichiers }
 close(FOBJ);
 close(FV);        Erase(FV);
 close(FVt);       Erase(FVt);
 close(FVn);       Erase(FVn);
 close(FIndices);  Erase(FIndices);
end;

 {***************************************************************************************}
 { Lit la section Mesh pour en extraire les 'Vertex', 'Indices', 'Subset' et 'LODs'      }
 {***************************************************************************************}

Procedure ReadMesh(Name:string);
type
 T_pssn4nubn4ussn2 = record
                      v  : array[1..4] of smallint;
                      vn : array[1..4] of shortint;
                      vt : array[1..2] of smallint;
                     end;
 T_pssn4nf24ussn2ussn2ccif41 = record
                                v  : array[1..4] of smallint;
                                vn : array[1..4] of Float_16;   { short reel }
                                vt : array[1..2] of smallint;
                               end;
 T_pf24nubn4ussn2ussn2 = record
                          v  : array[1..4] of Float_16;
                          vn : array[1..4] of shortint;
                          vt : array[1..2] of smallint;
                         end;
 T_pf43nubn4ussn2 = record
                     v  : array[1..3] of single;
                     vn : array[1..4] of shortint;
                     vt : array[1..2] of smallint;
                    end;
 T_pssn4ussn2 = record
                 v  : array[1..4] of smallint;
                 vt : array[1..2] of smallint;
                end;

var
 SM                        : smallint;
 pssn4ussn2                : T_pssn4ussn2;
 pssn4nf24ussn2ussn2ccif41 : T_pssn4nf24ussn2ussn2ccif41;
 pssn4nubn4ussn2           : T_pssn4nubn4ussn2;
 pf24nubn4ussn2ussn2       : T_pf24nubn4ussn2ussn2;
 pf43nubn4ussn2            : T_pf43nubn4ussn2;
 RCompressed1,
 RCompressed2,
 RCompressed3              : single;                   { valeur des taux de compression de compressedvertexformatdata }
 BSP                       : boolean;                  { vrai s'il s'agit d'un format BSP }
 pssn4_ussn2,
 pf43,
 pf24,                                                 { est vrai quand le format BSP pf24 est rencontré }
 nf24                      : boolean;                  { est vrai quand un format BSP nf24 est rencontré }
 Pos,
 PosCompressedVertexFormatData,
 PosBeginIndices,
 IndicesReadNum,
 IndicesType,
 PosBeginMesh, PosEndMesh,                             { position du début et de la fin de la section 'Mesh' }
 PosBeginVertexStream,                                 { position du début du vertexstream }
 NbVertex,                                             { nombre de Vertex dans VertexStream }
 LVertex,                                              { Longueur d'un vertex }
 LVertexStream,                                        { longueur de la section 'vertexstream' }
 NbLODPhases,
 FirstSubset,
 LastSubset,
 PosBeginSubset, PosEndSubset,                          { position du début et de la fin de la section 'subset' }
 LI, LI1, LI2, TexIdx      : longint;
 S,
 KeyWord                   : string;
 MSHD, CurrentName         : string;
 TexName, TexTxt, TexExt, FirstTexName : string;
 TexTracker                : integer;
 Textured, CanExport, TexturedLocal, HasBump : boolean;
 Vertex                    : array[1..8] of single;
 TVertexStreamIndex        : array[0..9] of longint;    { position du début du vertexstream dans le fichier FVertex }
 VertexStreamIndex, int1   : longint;                   { index du VertexStream dans le Subset }
 NbIndexVertexStream       : integer;
 TexFormatTable            : array of string;

begin

 BlockRead(FMmod,LI1,4);          { lire la longueur de la section }
 BlockRead(FMmod,LI2,4);          { ejecter 1 nombre }
 PosBeginMesh:=FilePos(FMmod);    { mémoriser la position du début de le section }
 PosEndMesh:=PosBeginMesh+LI1-4;  { mémoriser la position de la fin de la section }
 
 {*******************************************************************************}
 { 1ere étape : retrouver tous les 'VertexStream' et faire un fichier des vertex }
 {*******************************************************************************}
 
 { initialier le fichier temporaire des vertex }
 assign(FVertex,'vertex');
 Rewrite(FVertex,1);
 
 NbIndexVertexStream:=0;
 
 while FilePos(FMmod)<PosEndMesh do begin
 
  KeyWord:=ReadKeyWord;            { lire le mot clef }
 
  if KeyWord='VertexStream' then begin
 
    { lire la longueur de la section }
   BlockRead(FMmod,LVertexStream,4);
   
    { calculer la position de vertexcompressedformatdata }
   PosCompressedVertexFormatData:=FilePos(FMmod);
   inc(PosCompressedVertexFormatData,LVertexStream);
 
    { lire le nombre de vertexs dans le vertexstream }
   BlockRead(FMmod,NbVertex,4);
 
    { mémoriser le nombre de vertex dans IndexVertexStream }
   TVertexStreamIndex[NbIndexVertexStream]:=FileSize(FVertex) div (8*4);
   
    { lire le type de mvfm et y associer la longueur de chaque vertex }
   BSP:=false;
   pssn4_ussn2:=false;
   nf24:=false;
   pf24:=false;
   pf43:=false;
   KeyWord:=readKeyWord;
 
   LVertex:=0;
   if KeyWord='ship.mvfm' then LVertex:=64;
   if KeyWord='shipvc.mvfm' then LVertex:=68;
   if KeyWord='rope.mvfm' then LVertex:=36;
   if KeyWord='gunvc.mvfm' then LVertex:=36;
   if KeyWord='simple.mvfm' then LVertex:=32;
   if KeyWord='simpleindexed.mvfm' then LVertex:=36;
   if KeyWord='bterrain2.mvfm' then LVertex:=40;
   if KeyWord='shore.mvfm' then LVertex:=24;
   if KeyWord='position.mvfm' then LVertex:=12;
   if KeyWord='airplane.mvfm' then LVertex:=56;
   if KeyWord='airfield.mvfm' then LVertex:=40;
 
    { vertex stream de BSP }
   if KeyWord='pssn4nubn4ussn2cc.mvfm' then begin LVertex:=20; BSP:=true; end;
   if KeyWord='pssn4nubn4ussn2ccif41.mvfm' then begin LVertex:=24; BSP:=true; end;
   if KeyWord='pssn4nubn4ussn2if41.mvfm' then begin LVertex:=20; BSP:=true; end;
   if KeyWord='pssn4nubn4ussn2uf41if41.mvfm' then begin LVertex:=24; BSP:=true; end;
   if KeyWord='pssn4nubn4ussn2ussn2ccif41.mvfm' then begin LVertex:=28; BSP:=true; end;
   if KeyWord='pssn4nubn4ussn2ussn2if41.mvfm' then begin LVertex:=24; BSP:=true; end;
   if KeyWord='pssn4nubn4ussn2ussn2.mvfm' then begin LVertex:=20; BSP:=true; end;
   if KeyWord='pssn4nubn4ussn2.mvfm' then begin LVertex:=16; BSP:=true; end;
   if KeyWord='pssn4nf24ussn2ussn2ccif41.mvfm' then begin LVertex:=32; BSP:=true; nf24:=true; end;
   if KeyWord='pssn4nf24ussn2ccif41.mvfm' then begin LVertex:=28; BSP:=true; nf24:=true; end;
   if KeyWord='pssn4nf24ussn2ussn2.mvfm' then begin LVertex:=24; BSP:=true; nf24:=true; end;
   if KeyWord='pf24nubn4ussn2ussn2.mvfm' then begin LVertex:=20; BSP:=true; pf24:=true; end;
   if KeyWord='pssn4nubn4ussn2uf22.mvfm' then begin LVertex:=20; BSP:=true; end;
   if KeyWord='pf43nubn4ussn2ussn2.mvfm' then begin LVertex:=24; BSP:=true; pf43:=true; end;
   if KeyWord='pssn4nubn4ussn2uf42.mvfm' then begin LVertex:=24; BSP:=true; end;
   if KeyWord='pssn4ussn2.mvfm' then begin LVertex:=12; BSP:=true; pssn4_ussn2:=true; end;
   if KeyWord='pf43.mvfm' then begin LVertex:=12; BSP:=true; pf43:=true; end;
   if KeyWord='pssn4.mvfm' then begin LVertex:=8; BSP:=true; end;
 
   if LVertex=0 then begin
   Writeln;
    Writeln('********************************************');
    Writeln('    ',Keyword);
    Writeln('*    UNKNOWN VERTEX FORMAT : HALTING       *');
    Writeln('********************************************');
    Writeln;
    writeln('Press "ENTER" to exit.');
    ReadLN;
    halt;
   end;
 
    { mémroriser la position du début des vertexs de 'vertexstream' }
   PosBeginVertexStream:=FilePos(FMmod);
 
     { lire tous les vertex et creer le fichier de vertex }
   if BSP then begin
     { il s'agit d'un fichier au format BSP }
    
	if IsModelBSP=false then begin
	
	 IsModelBSP:=true;
	 
	 Writeln('---- WARNING: This model includes the BSP Vertex Format, which is not supported! ----');
	 
	end;
	
     { aller lire les valeur de CompressedVertexFormatData }
    seek(FMmod,PosCompressedVertexFormatData);  { se positionner dans le fichier }
 
    if ReadKeyWord='CompressedVertexFormatData' then begin
 
     BlockRead(FMmod,LI,4);  { éjecter la longueur }
 
      { lire les taux de compression }
     BlockRead(FMmod,RCompressed1,4);
     BlockRead(FMmod,RCompressed2,4);
     BlockRead(FMmod,RCompressed3,4);
 
 
      { se replacer dans le fichier }
     seek(Fmmod,PosBeginVertexStream);
 
     for LI1:=1 to NbVertex do begin
 
      Pos:=FilePos(FMmod);
 
      if nf24 then begin
		
		//Writeln('nf24!!!!!!!!!!');
		
        { lire les valeurs compressée dans FMmod }
       BlockRead(FMmod,pssn4nf24ussn2ussn2ccif41,20);
		
        { calculer les valeurs décompressées }
       Vertex[1]:=pssn4nf24ussn2ussn2ccif41.v[1]; Vertex[1]:=Vertex[1]*RCompressed1/32767;
       Vertex[2]:=pssn4nf24ussn2ussn2ccif41.v[2]; Vertex[2]:=Vertex[2]*RCompressed2/32767;
       Vertex[3]:=pssn4nf24ussn2ussn2ccif41.v[3]; Vertex[3]:=Vertex[3]*RCompressed3/32767;
       Vertex[4]:=decompress_Float_16(pssn4nf24ussn2ussn2ccif41.vn[1]);
       Vertex[5]:=decompress_Float_16(pssn4nf24ussn2ussn2ccif41.vn[2]);
       Vertex[6]:=decompress_Float_16(pssn4nf24ussn2ussn2ccif41.vn[3]);
       Vertex[7]:=pssn4nf24ussn2ussn2ccif41.vt[1]; Vertex[7]:=Vertex[7]/32767;
	   Vertex[8]:=pssn4nf24ussn2ussn2ccif41.vt[2]; Vertex[8]:=Vertex[8]/32767;
	   
      end
      else
      begin
       
	   if pf24 then begin
		
		//Writeln('pf24!!!!!!!!!!');
		
         { lire les valeurs compressée dans FMmod }
        BlockRead(FMmod,pf24nubn4ussn2ussn2,20);
 
         { calculer les valeurs décompressées }
        Vertex[1]:=decompress_Float_16(pf24nubn4ussn2ussn2.v[1]);
        Vertex[2]:=decompress_Float_16(pf24nubn4ussn2ussn2.v[2]);
        Vertex[3]:=decompress_Float_16(pf24nubn4ussn2ussn2.v[3]);
        Vertex[4]:=pf24nubn4ussn2ussn2.vn[1]; Vertex[4]:=Vertex[4]/127;
        Vertex[5]:=pf24nubn4ussn2ussn2.vn[2]; Vertex[5]:=Vertex[5]/127;
        Vertex[6]:=pf24nubn4ussn2ussn2.vn[3]; Vertex[6]:=Vertex[6]/127;
        Vertex[7]:=pf24nubn4ussn2ussn2.vt[1]; Vertex[7]:=Vertex[7]/32767;
        Vertex[8]:=pf24nubn4ussn2ussn2.vt[2]; Vertex[8]:=Vertex[8]/32767;
 
       end
       else
       begin
        if pf43 then begin
         if LVertex=12 then begin
 
			//Writeln('pf43!!!!!!!!!!');
 
          BlockRead(FMmod,Vertex[1],4);
          BlockRead(FMmod,Vertex[2],4);
          BlockRead(FMmod,Vertex[3],4);
          Vertex[4]:=0;
          Vertex[5]:=0;
          Vertex[6]:=0;
          Vertex[7]:=0;
          Vertex[8]:=0;
 
         end
         else
         begin
			
			//Writeln('pf43nubn4ussn2 other!!!!!!!!!!');
			
          BlockRead(Fmmod,pf43nubn4ussn2,20);
 
          Vertex[1]:=pf43nubn4ussn2.v[1];
          Vertex[2]:=pf43nubn4ussn2.v[2];
          Vertex[3]:=pf43nubn4ussn2.v[3];
          Vertex[4]:=pf43nubn4ussn2.vn[1]; Vertex[4]:=Vertex[4]/127;
          Vertex[5]:=pf43nubn4ussn2.vn[2]; Vertex[5]:=Vertex[5]/127;
          Vertex[6]:=pf43nubn4ussn2.vn[3]; Vertex[6]:=Vertex[6]/127;
          Vertex[7]:=pf43nubn4ussn2.vt[1]; Vertex[7]:=Vertex[7]/32767;
          Vertex[8]:=pf43nubn4ussn2.vt[2]; Vertex[8]:=Vertex[8]/32767;
 
         end;
        end
        else
        begin
 
         if pssn4_ussn2 then begin
			
			//Writeln('pssn4_ussn2!!!!!!!!!!');
			
          BlockRead(FMmod,pssn4ussn2,12);
 
          Vertex[1]:=pssn4ussn2.v[1]; Vertex[1]:=Vertex[1]*RCompressed1/32767;
          Vertex[2]:=pssn4ussn2.v[2]; Vertex[2]:=Vertex[2]*RCompressed2/32767;
          Vertex[3]:=pssn4ussn2.v[3]; Vertex[3]:=Vertex[3]*RCompressed3/32767;
          Vertex[4]:=0;
          Vertex[5]:=0;
          Vertex[6]:=0;
          Vertex[7]:=pssn4ussn2.vt[1]; Vertex[7]:=Vertex[7]/32767;
          Vertex[8]:=pssn4ussn2.vt[2]; Vertex[8]:=Vertex[8]/32767;
 
         end
         else
         begin
			
			//Writeln('pssn4_ussn2 other!!!!!!!!!!');
			
          if LVertex=8 then begin
 
           BlockRead(FMmod,SM,2);
           Vertex[1]:=SM*RCompressed1/32767;
           BlockRead(FMmod,SM,2);
           Vertex[2]:=SM*RCompressed2/32767;
           BlockRead(FMmod,SM,2);
           Vertex[3]:=SM*RCompressed3/32767;
 
          end
          else
          begin
            { lire les valeurs compressée dans FMmod }
           BlockRead(FMmod,pssn4nubn4ussn2,16);
			
			//Writeln('pssn4nubn4ussn2 other!!!!!!!!!!');
			
            { calculer les valeurs décompressées }
           Vertex[1]:=pssn4nubn4ussn2.v[1]; Vertex[1]:=Vertex[1]*RCompressed1/32767;
           Vertex[2]:=pssn4nubn4ussn2.v[2]; Vertex[2]:=Vertex[2]*RCompressed2/32767;
           Vertex[3]:=pssn4nubn4ussn2.v[3]; Vertex[3]:=Vertex[3]*RCompressed3/32767;
           Vertex[4]:=pssn4nubn4ussn2.vn[1]; Vertex[4]:=Vertex[4]/127;
           Vertex[5]:=pssn4nubn4ussn2.vn[2]; Vertex[5]:=Vertex[5]/127;
           Vertex[6]:=pssn4nubn4ussn2.vn[3]; Vertex[6]:=Vertex[6]/127;
           Vertex[7]:=pssn4nubn4ussn2.vt[1]; Vertex[7]:=Vertex[7]/32767;
           Vertex[8]:=pssn4nubn4ussn2.vt[2]; Vertex[8]:=Vertex[8]/32767;
 
          end;
         end;
        end;
       end;
      end;
      BlockWrite(FVertex,Vertex,8*4);             { écrire les 8 nombres réel }
       { se placer juste après le vertex }
      seek(FMmod,Pos+LVertex);
 
     end;
	 
    end
	else
    begin
     writeln('---- UNKNOWN VERTEX DATA FORMAT - HALTING ----');
     ReadLN;
     halt;
    end;
   end
   else
   begin
    
	{ il s'agit d'un fichier au format BSM }
    for LI1:=1 to NbVertex do begin
 
     Pos:=FilePos(FMMod);                         { mémoriser la position du vertex }
 
     if LVertex>24 then begin                     { cas le plus courant }
      BlockRead(FMmod,Vertex,8*4);                { lire les 8 nombres réels }
      BlockWrite(FVertex,Vertex,8*4);             { écrire les 8 nombres réel }
     end;
 
     if LVertex=24 then begin                     { c'est shore.mvfm }
      BlockRead(FMmod,Vertex[1],3*4);             { lire 3 nombres réels }
      Vertex[4]:=0; Vertex[5]:=0; Vertex[6]:=0;   { donner la valeur 0 aux 3 nombres suivant }
      Blockread(FMmod,Vertex[7],2*4);             { lire les 2 derniers nombres }
      BlockWrite(FVertex,Vertex,8*4);             { écrire les 8 nombres réel }
     end;
 
     if LVertex=12 then begin { c'est position.mvfm }
      BlockRead(FMmod,Vertex[1],3*4);             { lire 3 nimbre réel }
      Vertex[4]:=0; Vertex[5]:=0; Vertex[6]:=0;   { donner la valeur 0 aux 5 nombres suivant }
      Vertex[7]:=0; Vertex[8]:=0;
      BlockWrite(FVertex,Vertex,8*4);             { écrire les 8 nombres réel }
     end;
 
      { se placer juste après le vertex }
     seek(FMmod,Pos+LVertex);
 
    end;
   end;
 
    { mettre à jour le nombre d'indexVertexStream }
   inc(NbIndexVertexStream);
 
  end
  else
  begin
 
    { le mot cle n'est pas 'VertexStream' }
   if KeyWord<>'' then begin
    Blockread(FMmod,LI,4);         { lire la longueur de la section }
    Seek(FMmod,FilePos(FMmod)+LI); { se placer au début de la section suivante }
   end;
 
  end;
 
 end;
 
 str(NbSubset,S);
 
 CurrentName:=Name+'_Subset_'+S;
 CanMatrix:=false;
 
 if IsModelBSP=false then begin
 
  if ItemNamesTracker2 < ItemNamesTracker then begin
   
   CurrentName:='NoName';
   
   while CurrentName='NoName' do begin
   
    CurrentName:=ItemNames[ItemNamesTracker2];
   
    ItemNamesTracker2:=ItemNamesTracker2+1;
    CanMatrix:=true;
	
	GlobalMatrixTracker:=GlobalMatrixTracker + 1;
	
   end;
   
  end;
 
 end;
 
 {*******************************************************************************}
 { 2eme étape : Mémoriser la position du début de la zone des valeurs 'Indices'  }
 {*******************************************************************************}
 
  { se placer au début de la section 'Mesh' }
 seek(FMmod,PosBeginMesh);
 
 while FilePos(FMmod)<PosEndMesh do begin
 
  KeyWord:=ReadKeyWord;                { lire le mot clef }
 
  if KeyWord='Indices' then begin
   ReadLI(8);
   IndicesType:=ReadLI(4);
   {Writeln('IndicesType: '+IntToStr(IndicesType));
   WriteLN(FRapport, 'IndicesType: '+IntToStr(IndicesType));}
   PosBeginIndices:=FilePos(FMmod);  { mémoriser la position du début de la section Indices }
   Break;                              { sortir de la boucle while }
  end
  else
  begin
 
    { le mot cle n'est pas 'Indices' }
   if KeyWord<>'' then begin
    Blockread(FMmod,LI,4);         { lire la longueur de la section }
    Seek(FMmod,FilePos(FMmod)+LI); { se placer au début de la section suivante }
   end;
 
  end;
 
 end;
 
 {********************************************************************************}
 { 3eme étape : retrouver tous les 'Subset' et créer le fichier OBJ correspondant }
 {********************************************************************************}
 
  { se placer au début de la section 'Mesh' }
 seek(FMmod,PosBeginMesh);
 
  { initialiser le fichier destination }
 assign(FOBJ,CurrentName+'.OBJ');
 Rewrite(FOBJ);
 assign(FMatLib,CurrentName+'.mtl');
 Rewrite(FMatLib);
 
  { afficher le fichier créé }
 Writeln('-- "'+CurrentName+'.OBJ" created --');
 Writeln('-- "'+CurrentName+'.mtl" created --');
 
 WriteLN(FOBJ,'# File created by MMOD Model Extractor v1.0 for Battlestations: Pacific');Flush(FOBJ);
 WriteLN(FOBJ);Flush(FOBJ);
 
 WriteLN(FOBJ,'mtllib '+CurrentName+'.mtl');Flush(FOBJ);
 WriteLN(FOBJ);Flush(FOBJ);
 
 LocalSubsetTracker:=0;
 GlobalSubsetTracker2:=0;
 GlobalSubsetSpecialTracker:=0;
 PassNextThrow:=false;
 
 while FilePos(FMmod)<PosEndMesh do begin
 
  KeyWord:=ReadKeyWord;              { lire le mot clef }
 
  if KeyWord='Subset' then begin
 
    { creer le fichier OBJ pour ce subset }
   TexTracker:=0;
   
    { mémoriser les posistions de début et de fin de subset }
   BlockRead(FMmod,LI,4);             { lit la longueur de la section }
   PosBeginSubset:=filePos(FMmod);    { mémorise la position du début de la section }
   PosEndSubset:=PosBeginSubset+LI;   { mémorise le début de la section suivante }
   
    { éjecter les 5 nombres suivant }
   BlockRead(FMmod,LI,4);
   BlockRead(FMmod,LI,4);
   BlockRead(FMmod,LI,4);
   BlockRead(FMmod,LI,4);
   BlockRead(FMmod,LI,4);
   
    { éjecter *.mshd }
   KeyWord:=ReadKeyWord;
   
   MSHD:=KeyWord;
   Textured:=false;
   HasBump:=false;
   
    { chercher 'VertexStreamIndex' et extraire sa valeur s'il existe, valeur par défaut = 0 }
   VertexStreamIndex:=0;
   
   while filepos(FMmod)<PosEndSubset do begin
    KeyWord:=ReadKeyWord;     { lire le mot clef }
 
    if KeyWord='VertexStreamIndex' then begin
     { VertexStreamIndex a été trouvé, lire sa valeur }
 
     BlockRead(FMmod,LI,4);                 { éjecter la longueur }
     BlockRead(FMmod,VertexStreamIndex,4);  { lire le nombre }
 	 
    end
    else
    begin
 	 
	 SetLength(TexFormatTable, 8);
     
     TexFormatTable[0]:='.dds';
     TexFormatTable[1]:='.DDS';
     TexFormatTable[2]:='.tga';
     TexFormatTable[3]:='.TGA';
     TexFormatTable[4]:='.jpg';
     TexFormatTable[5]:='.JPG';
     TexFormatTable[6]:='.png';
     TexFormatTable[7]:='.PNG';
	 
	 TexExt:=TexFormatTable[0];
	 
	 for int1:=1 to Length(TexFormatTable) do begin
      
	  TexIdx:=System.pos(TexFormatTable[int1-1],KeyWord);
	  
      if TexIdx > 0 then begin
       
	   TexExt:=TexFormatTable[int1-1];
	   
       break;
	  
      end;
     
     end;
	 
 	 if (KeyWord='Texture') or (TexIdx > 0) then begin
 	  
	  Textured:=true;
	  TexturedLocal:=false;
	  
	  if KeyWord='Texture' then begin
	  
 	   TexName:=ReadKeyWord;
 	    
	  end else if TexIdx > 0 then begin
	   
	   TexName:=KeyWord;
	   
	  end;
	   
	  Delete(TexName,1,4);
 	  Delete(TexName,(Length(TexName)-7),8);
	   
	  //Writeln(TexName);
	   
 	  if TexTracker = 0 then begin
 	   
	   FirstTexName:=TexName;
	   
 	   WriteLN(FMatLib,'newmtl '+TexName+' '+MSHD);Flush(FMatLib);
 	   WriteLN(FMatLib,'Kd 0.502 0.502 0.502');Flush(FMatLib);
 	   WriteLN(FMatLib,'Ks 0.25 0.25 0.25');Flush(FMatLib);
 	   WriteLN(FMatLib,'Ns 30');Flush(FMatLib);
 	   
 	   TexTxt:='map_Kd ';
 	   
	   TexturedLocal:=true;
	   
	  end else begin
 	   
	   int1:=System.pos('Bump',TexName);
	   
	   if int1 > 0 then begin
	   
	    if int1 = (Length(TexName) - 3) then  begin
		
		 TexTxt:='map_bump ';
		 
		 HasBump:=true;
		 TexturedLocal:=true;
		
		end;
	   
	   end;
	   
	   int1:=System.pos('bump',TexName);
	   
	   if int1 > 0 then begin
	   
	    if int1 = (Length(TexName) - 3) then  begin
		
		 TexTxt:='map_bump ';
		 
		 HasBump:=true;
		 TexturedLocal:=true;
		
		end;
	   
	   end;
	   
	   int1:=System.pos('_n',TexName);
	   
	   if int1 > 0 then begin
	   
	    if int1 = (Length(TexName) - 1) then  begin
		
		 TexTxt:='map_bump ';
		 
		 HasBump:=true;
		 TexturedLocal:=true;
		
		end;
	   
	   end;
	   
 	  end;
 	  
	  if CompareText('ship.mshd', MSHD) = 0 then begin
	  
	   if (TexTracker = 4) and (HasBump = false) then begin
	   
	    TexTxt:='map_bump ';
	    TexName:='Bump';
	    TexExt:='.dds';
		  
	    HasBump:=true;
	    TexturedLocal:=true;
	   
	   end;
	   
	  end else if CompareText('airplanerp.mshd', MSHD) = 0 then begin
	   
	   if (TexTracker = 2) and (HasBump = false) then begin
	   
	    TexTxt:='map_bump ';
	    TexName:='Bump';
	    TexExt:='.dds';
		  
	    HasBump:=true;
	    TexturedLocal:=true;
	   
	   end;
	   
	  end;
	   
	  if TexturedLocal = true then begin
	   
 	   WriteLN(FMatLib,TexTxt+TexturesPath+'\'+TexName+TexExt);Flush(FMatLib);
 	  
	  end;
	  
 	  TexTracker:=TexTracker+1;
 	  
 	 end;
 	 
      { le mot cle n'est pas 'VertexStreamIndex' }
     if KeyWord<>'' then begin
      Blockread(FMmod,LI,4);          { lire la longueur de la section }
      Seek(FMmod,FilePos(FMmod)+LI);  { se placer au début de la section suivante }
     end;
    end;
   end;
   
   if Textured=false then begin
    
 	str(NoTextureTracker,S);
 	
 	TexName:='untextured_'+S;
 	
	FirstTexName:=TexName;
	
	//WriteLN(FMatLib);Flush(FMatLib);
    WriteLN(FMatLib,'newmtl '+TexName+' '+MSHD);Flush(FMatLib);
 	WriteLN(FMatLib,'Kd 0.502 0.502 0.502');Flush(FMatLib);
 	WriteLN(FMatLib,'Ks 0.25 0.25 0.25');Flush(FMatLib);
 	WriteLN(FMatLib,'Ns 30');Flush(FMatLib);
	
 	NoTextureTracker:=NoTextureTracker+1;
 	
 	Textured:=true;
 	
   end;
   
   WriteLN(FMatLib);Flush(FMatLib);
   
    { se replacer dans le fichier source }
   seek(FMmod,PosBeginSubset);
   
   if GlobalSubsetTracker < Length(SubsetsTable) then begin
   
    if LocalSubsetTracker < SubsetsTable[GlobalSubsetTracker] then begin
     
      { lancer la construction du fichier OBJ pour ce subset }
     BuildSubset(CurrentName,PosBeginIndices,TVertexStreamIndex[VertexStreamIndex],IndicesType,FirstTexName, false, MSHD, LocalSubsetTracker);
     
 	 {str(LocalSubsetTracker,S);
 	 Writeln('Local '+S);
 	 str(SubsetsTable[GlobalSubsetTracker],S);
 	 Writeln('Global '+S);}
 	 
    end;
   
   end;
   
   LocalSubsetTracker:=LocalSubsetTracker+1;
   
   if GlobalSubsetTracker < Length(SubsetsTable) then begin
   
    if DoExtractLOD4 = true then begin
    
     if LODsTable[GlobalSubsetTracker]=4 then begin
     
      if LocalSubsetTracker = (SubsetsTable[GlobalSubsetTracker]*3)+1 then begin
     
 	    { lancer la construction du fichier OBJ pour ce subset }
       BuildSubset(CurrentName,PosBeginIndices,TVertexStreamIndex[VertexStreamIndex],IndicesType,FirstTexName, true, MSHD, LocalSubsetTracker);
 	  
 	  end;
 	  
     end;
    
    end;
	
   end;
   
    { se replacer dans le fichier source }
   seek(FMmod,PosEndSubset);
 
    { mettre à jour le nombre de Subset }
   inc(NbSubset);
 
  end
  else
  begin
 
    { le mot cle n'est pas 'Subset' }
   if KeyWord<>'' then begin
    Blockread(FMmod,LI,4);          { lire la longueur de la section }
    Seek(FMmod,FilePos(FMmod)+LI);  { se placer au début de la section suivante }
   end;
 
  end;
 
 end;
 
  { fermer le fichier destination }
 Close(FOBJ);
 Close(FMatLib);
 
 //if CanMatrix = true then begin
 
 // GlobalMatrixTracker:=GlobalMatrixTracker + 1;
 
 //end;
 
 {**********************************************************************************}
 { 4eme étape : retrouver la zone LODs et créer le fichier OBJ pour chaque LOD      }
 {**********************************************************************************}
 
  { se placer au début de la section 'Mesh' }
 seek(FMmod,PosBeginMesh);
 
 while FilePos(FMmod)<PosEndMesh do begin
 
  KeyWord:=ReadKeyWord;              { lire le mot clef }
 
  if KeyWord='LODPhases' then begin
    { la section LODPhases a été trouvée }
    { extraire chaque LOD et créer le fichier OBJ associé }
 
   BlockRead(FMmod,LI,4);                        { éjecter la longueur de la section }
   BlockRead(FMmod,NbLODPhases,4);               { lire le nombre de LODPhases }
   Blockread(FMmod,LI,4); BlockRead(FMmod,LI,4); { éjecter les 2 nombres suivant }
   for LI1:=1 to pred(NbLODPhases) do begin
    BlockRead(FMmod,FirstSubset,4);
    BlockRead(FMmod,LastSubset,4);
    BlockRead(FMmod,LI,4); BlockRead(FMmod,LI,4); { éjecter 2 nombres }
    {BuildLODPhase(Name,pred(LI1),FirstSubset,LastSubset);}
   end;
 
    { lire et creer le fichier du dernier LOD }
 
   BlockRead(FMmod,FirstSubset,4);
   BlockRead(FMmod,LastSubset,4);
   {BuildLODPhase(Name,Pred(NbLODPhases),FirstSubset, LastSubset);}
 
  end
  else
  begin
 
    { le mot cle n'est pas 'LODPhases' }
   if KeyWord<>'' then begin
    Blockread(FMmod,LI,4);          { lire la longueur de la section }
    Seek(FMmod,FilePos(FMmod)+LI);  { se placer au début de la section suivante }
   end;
 
  end;
 
 end;
 
 close(FVertex);
 Erase(FVertex);
 
  { se placer à la fin de la section 'Mesh' }
 seek(FMmod,PosEndMesh);
 
end;

 {*******************************************************************}
 { Lit la section Resource pour en extraire les sections 'Mesh'      }
 {*******************************************************************}

Procedure ReadResource(name : string);
var
 NbMesh : integer;
 PosEnd, PosEndAux,                { position de la fin de la section Resource }
 LI, LI1, LI2, LI3,
 IndicesTracker, IndicesTracker2     : longint;
 S, FilePosString,
 KeyWord, AuxName, AuxNumberTxt, AuxExt,
 AuxNameFinal       : string;
 AuxTracker, AuxNumber : longint;
 AuxNameArray       : array of char;
 IndicesArray       : array of integer;
 V1, V2, V3         : string;
 IsLine, Indent     : boolean;
begin
 BlockRead(FMmod,LI,4);            { lire la longueur de la section }
 PosEnd:=FilePos(FMmod)+LI;        { mémoriser la position de la fin de la section }
 NbMesh:=0;
 
 GlobalIndicesInc:=0;
 GlobalIndicesTracker:=0;
 IncIndicesYes:=false;
 
  { rechercher les 'Mesh' }
 while FilePos(FMmod)<PosEnd do begin
  KeyWord:=ReadKeyWord;
  
  if (KeyWord='Mesh') or (KeyWord='MatrixIndexedMesh') then begin
   
    { initialiser le nombre de Subset }
   NbSubset:=0;
   
    { lire le Mesh trouvé }
   str(NbMesh,S);
   ReadMesh(Name+'_Mesh_'+S);
   inc(NbMesh);
   
   GlobalSubsetTracker:=GlobalSubsetTracker+1;
   
   { SDC RIPPER START }
  end else if (KeyWord='Aux') then begin
   
   LI:=ReadLI(4);
   PosEndAux:=FilePos(FMmod)+LI;
   IsLine:=false;
   IndicesTracker2:=0;
   
   while FilePos(FMmod)<PosEndAux do begin
    
	if KeyWordFind('Identifier') then begin
	 
	 Seek(FMmod,FilePos(FMmod)+KeyWordIterations);
	 //str(FilePos(FMmod),FilePosString);
	 
	 ReadLI(4);
	 LI1:=ReadLI(4);
	 
	 SetLength(AuxNameArray, LI1);
	 
	 for LI2:=1 to LI1 do begin AuxNameArray[LI2-1]:=chr(ReadB); end;
	 
	 SetString(AuxName, PChar(@AuxNameArray[0]), Length(AuxNameArray));
	 
	 //Writeln('-- Found an SDC ('+AuxName+') at '+FilePosString+' --');
	 
	 AuxNumber:=ReadLI(4);
	 AuxNumberTxt:=StrLI(AuxNumber);
	 
	 if AuxNumber<10 then begin
	 
	  Delete(AuxNumberTxt,1,7);
	 
	 end else if AuxNumber<100 then begin
	 
	  Delete(AuxNumberTxt,1,6);
	  
	 end else if AuxNumber<1000 then begin
	 
	  Delete(AuxNumberTxt,1,5);
	  
	 end else if AuxNumber<10000 then begin
	 
	  Delete(AuxNumberTxt,1,4);
	  
	 end else if AuxNumber<100000 then begin
	 
	  Delete(AuxNumberTxt,1,3);
	  
	 end else begin
	 
	  Delete(AuxNumberTxt,1,2);
	 
	 end;
	 
	 ReadLI(4);
	 AuxExt:='';
	 
	 if KeyWordFind('Category') then begin
	 
	  Seek(FMmod,FilePos(FMmod)+KeyWordIterations);
	  
	  //Writeln('FOUND A CATEGORY!!!!!!!');
	  
	  ReadLI(4);
	  LI1:=ReadLI(4);
	  
	  SetLength(AuxNameArray, LI1);
	  
	  for LI2:=1 to LI1 do begin AuxNameArray[LI2-1]:=chr(ReadB); end;
	  
	  SetString(AuxExt, PChar(@AuxNameArray[0]), Length(AuxNameArray));
	 
	 end else begin
	 
	  AuxExt:=' 0';
	 
	 end;
	 
	 AuxNameFinal:='#'+AuxName+' '+AuxNumberTxt+'#';
	 
	 if CompareText(AuxName,'bottomline')=0 then begin
	 
	  AuxNameFinal:='#'+AuxName;
	  IsLine:=true;
	  
	 end;
	 if CompareText(AuxName,'deckline')=0 then begin
	 
	  AuxNameFinal:='#'+AuxName;
	  IsLine:=true;
	 
	 end;
	 if CompareText(AuxName,'wave')=0 then begin
	 
	  AuxNameFinal:='#'+AuxName+'#';
	  
	  if IsPlane = false then begin
	  
	   IsLine:=true;
	   
	  end;
	 
	 end;
	 if CompareText(AuxName,'wave_stern')=0 then begin
	 
	  AuxNameFinal:='#'+AuxName+'#';
	  IsLine:=true;
	 
	 end;
	 if CompareText(AuxName,'wave_tower')=0 then begin
	 
	  AuxNameFinal:='#'+AuxName+'#';
	  IsLine:=true;
	 
	 end;
	 if CompareText(AuxName,'explosion')=0 then begin
	  
	  AuxNameFinal:='#'+AuxName+' '+AuxExt;
	 
	 end;
	 if CompareText(AuxName,'fire')=0 then begin
	  
	  if IsGun = false then begin
	  
	   AuxNameFinal:='#'+AuxName;
	  
	  end;
	  
	 end;
	 if CompareText(AuxName,'path')=0 then begin
	  
	  IsLine:=true;
	 
	 end;
	 if CompareText(AuxName,'sight')=0 then begin
	  
	  AuxNameFinal:='#'+AuxName+'#';
	  
	 end;
	 if CompareText(AuxName,'cockpitview')=0 then begin
	  
	  AuxNameFinal:='#'+AuxName+'#';
	  
	 end;
	 if CompareText(AuxName,'shipcenter')=0 then begin
	  
	  AuxNameFinal:='#'+AuxName+'#';
	  
	 end;
	 if CompareText(AuxName,'runwaycenter')=0 then begin
	  
	  AuxNameFinal:='#'+AuxName+'#';
	  
	 end;
	 
     WriteLN(FSDCObj,'# ---- SDC OBJECT START ----');Flush(FSDCObj);
     WriteLN(FSDCObj);Flush(FSDCObj);
	 
	 V1:='0';
	 V2:='0';
	 V3:='0';
	 
	 if CompareText(AuxName,'camera')=0 then begin
	 
	  V1:='0';
	  V2:='0';
	  V3:='1';
	 
	 end else if CompareText(AuxName,'wave_stern')=0 then begin
	 
	  V1:='0.784314';
	  V2:='0.784314';
	  V3:='0.784314';
	 
	 end else if CompareText(AuxName,'slot')=0 then begin
	 
	  V1:='1';
	  V2:='0.501961';
	  V3:='0';
	 
	 end else if CompareText(AuxName,'explosion')=0 then begin
	 
	  V1:='0.682353';
	  V2:='0.529412';
	  V3:='0';
	 
	 end else if CompareText(AuxName,'bottomline')=0 then begin
	 
	  V1:='0.784314';
	  V2:='0.784314';
	  V3:='0.784314';
	 
	 end else if CompareText(AuxName,'deckline')=0 then begin
	 
	  V1:='0.784314';
	  V2:='0.784314';
	  V3:='0.784314';
	
	 end else if CompareText(AuxName,'liftexitpoint')=0 then begin
	 
	  V1:='0.501961';
	  V2:='0';
	  V3:='1';
	
	 end else if CompareText(AuxName,'wave')=0 then begin
	  
	  if IsPlane = false then begin
	  
	   V1:='0.784314';
	   V2:='0.784314';
	   V3:='0.784314';
	   
	  end else begin
	  
	   V1:='0.501961';
	   V2:='0';
	   V3:='0.25098';
	   
	  end;
	
	 end else if CompareText(AuxName,'zaszlo')=0 then begin
	 
	  V1:='1';
	  V2:='0';
	  V3:='0.431373';
	
	 end else if CompareText(AuxName,'farviz')=0 then begin
	 
	  V1:='0.443137';
	  V2:='0.823529';
	  V3:='0.909804';
	
	 end else if CompareText(AuxName,'fire')=0 then begin
	  
	  if IsGun = false then begin
	  
	   V1:='1';
	   V2:='0';
	   V3:='0';
	   
	  end else begin
	  
	   V1:='1';
	   V2:='0.501961';
	   V3:='0';
	  
	  end;
	
	 end else if CompareText(AuxName,'orrhullam')=0 then begin
	 
	  V1:='0.443137';
	  V2:='0.823529';
	  V3:='0.909804';
	
	 end else if CompareText(AuxName,'shipcenter')=0 then begin
	 
	  V1:='0.94902';
	  V2:='0';
	  V3:='0.905882';
	 
	 end else if CompareText(AuxName,'runwaycenter')=0 then begin
	 
	  V1:='0.501961';
	  V2:='0.501961';
	  V3:='0';
	 
	 end else if CompareText(AuxName,'kemeny')=0 then begin
	 
	  V1:='1';
	  V2:='0.501961';
	  V3:='1';
	
	 end else if CompareText(AuxName,'path')=0 then begin
	 
	  V1:='1';
	  V2:='1';
	  V3:='1';
	
	 end else if CompareText(AuxName,'idle')=0 then begin
	 
	  V1:='1';
	  V2:='0.501961';
	  V3:='0.501961';
	
	 end else if CompareText(AuxName,'cockpitview')=0 then begin
	 
	  V1:='0';
	  V2:='0.529412';
	  V3:='0.878431';
	
	 end else if CompareText(AuxName,'collipos')=0 then begin
	 
	  V1:='0.501961';
	  V2:='0.501961';
	  V3:='0.501961';
	 
	 end else if CompareText(AuxName,'enginefire')=0 then begin
	 
	  V1:='1';
	  V2:='0';
	  V3:='0';
	 
	 end else if CompareText(AuxName,'groundpoint')=0 then begin
	 
	  V1:='1';
	  V2:='0.501961';
	  V3:='0.752941';
	
	 end else if CompareText(AuxName,'sight')=0 then begin
	 
	  V1:='0';
	  V2:='0';
	  V3:='1';
	
	 end else if CompareText(AuxName,'wingtip')=0 then begin
	 
	  V1:='0.501961';
	  V2:='0.501961';
	  V3:='0';
	  
	 end else if CompareText(AuxName,'shell')=0 then begin
	 
	  V1:='0.752941';
	  V2:='0.752941';
	  V3:='0.752941';
	  
	 end;
	 
	 WriteLN(FSDCMatLib,'newmtl '+AuxNameFinal);Flush(FSDCMatLib);
     WriteLN(FSDCMatLib,'Kd '+V1+' '+V2+' '+V3);Flush(FSDCMatLib);
     WriteLN(FSDCMatLib,'Ks 0 0 0');Flush(FSDCMatLib);
     WriteLN(FSDCMatLib,'Ns 400');Flush(FSDCMatLib);
     WriteLN(FSDCMatLib);Flush(FSDCMatLib);
	 
	 IndicesTracker:=0;
	 
	end else if KeyWordFind('Points') then begin
	
	 Seek(FMmod,FilePos(FMmod)+KeyWordIterations);
	 
	 //Writeln('Points: ');
	 
	 LI1:=ReadLI(4);
	 
	 //if IsLine=true then begin
	 
	 // LI1:=LI1 div 12;
	 
	 //end else begin
	 
	  LI1:=LI1 div 12;
	 
	 //end;
	 
	 if IsLine = false then begin
	 
	  if LI1 > 3 then begin
	  
	   LI1:=3;
	  
	  end;
	 
	 end;
	 
	 SetLength(IndicesArray, LI1);
	 
	 for LI2:=1 to LI1 do begin
	  
	  Write(FSDCObj,'v ');Flush(FSDCObj);
	  
	  if FlipModel = true then begin
	   
	   V1:=StrR(ReadR);
	   V2:=StrR(ReadR);
	   V3:=StrR(-(ReadR));
	  
	  end else begin
	   
	   V1:=StrR(-(ReadR));
	   V2:=StrR(ReadR);
	   V3:=StrR(ReadR);
	  
	  end;
	  
	  //Delete(V1,1,4);
	  //Delete(V2,1,4);
	  //Delete(V3,1,4);
	  
      Write(FSDCObj,V1+' ');Flush(FSDCObj);Write(FSDCObj,V2+' ');Flush(FSDCObj);Write(FSDCObj,V3);Flush(FSDCObj);
	  
	  IndicesArray[IndicesTracker]:=IndicesTrackerGlobal+1;
	  IndicesTracker:=IndicesTracker+1;
	  IndicesTrackerGlobal:=IndicesTrackerGlobal+1;
	  
	  WriteLN(FSDCObj);Flush(FSDCObj);
	  
     end;
	 
	 //for LI2:=1 to LI1 do begin
	 
	  //WriteLN(FSDCObj, 'vn 0 -1 -0');
	  
	 //end;
	 
	 WriteLN(FSDCObj);Flush(FSDCObj);
	 WriteLN(FSDCObj,'g '+AuxNameFinal);Flush(FSDCObj);
     WriteLN(FSDCObj,'usemtl '+AuxNameFinal);Flush(FSDCObj);
	 WriteLN(FSDCObj,'s off');Flush(FSDCObj);
	 
	 IndicesTracker:=0;
	 LI3:=Length(IndicesArray);
	 
	 if IsLine=true then begin
	 
	  LI3:=Length(IndicesArray)*2;
	 
	 end;
	 
	 if IsLine = false then begin
	 
	  if LI3 > 3 then begin
	  
	   LI3:=3;
	  
	  end;
	 
	 end;
	 
	 for LI2:=1 to LI3 do begin
	  
	  if IsLine=true then begin
	  
	   if IndicesTracker=0 then begin
	    
		if LI2=LI3 then begin
		
		 WriteLN(FSDCObj);Flush(FSDCObj);
		 
		 break;
		
		end;
		
		if IndicesTracker2=0 and (LI3 mod 2) then begin
		
		 Write(FSDCObj,'p ');Flush(FSDCObj);
		 
		 Indent:=true;
		 
		end else begin
		
		 Write(FSDCObj,'l ');Flush(FSDCObj);
		 
		 IndicesTracker:=IndicesTracker+1;
		 
		 Indent:=false;
		 
		end;
		
		IndicesTracker2:=IndicesTracker2+1;
		
	    str(IndicesArray[LI2-(1*IndicesTracker2)],S);
	    Write(FSDCObj,S+'/');Flush(FSDCObj);Write(FSDCObj,S+'/');Flush(FSDCObj);
	    
		//if LI2=LI3 then begin WriteLN(FSDCObj);Flush(FSDCObj); end;
		
		if Indent=true then begin
		
		 WriteLN(FSDCObj,S+' ');Flush(FSDCObj);
		
		end else begin
		
		 Write(FSDCObj,S+' ');Flush(FSDCObj);
		 
		end;
		
	   end else if IndicesTracker=1 then begin
	    
	    str(IndicesArray[LI2-(1*IndicesTracker2)],S);
	    Write(FSDCObj,S+'/');Flush(FSDCObj);Write(FSDCObj,S+'/');Flush(FSDCObj);WriteLN(FSDCObj,S+' ');Flush(FSDCObj);
	    
	    IndicesTracker:=0;
	    
	   end;
	  
	  end else begin
	   
	   if FlipModel = true then begin
	    
		//str(IndicesTracker,S);
		//Writeln(S);
		//str(Length(IndicesArray),S);
		//Writeln(S);
		
	    if IndicesTracker=0 then begin
	     
		 //if (LI2 + 3) < Length(IndicesArray) then begin
		 
	      Write(FSDCObj,'f ');Flush(FSDCObj);
	     
	      str(IndicesArray[LI2+1],S);
	      Write(FSDCObj,S+'/');Flush(FSDCObj);Write(FSDCObj,S+'/');Flush(FSDCObj);Write(FSDCObj,S+' ');Flush(FSDCObj);
	     
		 //end;
		 
	     IndicesTracker:=IndicesTracker+1;
	     
	    end else if IndicesTracker=2 then begin
	     
	     str(IndicesArray[LI2-3],S);
	     Write(FSDCObj,S+'/');Flush(FSDCObj);Write(FSDCObj,S+'/');Flush(FSDCObj);WriteLN(FSDCObj,S);Flush(FSDCObj);
	     
	     IndicesTracker:=0;
	    
	    end else begin
	    
	     str(IndicesArray[LI2-1],S);
	     Write(FSDCObj,S+'/');Flush(FSDCObj);Write(FSDCObj,S+'/');Flush(FSDCObj);Write(FSDCObj,S+' ');Flush(FSDCObj);
	     
	     IndicesTracker:=IndicesTracker+1;
	     
	    end;
		
	   end else begin
	   
	    if IndicesTracker=0 then begin
	     
	     Write(FSDCObj,'f ');Flush(FSDCObj);
	     
	     str(IndicesArray[LI2-1],S);
	     Write(FSDCObj,S+'/');Flush(FSDCObj);Write(FSDCObj,S+'/');Flush(FSDCObj);Write(FSDCObj,S+' ');Flush(FSDCObj);
	     
	     IndicesTracker:=IndicesTracker+1;
	     
	    end else if IndicesTracker=2 then begin
	     
	     str(IndicesArray[LI2-1],S);
	     Write(FSDCObj,S+'/');Flush(FSDCObj);Write(FSDCObj,S+'/');Flush(FSDCObj);WriteLN(FSDCObj,S);Flush(FSDCObj);
	     
	     IndicesTracker:=0;
	    
	    end else begin
	    
	     str(IndicesArray[LI2-1],S);
	     Write(FSDCObj,S+'/');Flush(FSDCObj);Write(FSDCObj,S+'/');Flush(FSDCObj);Write(FSDCObj,S+' ');Flush(FSDCObj);
	     
	     IndicesTracker:=IndicesTracker+1;
	     
	    end;
		
	   end;
	   
	  end;
	 
	 if LI2=LI3 then begin WriteLN(FSDCObj);Flush(FSDCObj); end;
	 
	 end;
	 
	 WriteLN(FSDCObj,'# ---- SDC OBJECT END ----');Flush(FSDCObj);
     WriteLN(FSDCObj);Flush(FSDCObj);
	 
	// WriteLN(FSDCObj);
	 
	end else begin
	
	 Seek(FMmod,FilePos(FMmod)+1);
	 
	end;
	
   end;
   
  end
   { SDC RIPPER END }
  
  else
  begin
   
    { le mot clef n'est pas 'Mesh' ni 'MatrixIndexedMesh' }
   if KeyWord<>'' then begin
    Blockread(FMmod,LI,4);         { lire la longueur de la section }
    Seek(FMmod,FilePos(FMmod)+LI); { se placer au début de la section suivante }
   end;

  end;
 end;
end;

 {*******************************************************************}
 { Lit le fichier Mmod trouvé pour en extraire la section 'Resource' }
 {*******************************************************************}

Procedure ExtractMmod(Name : string);
var
 keyword, ItemName, S : string;
 LI, StartingPos, GoToPos, GoToPos2, LI1, LI2, RemoveIdx, RemoveIdx2, SubsetTracker, LODNum, ResourceCounter : longint;
 NeedName, NeedToInc, PassedMesh, NeedResourceCounter : boolean;
 TempTable      : array of char;
 ResourceTrackers : array[0..100] of longint;
 RootHere, HasPlacedLOD : boolean;
begin

 if ReadKeyWord = 'MMOD' then begin

   { éjecter les deux nombres suivants }
  BlockRead(FMmod,LI,4);
  BlockRead(FMmod,LI,4);
  
  StartingPos:=FilePos(FMmod);
  
  assign(FSDCObj,name+'_SDC.OBJ');
  Rewrite(FSDCObj);
  assign(FSDCMatLib,name+'_SDC.mtl');
  Rewrite(FSDCMatLib);
  
  Writeln('-- "'+name+'_SDC.OBJ" created --');
  Writeln('-- "'+name+'_SDC.mtl" created --');
  
  WriteLN(FSDCObj,'# File created by MMOD Model Extractor v1.0 for Battlestations: Pacific');Flush(FSDCObj);
  WriteLN(FSDCObj);Flush(FSDCObj);
  
  WriteLN(FSDCObj,'mtllib '+name+'_SDC.mtl');Flush(FSDCObj);
  WriteLN(FSDCObj);Flush(FSDCObj);
  
  IndicesTrackerGlobal:=0;
  ItemNamesTracker:=0;
  ItemNamesTracker2:=0;
  GlobalSubsetTracker:=0;
  NoTextureTracker:=0;
  GlobalMatrixTracker:=0;
  IsModelBSP:=false;
  
   { MESH NAMING START }
   
  Repeat
   
   KeyWord:=ReadKeyWord;

   if KeyWord='Hierarchy' then begin
     
	 for LI2:=1 to Length(ResourceTrackers) do begin ResourceTrackers[LI2-1]:=-1; end;
	 
     GoToPos:=ReadLI(4)+FilePos(FMmod);
	 ReadLI(4);
	 
	 ResourceCounter:=0;
	 
	 while FilePos(FMmod)<GoToPos do begin
	 
	  if KeyWordFind('Item') then begin 
	   
	   NeedResourceCounter:=true;
	   
	   //NeedName:=true;
	   
	   Seek(FMmod,FilePos(FMmod)+KeyWordIterations);
	   
	   GoToPos2:=ReadLI(4)+FilePos(FMmod);
	   ReadLI(4);
	   
	   RootHere:=false;
	   
	   while FilePos(FMmod)<GoToPos2 do begin
	   
	    if KeyWordFind('Name') then begin 
		 
		 Seek(FMmod,FilePos(FMmod)+KeyWordIterations);
		 
		 ReadLI(4);
		 LI1:=ReadLI(4);
		 
		 SetLength(TempTable, LI1);
		 
		 for LI2:=1 to LI1 do begin TempTable[LI2-1]:=chr(ReadB); end;
		 
		 SetString(ItemName, PChar(@TempTable[0]), Length(TempTable));
		 
		 RemoveIdx:=System.pos(':',ItemName);
		 
		 if RemoveIdx > 0 then begin
		  
		  //Delete(ItemName, 1, RemoveIdx);
		  
		  Delete(ItemName, RemoveIdx, 1);
		  Insert('_', ItemName, RemoveIdx);
		  
		 end;
		 
		 {RemoveIdx:=System.pos('(Complete)',ItemName);
		 
		 if RemoveIdx>0 then begin
		  
		  Delete(ItemName, RemoveIdx, Length('(Complete)'));
		  
		 end;
		 
		 RemoveIdx:=System.pos('(complete)',ItemName);
		 
		 if RemoveIdx>0 then begin
		  
		  Delete(ItemName, RemoveIdx, Length('(complete)'));
		  
		 end;
		 
		 RemoveIdx:=System.pos('_Complete',ItemName);
		 
		 if RemoveIdx>0 then begin
		  
		  Delete(ItemName, RemoveIdx, Length('_Complete'));
		  
		 end;
		 
		 RemoveIdx:=System.pos('_complete',ItemName);
		 
		 if RemoveIdx>0 then begin
		  
		  Delete(ItemName, RemoveIdx, Length('_complete'));
		  
		 end;}
		 
		 if (System.pos('GroupRoot',ItemName) > 0) or (System.pos('Null',ItemName) > 0) or (System.pos('null',ItemName) > 0) then begin
		 
		  //Delete(ItemName,1,10);
		 
		  RootHere:=true;
		 
		 end else begin
		  
		  SetLength(ItemNames, Length(ItemNames) + 1);
		  
		  ItemNames[ItemNamesTracker]:=ItemName;
		  
		  ItemNamesTracker:=ItemNamesTracker+1;
		  
		  //Writeln(ItemNames[ItemNamesTracker-1]);
		  
		 end;
		 
		 //NeedName:=false;
		 
		end else if KeyWordFind('Matrix') then begin 
		 
		 Seek(FMmod,FilePos(FMmod)+KeyWordIterations);
		 
		 LI1:=(FilePos(FMmod)+ReadLI(4));
		 
		 if RootHere = false then begin
		 
		  ReadR();ReadR();ReadR();ReadR();
		  ReadR();ReadR();ReadR();ReadR(); //ROTATION VALUES NOT SUPPORTED!
		  ReadR();ReadR();ReadR();ReadR();
		  
		  SetLength(MatrixMoveXList, Length(MatrixMoveXList) + 1);
		  SetLength(MatrixMoveYList, Length(MatrixMoveYList) + 1);
		  SetLength(MatrixMoveZList, Length(MatrixMoveZList) + 1);
		  
		  MatrixMoveXList[ItemNamesTracker - 1]:=ReadR();
		  MatrixMoveYList[ItemNamesTracker - 1]:=ReadR();
		  MatrixMoveZList[ItemNamesTracker - 1]:=ReadR();
		  
		 end;
		 
		 Seek(FMmod,LI1);
		
		end else if KeyWordFind('Resource') then begin 
		 
		 Seek(FMmod,FilePos(FMmod)+KeyWordIterations);
		 
		 LI:=ReadLI(4);
		 LI1:=ReadLI(4);
		 
		 //str(LI1,S);
		 //Writeln(S);
		 //Writeln;
		 
		 if NeedResourceCounter=true then begin
		 
		  ResourceTrackers[ResourceCounter]:=LI1;
		  
		  NeedResourceCounter:=false;
		  ResourceCounter:=ResourceCounter+1;
		  
		 end;
		 
		 Seek(FMmod,FilePos(FMmod)+LI);
		
		end else begin
		
		 Seek(FMmod,FilePos(FMmod)+1);
		
		end;
		
	   end;
	   
	  end else begin
	  
	   Seek(FMmod,FilePos(FMmod)+1);
	   
	  end;
	 
	 end;
	 
	 for LI2:=1 to Length(ResourceTrackers) do begin 
	  
	  if ResourceTrackers[LI2-1]=-1 then begin
	   
	   break;
	  
	  end;
	  
	  for LI:=LI2 to Length(ResourceTrackers) do begin 
	   
	   if (LI2-1)<>(LI-1) then begin
	   
	    if ResourceTrackers[LI2-1]=ResourceTrackers[LI-1] then begin
	    
	     ItemNames[LI2-1]:='NoName';
	     
		 break;
		 
	    end;
	   
	   end;
	   
	  end;
	  
	 end;
	 
	 //SetLength(ResourceTrackers, ResourceCounter);
	 
   end
   else
   begin

    if KeyWord<>'' then begin

     BlockRead(FMmod,LI,4);
     Seek(FMmod,FilePos(FMmod)+LI);
	 
    end;
	
   end;
   
  until KeyWord='';
  
  {for LI2:=1 to (ItemNamesTracker-1) do begin 
   
   Writeln(ItemNames[LI2-1]);
   
  end;
  
  Writeln;}
  
   { MESH NAMING END }
  
  Seek(FMmod,StartingPos);
  
   { LOD CUTTING START }
 
  LODsPassed:=-1;
  PassedMesh:=false;
  //SetLength(LODsTable, ItemNamesTracker-1);
  //SetLength(SubsetsTable, ItemNamesTracker-1);
   
  Repeat
    
	if KeyWordFind('Hierarchy') then begin
	 
	 break;
	
	end;
	
	NeedToInc:=true;
	
    if KeyWordFind('Resource') then begin NeedToInc:=false;
	
	 Seek(FMmod,FilePos(FMmod)+KeyWordIterations);
	
     //GoToPos:=FilePos(FMmod)+ReadLI(4);
	 
	 //ReadLI(4);
	 
	 //Writeln('INSIDE RESOURCE!!!!!!!!!!');
	 
	end;
	
	if KeyWordFind('Mesh') or KeyWordFind('MatrixIndexedMesh') or KeyWordFind('SkinedMesh') then begin NeedToInc:=false;
	 
	 Seek(FMmod,FilePos(FMmod)+KeyWordIterations);
	 
	 //ReadLI(4);
	 //ReadLI(4);
	 //ReadLI(4);
	   
	 //Writeln('INSIDE MESH!!!!!!!!!!');
	 
	 LODsPassed:=LODsPassed+1;
	 SetLength(LODsTable, Length(LODsTable) + 1);
	 LODsTable[LODsPassed]:=-1;
	 SetLength(SubsetsTable, Length(SubsetsTable) + 1);
	 SubsetsTable[LODsPassed]:=SubsetTracker;
	 SubsetTracker:=0;
	 
	end; 
	
	if KeyWordFind('VertexStream') or KeyWordFind('CompressedVertexFormatData') then begin NeedToInc:=false;
	 
	 //str(FilePos(FMmod),S);
	 //Writeln(S);
	 
	 Seek(FMmod,FilePos(FMmod)+KeyWordIterations);
	 
	 GoToPos2:=ReadLI(4);
	 
	 //Writeln('PASSED VERTEX!!!!!!!!!!');
	 
	 Seek(FMmod,FilePos(FMmod)+GoToPos2);
	 
	 //str(FilePos(FMmod),S);
	 //Writeln(S);
	 
	end; 
	
	if KeyWordFind('Indices') then begin NeedToInc:=false;
	 
	 //str(FilePos(FMmod),S);
	 //Writeln(S);
	 
	 Seek(FMmod,FilePos(FMmod)+KeyWordIterations);
	 
	 GoToPos2:=ReadLI(4);
	 
	 //Writeln('PASSED INDICES!!!!!!!!!!');
	 
	 Seek(FMmod,FilePos(FMmod)+GoToPos2);
	 
	 //str(FilePos(FMmod),S);
	 //Writeln(S);
	 
	end; 
	
	if KeyWordFind('Subset') then begin NeedToInc:=false;
	 
	 //str(FilePos(FMmod),S);
	 //Writeln(S);
	 
	 Seek(FMmod,FilePos(FMmod)+KeyWordIterations);
	 
	 GoToPos2:=ReadLI(4);
	 
	 //Writeln('PASSED SUBSET!!!!!!!!!!');
	 
	 Seek(FMmod,FilePos(FMmod)+GoToPos2);
	 
	 //str(FilePos(FMmod),S);
	 //Writeln(S);
	 
	 SubsetTracker:=SubsetTracker+1;
	 
	end; 
	
	if KeyWordFind('GeomMesh') then begin NeedToInc:=false;
	 
	 //str(FilePos(FMmod),S);
	 //Writeln(S);
	 
	 Seek(FMmod,FilePos(FMmod)+KeyWordIterations);
	 
	 GoToPos2:=ReadLI(4);
	 
	 //Writeln('PASSED GEOMMESH!!!!!!!!!!');
	 
	 Seek(FMmod,FilePos(FMmod)+GoToPos2);
	 
	 //str(FilePos(FMmod),S);
	 //Writeln(S);
	 
	end;
	
	if KeyWordFind('ConvexObject') then begin NeedToInc:=false;
	 
	 //str(FilePos(FMmod),S);
	 //Writeln(S);
	 
	 Seek(FMmod,FilePos(FMmod)+KeyWordIterations);
	 
	 GoToPos2:=ReadLI(4);
	 
	 //Writeln('PASSED CONVEXOBJECT!!!!!!!!!!');
	 
	 Seek(FMmod,FilePos(FMmod)+GoToPos2);
	 
	 //str(FilePos(FMmod),S);
	 //Writeln(S);
	 
	end;
	
	if KeyWordFind('LODPhases') then begin NeedToInc:=false;
	 
	 Seek(FMmod,FilePos(FMmod)+KeyWordIterations);
	 
	 //Writeln('PASSED LOD PHASES!!!!!!');
	 
	 ReadLI(4);
	 LODNum:=ReadLI(4);
	 
	 LODsTable[LODsPassed]:=LODNum;
	 
	 if LODNum=4 then begin
	  
	  SubsetTracker:=SubsetTracker-1;
	  LODNum:=LODNum-1;
	  
	 end;
	 
	 SubsetsTable[LODsPassed]:=SubsetTracker div LODNum;
	 
	end;
	
	if KeyWordFind('SceneError') then begin
	 
	 str(FilePos(FMmod),S);
	 
	 Writeln;
     Writeln('********************************************');
     Writeln('*    SCENE ERROR ENCOUNTERED AT '+S+'!   *');
     Writeln('********************************************');
     Writeln;
     writeln('Press "ENTER" to exit.');
     ReadLN;
     halt;
	
	end;
	
	if NeedToInc=true then begin
	
	 Seek(FMmod,FilePos(FMmod)+1);
	
	end;
	
  until LODsPassed=ItemNamesTracker;
  
   { LOD CUTTING END }
  
  //Writeln('FINISHED!!!!!!');
  
  {for LI:=1 to Length(LODsTable) do begin
  
   str(LODsTable[LI-1],S);
   Writeln(S);
  
  end;
  Writeln;
  for LI:=1 to Length(SubsetsTable) do begin
  
   str(SubsetsTable[LI-1],S);
   Writeln(S);
  
  end;}
  
  Seek(FMmod,StartingPos);
  
   { Trouver 'Resource' }
  Repeat
   
    { lire le mot clef }
   KeyWord:=ReadKeyWord;

   if KeyWord='Resource' then begin

      { Resource a été trouvé }
     ReadResource(Name);

     { quitter la procédure }
    exit;
    
   end
   else
   begin

     { ce n'est pas Resource }
    if KeyWord<>'' then begin

      { il y a bien un mot clef - lire la longueur du block et se repositionner à la fin de celui-ci }
     BlockRead(FMmod,LI,4);
     Seek(FMmod,FilePos(FMmod)+LI);
    end;
   end;
  until KeyWord='';
  
  Close(FSDCObj);
  Close(FSDCMatLib);
  
  end
 else
 begin
  Writeln(' ================== This file is not in MMOD format  ================ ');
  ReadLN;
  halt;
 end;
end;

{*********************************************************************************}
{ Trouve tous les fichier MMOD un par un et lance la conversion pour chacun d'eux }
{*********************************************************************************}

Procedure ExtractAllMmod;
var
 F : SearchRec;                  { variable de fichier pour la recherche des fichier dans le répertoire courant }
 w : word;
 S,
 NameF : string;                 { stockage provisoir d'un nom de fichier }
 i,
 NbFile : integer;               { nombre de fichiers converstis }
 B : byte absolute NameF;        { pointe sur la longueur de NameF }
begin
 FindFirst('*.MMOD',W,F);              { Trouver le 1er fichier .TXM }
 NbFile:=0;                            { initialiser le nombre de fichiers }
 AskedSettings:=false;
 KeepSettings:=false;
 
  { assigner le fichier RAPPORT }
 assign(FRapport,'RAPPORT.TXT');
 
 WriteLN('MMOD Model Extractor v1.0');
 WriteLN;
 
 TexturesPath:='textures';
 
 if FileExists('TexturePath.TXT') then begin
 
  assign(FPath,'TexturePath.TXT');
  Reset(FPath);
  
  ReadLN(FPath, TexturesPath);
  
  WriteLN('Path for textures found from the "TexturePath.txt" file:');
  
  close(FPath);
 
 end else begin
 
  WriteLN('Path for textures defaulted to:');
 
 end;
 
 WriteLN('"'+TexturesPath+'"');
 WriteLN;
 
 while DosError=0 do begin             { si le fichier existe, continuer }

   { contruire une chaine de caractère comportant le nom du fichier .TXM trouvé }
  NameF:=F.Name;

   { vérifier l'extension de fichier }
  if StrMajuscule(RightStr(NameF,5)) = '.MMOD' then begin
   
    { afficher le nom de fichier source }
   WriteLN;
   WriteLN('----------------------------------------------------------------');
   WriteLN('Found "'+NameF+'", extracting the model parts...');
   
    { USER PROMPTS START }
   
   if KeepSettings = false then begin
    
	WriteLN;
	WriteLN;
	
    IsPlane:=false;
    
    Writeln('Is this model an aircraft? (is the "wave" SDC slot a face?) (Enter "Y" for Yes, or anything else for No)');
    
    Readln(S);
    
    if (CompareText(S,'y')=0) or (CompareText(S,'Y')=0) then begin
	 
     IsPlane:=true;
	 
    end;
    
    IsGun:=false;
    
    Writeln('Is this model a gun/weapon? (are the "fire" SDC slots numbered?)');
    
    Readln(S);
    
    if (CompareText(S,'y')=0) or (CompareText(S,'Y')=0) then begin
	 
     IsGun:=true;
	 
    end;
    
    DoExtractLOD4:=false;
    
    Writeln('Do you want the LOD4 mesh parts extracted, if this model has them?');
    
    Readln(S);
    
    if (CompareText(S,'y')=0) or (CompareText(S,'Y')=0) then begin
	  
     DoExtractLOD4:=true;
	  
    end;
    
    FlipModel:=true;
    
    {Writeln('Do you want the mesh flipped along the axis of importation? (this may cause rendering issues in Lightwave?)');
    
    Readln(S);
    
    if (CompareText(S,'y')=0) or (CompareText(S,'Y')=0) then begin
	 
     FlipModel:=true;
	 
    end;}
    
   end;
   
   if AskedSettings = false then begin
   
    Writeln('Do you wish to keep the settings above for all "MMOD" files in this folder?');
    
    Readln(S);
    
    if (CompareText(S,'y')=0) or (CompareText(S,'Y')=0) then begin
	   
     KeepSettings:=true;
	   
    end;
    
	AskedSettings:=true;
	
   end;
   
   Writeln;
   WriteLN('-----------------------------');
   WriteLN('---- STARTING CONVERSION ----');
   WriteLN('-----------------------------');
   WriteLN;
   
    { USER PROMPTS END }
   
    { assigner le fichier source }
   assign(FMmod,NameF);
   
    { construire le nom du fichier de destination }
   dec(B,5);                { retirer les 4 derniers caractères - l'extension + le point }

    {Initialiser les fichier}
   Reset(FMmod,1);
   Rewrite(FRapport);

    { ecrire l'entete dans le fichier rapport }
   WriteLN(FRapport,'Fichier converti : '+NameF+'.MMOD');
   WriteLN(FRapport);
   
   GlobalName:=NameF;
   
   inc(NbFile);                    { + 1 fichier }

    { Creer les fichiers OBJ à partir du fichier TXM }
   ExtractMmod(NameF);
   
   writeLN;
   writeLN('...completed!');
   WriteLN('----------------------------------------------------------------');
   WriteLN;
   
    {fermer les fichiers }
   close(FMmod);
   close(FRapport);
   erase(FRapport);

  end;

   { rechercher le fichier suivant }
  FindNext(F);
 end;
 
  { affichage pour information de l'utilisateur }
 WriteLN;

 if NbFile=0 then
  WriteLN('NO MMOD FILE FOUND!')
 else
  if NbFile=1 then WriteLN('1 file succesfully converted.')
   else WriteLN(NbFile,' files successfully converted.');

 WriteLN('Press "ENTER" to exit.');
 ReadLN;

end;

begin
 ExtractAllMmod;
end.

