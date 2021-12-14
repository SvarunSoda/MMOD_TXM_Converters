unit TXMCommand;

interface

uses
  dos, StrUtils, TXMUtils, TXMVar ;

Procedure Command(var STXM : string);


implementation

type
 T_Subset =                record
                                 FirstVertex,
                                 NbVertex,
                                 FirstIndice,
                                 NbIndice            : longint;
                                 mshd                : string;
                                 VertexStreamIndex   : longint;
                                 Texture             : string;
                                 MinN1, MinN2, MinN3,
                                 MaxN1, MaxN2, MaxN3 : single;
                           end;

 T_LOD =                   record
                                 FocusMin, FocusMax   : Single;
                                 SubsetMin, SubsetMax : longint;
                           end;

 T_Vertex =                record
                                 y,z,x : single;
                           end;

 T_NormalVertex =          record
                                 y,z,x : single;
                           end;

 T_TextureVertex =         record
                                 x,y : single;
                           end;

 T_ShipVertexMmod =        record
                                 V :     T_Vertex;
                                 Vn :    T_NormalVertex;
                                 V1t :   T_TextureVertex;
                                 V2t :   T_TextureVertex;
                                 Other : array[0..5] of single;
                           end;


var
 FOBJ : Text;         { fichier OBJ source }
 FVertex,             { fichier temporaire contenant les vertex }
 FVertexNormal,       { fichier temporaire contenant les normales }
 FVertexTexture,      { fichier temporaire contenant les coord textures }
 FIndices : file;     { fichier temporaire contenant les indices à placer dans le fichier Mmod }
 TabSubset            : array[0..99] of T_Subset;
 TabLOD               : array[0..9] of T_LOD;
 NbSubset,
 NbLODPhases          : integer;
 NbVertex,
 NbIndices            : longint;
 NbIndex              : integer;

Procedure Arreter;
begin
  {$i-}
 close(FOBJ);
  {$i+}
 TXMUtils.Arreter;
end;

 {*************************************************************************}
 { ajouter un vertex dans le fichier Mmod, place le valeur 'Vertex' dedans }
 { et met les autre valeurs à 0                                            }
 {*************************************************************************}

Procedure AddShipVertex(V : T_Vertex);
const
 Blank : array [1..13] of single = (0,0,0,0,0,0,0,0,0,0,0,0,0);
begin
 Seek(FMmod,FileSize(FMmod));
 BlockWrite(FMmod,V,3*4);
 BlockWrite(FMmod,Blank,13*4);
end;

 {*****************************************************************************************************}
 { cette procedure lit le fichier OBJ et écrit tous les vertex dans le fichier MMod                    }
 { elle retourne le nombre de vertex ainsi que les valeurs mini et maxi de chaque type de nombre       }
 { pour le calcul de BoundingSphere et BoundingBox                                                     }
 {*****************************************************************************************************}

 (*****************

Procedure WriteVertex(var NbVertex : longint; var MinN1, MinN2, MinN3, MaxN1, MaxN2, MaxN3 : single; CoefEchelle, VOffset : single);
var
 NbFaces                : longint;   { nombre de triangle dans le mesh }
 VertexFound            : boolean;
 Compteur               : integer;
 W1, W2, W3             : word;
 LI                     : longint;
 B                      : Boolean;
 s                      : string;
 V                      : T_Vertex;
 VT                     : T_TextureVertex;
 VN                     : T_NormalVertex;
 SVM                    : T_ShipVertexMmod;
 PosVZone               : longint;    { position du début de la zone des vertex dans le fichier Mmod      }
 FirstMinMax            : boolean;    { vrai pour la premiere lecture des min/max afin de les initialiser }
 FPremierV,                           { fichier de booleen contenant vrai tant que le vertex correpondant n'a pas été utilisé }
 FVertexNormal,                       { fichier temporaire contenant les nomaux vertex source }
 FVertexTexture         : file;       { fichier temporaire contenant les coordonèes des textures }
 Key                    : Char;

 Function EstPremierV(N : word) : boolean;
 var
  b : boolean;
 begin
  seek(FPremierV,N);
  blockRead(FPremierV,B,1);
  EstPremierV:=b;
 end;

 Procedure NonPremierV(N:word);
 var
  b : boolean;
 begin
  b:=false;
  seek(FPremierV,N);
  blockWrite(FPremierV,b,1);
 end;

 Function ValVertex(LI : longint) : T_Vertex;
 var
  V : T_Vertex;
 begin
  V.y:=0;
  V.z:=0;
  V.x:=0;
  LI:=LI*16*4;
  inc(LI,PosVZone);
  if LI<=FileSize(FMmod)-(3*4) then begin
   seek(FMmod,LI);
   BlockRead(Fmmod,V,3*4);
  end;
  ValVertex:=V;
 end;

 Function ValNormalVertex(LI : longint) : T_NormalVertex;
 var
  TN : T_NormalVertex;
 begin
  TN.y:=0;
  TN.z:=0;
  TN.y:=0;
  LI:=LI*3*4;
  if LI<=FileSize(FVertexNormal)-(3*4) then begin
   seek(FVertexNormal, LI);
   BlockRead(FVertexNormal,TN,3*4);
  end
  else
   WriteLN(FRapport,'Dépacement normal Vertex : LI=',LI div 3 div 4,' Filesize=',FileSize(FVertexNormal));
  ValNormalVertex:=TN;
 end;

 Function ValTextureVertex(LI : longint) : T_TextureVertex;
 var
  TV : T_TextureVertex;
 begin
  TV.x:=0;
  TV.y:=0;
  WriteLN(FRapport,LI);
  LI:=LI*2*4;
  if LI<=FileSize(FVertexTexture)-(2*4) then begin
   seek(FVertexTexture, LI);
   BlockRead(FVertexTexture,TV,2*4);
  end
  else
   WriteLN(FRapport,'Dépacement texture Vertex : LI=',LI div 2 div 4,' Filesize=',FileSize(FVertexTexture));
  ValTextureVertex:=TV;
 end;

begin
  { se placer à la fin du fichier FMmod }
 seek(FMmod,FileSize(FMmod));

  { enregistrer la position de la zone de début des vertexs }
 PosVZone:=FilePos(FMmod);

  { initialiser les fichiers temporaire }
 assign(FIndices,'Indices.TMP');
 assign(FVertexNormal,'VertexNormal.TMP');
 assign(FVertexTexture,'VertexTexture.TMP');

 Rewrite(FIndices,1);
 Rewrite(FVertexNormal,1);
 Rewrite(FVertexTexture,1);

  { initialiser le fichier source }
  {$I-}
 reset(FOBJ);
  {$I+}

 if IOResult<>0 then arreter;

  { initialiser le nombre de vertex }
 NbVertex:=0;

  { lire le fichier source et remplir les fichiers temporaires FVertexNormal, FVertexTexture       }
  { écrire dans le fichier mmod les vertex avec des valeurs "Normale" et "Texture" à 0             }
 while not (EOF(FOBJ)) and (DosError=0) do begin
   {$I-}
  ReadLN(FOBJ,S);
   {$I+}


  if IOResult=0 then begin
   if length(S)>0 then begin
    if (S[1]='v') or (S[1]='V') then begin
     if (S[2]='t') or (S[2]='T') then begin

       { 'Vt' trouvé }

       { éjecter 'Vt' }
      EjectTxt(S,length('Vt'));

       { donner les valeurs par défaut à VT }
      VT.x:=0; VT.y:=0;

       { lire VT }
      if EjectAllPresentKey(S)<>'' then VT.x:=NumberR(S);
      if EjectAllPresentKey(S)<>'' then VT.y:=1-NumberR(S);

       { écrire les valeurs de VT dans le fichier temporaire }
      BlockWrite(FVertexTexture,VT,2*4);

     end
     else
     begin

      if (S[2]='n') or (S[2]='N') then begin

        { 'Vn' trouvé }

        { éjecter 'Vn' }
       EjectTxt(S,length('Vn'));

        { donner les valeurs par défaut à VN }
       VN.y:=0; VN.z:=0; VN.x:=0;

        { lire VN }
       if EjectAllPresentKey(S)<>'' then VN.y:=NumberR(S);
       if EjectAllPresentKey(S)<>'' then VN.z:=NumberR(S);
       if EjectAllPresentKey(S)<>'' then VN.x:=NumberR(S);

        { écrire les valeurs de VN dans le fichier temporaire }
       BlockWrite(FVertexNormal,VN,3*4);

      end
      else
      begin

        { 'V' trouvé }

       inc(NbVertex);

         { éjecter 'V' }
       EjectTxt(S,length('V'));

        { donner les valeurs par défaut à V }
       V.y:=0; V.z:=0; V.x:=0;

        { lire les valeurs de V }
       if EjectAllPresentKey(S)<>'' then V.y:=NumberR(S)*CoefEchelle;
       if EjectAllPresentKey(S)<>'' then V.z:=NumberR(S)*CoefEchelle+VOffset;
       if EjectAllPresentKey(S)<>'' then V.x:=NumberR(S)*CoefEchelle;


        { écrire les valeurs de V dans FMmod }
       AddShipVertex(V);

        { mettre à jour les valeurs de Min/Max N1, N2, N3 }
       with V do begin
        if FirstMinMax then begin
         MinN1:=y; MinN2:=z; MinN3:=x;
         MaxN1:=y; MaxN2:=z; MaxN3:=x;
         FirstMinMax:=false;
        end;
        if y<MinN1 then MinN1:=y;
        if y>MaxN1 then MaxN1:=y;
        if z<MinN2 then MinN2:=z;
        if z>MaxN2 then MaxN2:=z;
        if x<MinN3 then MinN3:=x;
        if x>MaxN3 then MaxN3:=x;
       end;
      end;
     end;
    end;
   end;
  end;
 end;

  { Lire les indices, les stocker dans le fichier FIndices, et mettre à jour les valeurs de FMmod }


  { initialiser le fichier FPremierV }
 B:=true;
 assign(FPremierV,'PremierV.TMP');
 Rewrite(FPremierV,1);
 for Li:=1 to NbVertex do BlockWrite(FPremierV,B,1);

 NbFaces:=0; { initialiser le nombre de triangles }

 Reset(FOBJ);

 while not (EOF(FOBJ)) and (DosError=0) do begin
  StopOnEscape;
   {$I-}
  ReadLN(FOBJ,S);
   {$I+}
  if IOResult=0 then begin

   if (length(S)>0) and ((S[1]='f') or (S[1]='F')) then begin
     { cette ligne contient un indice }

     { ecrire sur l'écran le Nb de faces écrites }
    inc(NbFaces);
    Write(chr(8)); Write(chr(8)); Write(chr(8)); Write(chr(8)); Write(chr(8)); Write(chr(8)); Write(chr(8)); Write(chr(8));
    Write(chr(8)); Write(chr(8)); Write(chr(8)); Write(chr(8)); Write(chr(8)); Write(chr(8));
    Write(NbFaces:8,' faces');

     { retirer le 'f' du début de ligne }
    EjectTXT(S,length('f'));

    for compteur:=1 to 3 do begin { lire les trois sommets du triangle }

      { donner les valeurs par défaut à W1, W2 et W3 }
     W1:=0; W2:=0; W3:=0;

     EjectfirstPresentKey(S);

      { lire le premier indice du vertex }
     if EjectAllPresentKey(S)<>'' then begin
      W1:=pred(NumberW(S));

       { lire le second indice du vertex }
      if (length(S)>0) and (S[1]='/') then begin
       EjectTXT(S,length('/'));
       if S[1]<>'/' then W2:=Pred(NumberW(S)) else EjectTXT(S,Length('/'));

        { lire le 3eme indice du vertex }
       if (length(S)>0) and (S[1]<>' ') then W3:=Pred(NumberW(S));

      end;
     end
     else
     begin
      Writeln;
      Writeln('Face have less then 3 vertices');
      W1:=0;
      W2:=0;
      W3:=0;
     end;

      { Ecrire les valeur dans le fichier Mmod et dans le fichier temporaire FIndices }
     if EstPremierV(W1) then begin

       { c'est la première fois que cet indice est utilisé, écrire directement les valeurs dans Mmod }
      LI:=W1;
      LI:=(LI*(16*4))+(3*4);
      inc(LI,PosVZone);
      seek(FMmod,LI);
      VN:=ValNormalVertex(W3);
      VT:=ValTextureVertex(W2);
      BlockWrite(FMmod,VN,3*4);
      BlockWrite(FMmod,VT,2*4);

       { mettre à jour PremierV }
      NonPremierV(W1);

     end
     else
     begin

       { ce n'est pas la première fois que cette indice est utilisé, comparer les valeurs, et si nécessaire, créer un nouveau vertex }
      LI:=W1;
      LI:=LI*(16*4);
      inc(LI,PosVZone);
      seek(FMmod,LI);
      Blockread(FMmod,SVM,16*4);
      VN:=ValNormalVertex(W3);
      VT:=ValTextureVertex(W2);
      if not ((VN.y=SVM.VN.y) and (VN.z=SVM.VN.z) and (VN.z=SVM.VN.z) and
         (VT.x=SVM.V1t.x) and (VT.y=SVM.V1t.y)) then begin

        { le vertex n'est pas le meme que celui désigné : rechercher dans tous le fichier s'il n'existe pas déja }
       V:=ValVertex(W1);
       VertexFound:=false;
       seek(FMmod,PosVZone);

       for LI:=0 to pred(NbVertex) do begin

        if not VertexFound then begin
          BlockRead(FMmod,SVM,16*4);
          if (SVM.V.y=V.y) and (SVM.V.z=V.z) and (SVM.V.x=V.x) and
            (SVM.Vn.y=VN.y) and (SVM.Vn.z=VN.z) and (SVM.Vn.x=VN.x) and
            (SVM.V1t.x=VT.x) and (SVM.V1t.y=VT.y) then begin

             { le vertex existe }
            W1:=LI;
            VertexFound:=true;

         end;
        end;
        end;

       if not(VertexFound) then begin

         { le vertex n'existe pas : en créer un nouveau }
        SVM.V:=ValVertex(W1);
        SVM.Vn:=VN;
        SVM.V1t:=VT;
        SVM.V2t.x:=0; SVM.V2t.y:=0;
        SVM.Other[0]:=0; SVM.Other[1]:=0; SVM.Other[2]:=0; SVM.Other[3]:=0; SVM.Other[4]:=0; SVM.Other[5]:=0;
        seek(FMmod,FileSize(FMmod));
        BlockWrite(FMmod,SVM,16*4);

         { metre à jour la valeur de l'indice  }
        W1:=NbVertex;

         { mettre à jour le nombre de vertex }
        inc(NbVertex);

       end;
      end;

     end;
      { Ecrire l'indice dans le fichier temporaire FIndices }
     BlockWrite(FIndices,W1,2);

    end;

    if EjectAllPresentKey(S)<>'' then begin
     Writeln;
     WriteLN('Face have more than 3 vertices');
    end;
   end;
  end;
 end;


  { fermer et effacer les fichiers temporaire FVertexNormal et FVertexTexture }
 close(FPremierV);
 close(FVertexNormal);
 close(FVertexTexture);

 erase(FPremierV);
 erase(FVertexNormal);
 erase(FVertexTexture);

 WriteLN;

end;

***********************)

 {*****************************************************************************************************}
 { lit le fichier source OBJ et écrit les indices dans le fichier destination FMMod                    }
 {*****************************************************************************************************}

Procedure WriteIndices(var NbIndices : longint);
var
 LI : longint;
 TI : array[1..3] of word;
begin

 reset(FIndices,1);
 seek(FMmod,FileSize(Fmmod));

  { écrire le mote clé 'Indices' }
 WriteLI(length('Indices'));
 WriteTxt('Indices');

  { écrire la longueur de la section }
 WriteLI(FileSize(FIndices)+8);

  { écrire le nombre d'indices }
 WriteLI(FileSize(FIndices) div 2);

  { écrire 101 }
 WriteLI(101);


 while not(EOF(FIndices)) do begin
   {$i-}
  BlockRead(FIndices,TI,3*2);
   {$i+}
  if IOResult=0 then BlockWrite(FMmod,TI,3*2);
 end;

 NbIndices:=FileSize(FIndices) div 6;

end;

Function ValVertex(LI : longint) : T_Vertex;
var
 V : T_Vertex;
begin
 V.y:=0;
 V.z:=0;
 V.x:=0;
 LI:=LI*3*4;
 if LI<=FileSize(FVertex)-(3*4) then begin
  seek(FVertex,LI);
  BlockRead(FVertex,V,3*4);
 end
 else
  WriteLN(FRapport,'Dépacement Vertex : LI=',LI div 3 div 4,' Filesize=',FileSize(FVertex));
 ValVertex:=V;
end;

Function ValNormalVertex(LI : longint) : T_NormalVertex;
var
 TN : T_NormalVertex;
begin
 TN.y:=0;
 TN.z:=0;
 TN.y:=0;
 LI:=LI*3*4;
 if LI<=FileSize(FVertexNormal)-(3*4) then begin
  seek(FVertexNormal, LI);
  BlockRead(FVertexNormal,TN,3*4);
 end
 else
  WriteLN(FRapport,'Dépacement normal Vertex : LI=',LI div 3 div 4,' Filesize=',FileSize(FVertexNormal));
 ValNormalVertex:=TN;
end;

Function ValTextureVertex(LI : longint) : T_TextureVertex;
var
 TV : T_TextureVertex;
begin
 TV.x:=0;
 TV.y:=0;
 LI:=LI*2*4;
 if LI<=FileSize(FVertexTexture)-(2*4) then begin
  seek(FVertexTexture, LI);
  BlockRead(FVertexTexture,TV,2*4);
 end
 else
  WriteLN(FRapport,'Dépacement texture Vertex : LI=',LI div 2 div 4,' Filesize=',FileSize(FVertexTexture));
 ValTextureVertex:=TV;
end;


Procedure ReadOBJFile(OBJFileName, Texture : string; Rescale, VOffset : single);
var
 KW,
 S, S2, S3              : string;
 V                      : T_Vertex;
 VT                     : T_TextureVertex;
 VN                     : T_NormalVertex;
 TextureMTL             : string;
 MTLFileName            : string;
 FMTL                   : text;
 NbFaces                : longint;
 Compteur               : integer;
 W,
 W1, W2, W3             : word;
 PVertexStream          : longint;    { mémorise l'emplacement de la longueur du vertexStream }
 PDebutVertex           : longint;    { mémorise la position du début de la liste des vertex }
 ShipVertexMmod         : T_ShipVertexMmod;
 CptVertex,
 NoVertex               : longint;

 Procedure InitSubset;
 begin

   { initialiser le nouveau Subset }
  TabSubset[NbSubset].FirstVertex:=NbVertex;
  TabSubset[NbSubset].FirstIndice:=NbIndices*3;
  if StrMajuscule(Texture)='MTL' then
   TabSubset[NbSubset].Texture:=TextureMTL
  else
   TabSubset[NbSubset].Texture:=Texture;
  if StrMajuscule(RightStr(TabSubset[NbSubset].Texture,4))='.DDS'then
   TabSubset[NbSubset].Texture:=LeftStr(TabSubset[NbSubset].Texture,Length(TabSubset[NbSubset].Texture)-4)+'.tga'
  else
  begin
   WriteLN;
   WriteLN('=========================================');
   Writeln(' Texture isn''t DDS format !');
   WriteLN('=========================================');
   Arreter;
  end;
  TabSubset[NbSubset].MSHD:='ship.mshd';
  TabSubset[NbSubset].MinN1:=0;
  TabSubset[NbSubset].MinN2:=0;
  TabSubset[NbSubset].MinN3:=0;
  TabSubset[NbSubset].MaxN1:=0;
  TabSubset[NbSubset].MaxN2:=0;
  TabSubset[NbSubset].MaxN3:=0;

  if (NbSubset=0) or (TabSubset[NbSubset].mshd<>TabSubset[pred(NbSubset)].mshd) then begin
   if NbSubset>0 then begin
     { mettre à jour le vertexstream en cours avant de passer au suivant }
     { se positionner à l'emplacement de la longueur de la section }
    seek(FMmod,PVertexStream);

     { écrire la longueur de la section }
    WriteLI(FileSize(FMmod)-PVertexStream-4);;
    WriteLI(NbVertex);

   end;

    { créer une nouvelle section }
   seek(FMmod,FileSize(FMmod));
   WriteLI(length('VertexStream'));
   WriteTxt('VertexStream');
   PVertexStream:=FilePos(FMmod);
   WriteLI(0);  { 0 dans le longueur de la section en attendant la bonne valeur }
   WriteLI(0);  { 0 dans le nombre de vertex en attendant la bonne valeur }
   if TabSubset[NbSubset].mshd='ship.mshd' then begin
    WriteLI(length('ship.mvfm'));
    WriteTxt('ship.mvfm');
   end;
   PDebutVertex:=FilePos(FMmod);

   inc(NbIndex);

  end;

   { mettre à jour la bonne valeur d'index }
  TabSubset[NbSubset].VertexStreamIndex:=Pred(NbIndex);

   { mettre à jour le nombre d'index }
  inc(NbSubset);

 end;

begin

  { initialiser les fichiers }
 assign(FOBJ,OBJFileName);        { fichier OBJ source }

 {$i-}
 Reset(FOBJ);
 {$i+}

 if IOResult<>0 then begin
  WriteLN;
  WriteLN('********************************');
  WriteLN('file ',OBJFileName,' not found / not opened');
  arreter;
 end;

 assign(FVertex,'Vertex.TMP');
 assign(FVertexNormal,'VertexNormal.TMP');
 assign(FVertexTexture,'VertexTexture.TMP');

 Rewrite(FVertex,1);
 Rewrite(FVertexNormal,1);
 Rewrite(FVertexTexture,1);

 seek(FIndices,FileSize(FIndices));

  { lire le fichier source et remplir les fichiers temporaires FVertex, FVertexNormal, FVertexTexture       }

 while not (EOF(FOBJ)) do begin
   {$I-}
  ReadLN(FOBJ,S);
   {$I+}

  if IOResult<>0 then begin
   writeln;
   writeln('================ OBJ READ ERROR !!! ======================');
   Arreter;
  end;

  KW:=StrMajuscule(KeyWord(S));

  if KW='V' then begin

     { éjecter 'V' }
   EjectTxt(S,length('V'));

    { donner les valeurs par défaut à V }
   V.y:=0; V.z:=0; V.x:=0;

    { lire les valeurs de V }
   if EjectAllPresentKey(S)<>'' then V.y:=NumberR(S)*Rescale;
   if EjectAllPresentKey(S)<>'' then V.z:=NumberR(S)*Rescale+VOffset;
   if EjectAllPresentKey(S)<>'' then V.x:=NumberR(S)*Rescale;

    { écrire les valeurs de V dans le fichier temporaire }
   BlockWrite(FVertex,V,3*4);

  end;

  if KW='VT' then begin

    { éjecter 'Vt' }
   EjectTxt(S,length('VT'));

    { donner les valeurs par défaut à VT }
   VT.x:=0; VT.y:=0;

    { lire VT }
   if EjectAllPresentKey(S)<>'' then VT.x:=NumberR(S);
   if EjectAllPresentKey(S)<>'' then VT.y:=1-NumberR(S);

    { écrire les valeurs de VT dans le fichier temporaire }
   BlockWrite(FVertexTexture,VT,2*4);

  end;

  if KW='VN' then begin

    { éjecter 'Vn' }
   EjectTxt(S,length('Vn'));

    { donner les valeurs par défaut à VN }
   VN.y:=0; VN.z:=0; VN.x:=0;

    { lire VN }
   if EjectAllPresentKey(S)<>'' then VN.y:=NumberR(S);
   if EjectAllPresentKey(S)<>'' then VN.z:=NumberR(S);
   if EjectAllPresentKey(S)<>'' then VN.x:=NumberR(S);

     { écrire les valeurs de VN dans le fichier temporaire }
   BlockWrite(FVertexNormal,VN,3*4);

  end;
 end;

  { lire le fichier source OBJ depuis le début et extraire les subsets et les indices }

 Reset(FOBJ);

 TextureMTL:='white.dds';
 MTLFileName:='';

 NbFaces:=0;

  { initialiser les subsets }
 InitSubset;

 while not EOF(FOBJ) do begin

  StopOnEscape;

   {$I-}
  ReadLN(FOBJ,S);
   {$I+}

  if IOResult<>0 then begin
   writeln;
   writeln('================ OBJ READ ERROR !!! ======================');
   Arreter;
  end;

   { lire le mot clé et l'éjecter de la chaine S }
  S:=EjectFirstPresentKey(S);
  KW:=StrMajuscule(KeyWord(S));
  EjectTxt(S,length(KW));

  if (KW='MTLLIB') and (StrMajuscule(Texture) ='MTL') then
      { définir le fichier 'MTL' à lire }
   MTLFileName:=EjectFirstPresentKey(S);

  if (KW='USEMTL') and (StrMajuscule(Texture) ='MTL') then begin

    { ouvrir le fichier MTL et retrouver la définition correspondante }
    { puis creer le nouveau subset }

   if MTLFileName<>'' then begin
    assign(FMTL,MTLFileName);
     {$i-}
    reset(FMTL);
     {$i+}
    if IOResult<>0 then begin
     writeln;
     writeln('======= MTLFileName not found / not opened !!! =========');
     arreter;
    end;
    while not EOF(FMTL) do begin
     ReadLN(FMTL,S2);
     if StrMajuscule(KeyWord(S2))='NEWMTL' then begin
      EjectTxt(S2,Length('NEWMTL'));
      if EjectFirstPresentKey(S2)=EjectFirstPresentKey(S) then begin

        { la section correspondante a été trouvée }
        { lire sa définition }

        { donner la valeur par défaut à TextureMTL }
       TextureMTL:='white.dds';

       Repeat
         {$i-}
        Readln(FMTL,S3);
         {$i+}
        if IOResult<>0 then begin
         writeln;
         writeln('================ MTL READ ERROR !!! ======================');
         Arreter;
        end;

        if StrMajuscule(KeyWord(S3)) = 'MAP_KD' then begin

          { la définition de la texture a été trouvée, la lire }
         S3:=EjectFirstPresentKey(S3);
         EjectTxt(S3, length('MAP_KD'));
         TextureMTL:=EjectFirstPresentKey(S3);
         break;
        end;

       until (StrMajuscule(KeyWord(S3))='NEWMTL') or EOF(FMTL);;
      end;
     end;
    end;

    close(FMTL);

   end;

   if NbSubset>0 then begin
     { cloturer le subset en cours }
    TabSubset[pred(NbSubset)].NbVertex:=NbVertex-TabSubset[pred(NbSubset)].FirstVertex;
    TabSubset[pred(NbSubset)].NbIndice:=NbIndices-(TabSubset[pred(NbSubset)].FirstIndice div 3);
   end;

    { initialiser le nouveau Subset }
   InitSubset;

  end;

  if KW='F' then begin
   { il s'agit d'une face }
   { la lire et l'ajouter dans FIndices et éventuellement mettre à jour les vertex de FMmod }

    { ecrire sur l'écran le Nb de faces écrites }
   inc(NbFaces);
   Write(chr(8)); Write(chr(8)); Write(chr(8)); Write(chr(8)); Write(chr(8)); Write(chr(8)); Write(chr(8)); Write(chr(8));
   Write(chr(8)); Write(chr(8)); Write(chr(8)); Write(chr(8)); Write(chr(8)); Write(chr(8));
   Write(NbFaces:8,' faces');

    { retirer le 'f' du début de ligne }
   EjectTXT(S,length('f'));

   for compteur:=1 to 3 do begin { lire les trois sommets du triangle }

     { donner les valeurs par défaut à W1, W2 et W3 }
    W1:=0; W2:=0; W3:=0;

    S:=EjectfirstPresentKey(S);

     { lire le premier indice du vertex }
    if EjectAllPresentKey(S)<>'' then begin
     W1:=pred(NumberW(S));

      { lire le second indice du vertex }
     if (length(S)>0) and (S[1]='/') then begin
      EjectTXT(S,length('/'));
      if S[1]<>'/' then W2:=Pred(NumberW(S)) else EjectTXT(S,Length('/'));

       { lire le 3eme indice du vertex }
      if (length(S)>0) and (S[1]<>' ') then W3:=Pred(NumberW(S));

     end;
    end
    else
    begin
     Writeln;
     Writeln('Face have less then 3 vertices');
     W1:=0;
     W2:=0;
     W3:=0;
    end;

     { récupéré les valeurs des vertex, nomalvertex et texture }
    V:=ValVertex(W1);
    VT:=ValTextureVertex(W2);
    VN:=ValNormalVertex(W3);

     { rechercher dans FMmod si ce vertex existe déja }
    NoVertex:=-1;
    CptVertex:=0;
    seek(FMmod,PDebutVertex);
    while not EOF(FMmod) do begin
      { lire le vertex dans FMmod }
     if TabSubset[pred(NbSubset)].mshd='ship.mshd' then BlockRead(FMmod,ShipVertexMmod,16*4);

      { comparer le vertex lu à celui dont on a besoin }
     if   (ShipVertexMmod.V.x=V.x) and (ShipVertexMmod.V.y=V.y) and (ShipVertexMmod.V.z=V.z)
      and (ShipVertexMmod.V1t.x=VT.x) and  (ShipVertexMmod.V1t.y=VT.y)
      and (ShipVertexMmod.Vn.x=VN.x) and (ShipVertexMmod.Vn.y=VN.y) and (ShipVertexMmod.Vn.z=VN.z) then begin

       { le vertex existe et est trouvé }
      NoVertex:=CptVertex;
      break;

     end;
     inc(CptVertex);
    end;

    if NoVertex=-1 then begin
      { le vertex n'existe pas : le créer }
     ShipVertexMmod.V.x:=V.x; ShipVertexMmod.V.y:=V.y; ShipVertexMmod.V.z:=V.z;
     ShipVertexMmod.V1t.x:=VT.x; ShipVertexMmod.V1t.y:=VT.y;
     ShipVertexMmod.Vn.x:=VN.x; ShipVertexMmod.Vn.y:=VN.y; ShipVertexMmod.Vn.z:=VN.z;
     ShipVertexMmod.V2t.x:=0; ShipVertexMmod.V2t.y:=0;
     ShipVertexMmod.Other[0]:=0; ShipVertexMmod.Other[1]:=0; ShipVertexMmod.Other[2]:=0; ShipVertexMmod.Other[3]:=0; ShipVertexMmod.Other[4]:=0; ShipVertexMmod.Other[5]:=0;

     seek(FMmod,FileSize(FMmod));
     blockWrite(FMmod,ShipVertexMmod,16*4);

      { mettre à jour le numéro du vertex utilisé }
     NoVertex:=CptVertex;

      { mettre à jour le nombre de vertex }
     inc(NbVertex);
    end;

    if NoVertex<=$FFFF then begin

      { écrire l'indice correspondant }
     W:=NoVertex;
     BlockWrite(Findices,W,2);

    end
    else
    begin
     writeln;
     writeln('========== TOO MANY VERTICES !!! ===============');
     arreter;
    end;

     { mettre à jour les valeur min/max pour le subset }
    if (TabSubset[pred(NbSubset)].MinN1=0) and (TabSubset[pred(NbSubset)].MinN2=0) and (TabSubset[pred(NbSubset)].MinN3=0) and
       (TabSubset[pred(NbSubset)].MaxN1=0) and (TabSubset[pred(NbSubset)].MaxN2=0) and (TabSubset[pred(NbSubset)].MaxN3=0) then begin
      { c'est la première fois : initialiser les valeur Min/Max }
     TabSubset[pred(NbSubset)].MinN1:=ShipVertexMmod.V.y;
     TabSubset[pred(NbSubset)].MaxN1:=ShipVertexMmod.V.y;
     TabSubset[pred(NbSubset)].MinN2:=ShipVertexMmod.V.z;
     TabSubset[pred(NbSubset)].MaxN2:=ShipVertexMmod.V.z;
     TabSubset[pred(NbSubset)].MinN3:=ShipVertexMmod.V.x;
     TabSubset[pred(NbSubset)].MaxN3:=ShipVertexMmod.V.x;
    end;
    if ShipVertexMmod.V.y<TabSubset[pred(NbSubset)].MinN1 then TabSubset[pred(NbSubset)].MinN1:= ShipVertexMmod.V.y;
    if ShipVertexMmod.V.y>TabSubset[pred(NbSubset)].MaxN1 then TabSubset[pred(NbSubset)].MaxN1:= ShipVertexMmod.V.y;
    if ShipVertexMmod.V.z<TabSubset[pred(NbSubset)].MinN2 then TabSubset[pred(NbSubset)].MinN2:= ShipVertexMmod.V.z;
    if ShipVertexMmod.V.z>TabSubset[pred(NbSubset)].MaxN2 then TabSubset[pred(NbSubset)].MaxN2:= ShipVertexMmod.V.z;
    if ShipVertexMmod.V.x<TabSubset[pred(NbSubset)].MinN3 then TabSubset[pred(NbSubset)].MinN3:= ShipVertexMmod.V.x;
    if ShipVertexMmod.V.x>TabSubset[pred(NbSubset)].MaxN3 then TabSubset[pred(NbSubset)].MaxN3:= ShipVertexMmod.V.x;

   end;

    { mettre à jour le nombre d'indices }
   inc(NbIndices);

  end;
 end;

  { cloturer le dernier subset }
 TabSubset[pred(NbSubset)].NbVertex:=NbVertex-TabSubset[pred(NbSubset)].FirstVertex;
 TabSubset[pred(NbSubset)].NbIndice:=NbIndices-(TabSubset[pred(NbSubset)].FirstIndice div 3);

  { mettre à jour le dernier vertexstream }

  { se positionner à l'emplacement de la longueur de la section }
 seek(FMmod,PVertexStream);

  { écrire la longueur de la section }
 WriteLI(FileSize(FMmod)-PVertexStream-4);

  { écrire le nombre de sommets }
 WriteLI(NbVertex);

  { se replacer à la fin du fichier FMmod }
 seek(FMmod,FileSize(FMmod));

  { fermer le fichier source }
 close(FOBJ);

  { fermer et effacer les fichiers temporaires }
 close(FVertex);
 close(FVertexNormal);
 close(FVertexTexture);

 (**
 erase(FVertex);
 erase(FVertexNormal);
 erase(FVertexTexture);
    **)
end;

Procedure LODPhase(var STXM : string);
var
 OBJFileName,               { nom du fichier OBJ source }
 Texture        : string;   { texture à appliquer }
 Rescale        : single;   { valeur de remise à l'échelle }
 VOffset        : single;   { valeur du décalage vertical }
begin

  { éjecter 'LOD' du début de STXM }
 STXm:=EjectFirstPresentKey(STXM);
 EjectTxt(STXM,length('LOD'));

  { lire les deux valeur de focus }
 if EjectFirstPresentKey(STXM)='' then Arreter;
 TABLOD[NbLODPhases].FocusMin:=NumberR(STXM);
 if EjectFirstPresentKey(STXM)='' then Arreter;
 TABLOD[NbLODPhases].FocusMax:=NumberR(STXM);

  { donner la valeur à TABLOD.SubsetMin }
 TABLOD[NbLODPhases].SubsetMin:=NbSubset;

  { lire la ligne suivante dans le fichier source }
 STXM:=ReadFTXM;

  { lire tous les fichiers composant le LOD }
 while (StrMajuscule(EjectAllPresentKey(STXM))<>'ENDLOD') and (STXM<>'') do begin

   { lire le nom du fichier source }
  OBJFileName := StrMajuscule(KeyWord(STXM));
  STXM:=EjectFirstPresentKey(STXM);
  EjectTxt(STXM,Length(OBJFileName));

   { lire le nom de la texture }
  Texture:=StrMajuscule(KeyWord(STXM));
  STXM:=EjectFirstPresentKey(STXM);
  EjectTxt(STXM,length(Texture));

   { initialiser les valeurs de remise à l'échelle et de décalage vertical }
  Rescale:=1;
  VOffset:=0;

   { si elle existe, lire la valeur valeur de remise à l'echelle }
  if EjectAllPresentKey(STXM)<>'' then Rescale:=NumberR(STXM);

   { si elle existe, lire la valeur VOffset de décalage vertical }
  if EjectAllPresentKey(STXM)<>'' then VOffset:=NumberR(STXM);


   { informer l'utilisateur }
  writeln('Fichier source : ',OBJFileName);
  writeln('Texture : ',texture);
  writeLN('Rescale = ',Rescale:6:2);
  writeln('Vertical offset = ',VOffset:6:2);

  if (RightStr(Texture,4) <> '.DDS') and (Texture<>'MTL') then begin

    { la texture trouvée n'est pas un fichier 'DDS' }
   WriteLN;
   Writeln('***************************************');
   writeln(Texture,' isn''t a DDS file !');
   Writeln('***************************************');
   Arreter;

  end;

  if RightStr(OBJFileName,4) <> '.OBJ' then begin

    { le nom trouvé ne correspond pas à un fichier OBJ }
   WriteLN;
   Writeln('***************************************');
   writeln(OBJFilename,' isn''t an OBJ file !');
   Writeln('***************************************');
   Arreter;

  end;

   { lire le fichier source }
  ReadOBJFile(OBJFileName,Texture, Rescale, VOffset);

   { lire la ligne suivante du fichier source }
  STXM:=ReadFTXM;

 end;

  { donner la bonne valeur à TABLOD.SubsetMax }
 TABLOD[NbLODPhases].SubsetMax:=pred(NbSubset);

  { mettre à jour le nombre de LOD dans ce Mesh }
 inc(NbLODPhases);

end;

 {*****************************************************************************************************}
 { cette procédure écrit la section BoundingSphere à la fin du fichier Mmod                               }
 {*****************************************************************************************************}

Procedure WriteBoundingSphere(MinN1, MinN2, MinN3, MaxN1, MAxN2, MAxN3 : single);
var
 LR1, LR2, LR3, RS : single;
begin

  { se replacer à la fin du fichier FMmod }
 seek(FMmod,FileSize(FMmod));

  { écrire la longueur du mot clé 'BoundingSphere }
 WriteLI(Length('BoundingSphere'));

  { écrire le mot clé 'BoundingSphere' }
 WriteTxt('BoundingSphere');

  { écrire la longueur de la section (=16) }
 WriteLI(16);

  { écrire les coordonnées du centre }
 WriteR((MinN1+MaxN1)/2);
 WriteR((MinN2+MaxN2)/2);
 WriteR((MinN3+MaxN3)/2);

  { calculer le rayon }
 LR1:=MaxN1-MinN1; LR2:=MaxN2-MinN2; LR3:=MaxN3-MinN3;
 RS:=sqrt((LR1*LR1)+(LR2*LR2)+(LR3*LR3))/2;

  { écrire le rayon }
 WriteR(RS);

end;

 {*****************************************************************************************************}
 { cette procédure écrit la section BoundingBox à la fin du fichier Mmod                               }
 {*****************************************************************************************************}

Procedure WriteBoundingBox(MinN1, MinN2, MinN3, MaxN1, MAxN2, MAxN3 : single);
begin

  { se replacer à la fin du fichier FMmod }
 seek(FMmod,FileSize(FMmod));

  { écrire la longueur du mot clé 'BoundingBox' }
 WriteLI(Length('BoundingBox'));

  { écrire le mot clé 'BoundingSphere' }
 WriteTxt('BoundingBox');

  { écrire la longueur de la section (=24) }
 WriteLI(24);

  { écrire les valeurs extremes }
 WriteR(MinN1); WriteR(MinN2); WriteR(MinN3);
 WriteR(MaxN1); WriteR(MaxN2); WriteR(MaxN3);

end;

 {*****************************************************************************************************}
 { cette procédure écrit la section SubSets à la fin du fichier Mmod                               }
 {*****************************************************************************************************}

Procedure WriteSubsets;
const
 LightingSettingsNumber : array[1..38] of word = (
  1,0,0,0,0,16256,0,16256,0,16256,0,16256,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,16256,0,0,0,0,0,0,0,16256,0,0);
var
 i : integer;
 PSubset    : longint; { emplacement de la longueur de la section du subset }
begin

 for i:=0 to pred(NbSubset) do begin

   { se placer à la fin du fichier FMmod }
  seek(FMmod,FileSize(FMmod));

   { écrire le mot clé 'Subset'}
  WriteLI(Length('Subset'));
  WriteTxt('Subset');

   { mémoriser la position de la longueur de la section }
  PSubset:=FilePos(FMmod);
  WriteLI(0); { écrire 0 en attendant la bonne valeur }

   { écrire les nombres associés }
  WriteLI(5);
  WriteLI(TabSubset[i].FirstVertex); WriteLI(TabSubset[i].NbVertex);
  WriteLI(TabSubset[i].FirstIndice); WriteLI(TabSubset[i].NbIndice);

   { écrire le mshd }
  WriteLI(Length(TabSubset[i].mshd)); WriteTxt(TabSubset[i].mshd);
  WriteLI(Length('VertexStreamIndex')); WriteTxt('VertexStreamIndex');
  WriteLI(4); WriteLI(TabSubset[i].VertexStreamIndex);

   { écrire les 3 textures }
  WriteLI(Length('Texture'));WriteTxt('Texture');
  WriteLI(Length(TabSubset[i].Texture)+8);
  WriteLI(Length(TabSubset[i].Texture)); WriteTxt(TabSubset[i].Texture);
  WriteLI(0);

  WriteLI(Length('Texture'));WriteTxt('Texture');
  WriteLI(Length('Japo_nocolor.tga')+8);
  WriteLI(Length('Japo_nocolor.tga')); WriteTxt('Japo_nocolor.tga');
  WriteLI(1);

  WriteLI(Length('Texture'));WriteTxt('Texture');
  WriteLI(Length('No_shadow.tga')+8);
  WriteLI(Length('No_shadow.tga')); WriteTxt('No_shadow.tga');
  WriteLI(2);

   { ecrire le LightingSettings }
  WriteLI(length('LightingSettings'));
  WriteTXT('LightingSettings');
  WriteLI(76);
  BlockWrite(FMmod,LightingSettingsNumber,76);

   { écrire le BoundingSpghere }
  with TabSubset[i] do WriteBoundingSphere(MinN1, MinN2, MinN3, MaxN1, MAxN2, MAxN3);

   { écrire la longueur du Subset }
  seek(FMmod,PSubset);
  WriteLI(FileSize(FMmod)-PSubset-4);

 end;

  { se replacer à la fin du fichier FMmod }
 seek(FMmod,FileSize(FMmod));

end;

 {*****************************************************************************************************}
 { cette procédure écrit la section LODPhases à la fin du fichier Mmod                               }
 {*****************************************************************************************************}

Procedure WriteLODs;
var
 PLOD : longint ;  { position de la longueur de la section }
 i : integer;
begin

  { se placer à la fin du fichier Mmod }
 seek(FMmod,fileSize(FMmod));

  { écrit la longueur du mot clé 'LODPhases' }
 WriteLI(Length('LODPhases'));

  { écrire le mot clé 'LODPhases' }
 WriteTxt('LODPhases');

  { mémoriser la position de la longueur de la section }
 PLOD:=FilePos(FMmod);

  { écrire 0 dans la longueur de la section en attendant la bonne valeur }
 WriteLI(0);

  { écrire le nombre de phases }
 WriteLI(NbLODPhases);

  { écrire les LODphases }
 for i:=0 to Pred(NbLODPhases) do begin
  WriteR(TABLOD[i].FocusMin);
  WriteR(TABLOD[i].FocusMax);
  WriteLI(TABLOD[i].SubsetMin);
  WriteLI(TABLOD[i].SubsetMax);
 end;

  { écrire la longueur de la section }
 seek(FMmod,PLOD);
 WriteLI(FileSize(FMmod)-PLOD-4);

end;

 {*****************************************************************************************************}
 { cette procédure lit le fichier de format OBJ et l'insert comme Mesh dans le fichier Mmod            }
 {*****************************************************************************************************}

Procedure InsertMesh(var STXM : string);
const
 LightingSettingsNumber : array[1..38] of word = (
  1,0,0,0,0,16256,0,16256,0,16256,0,16256,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,16256,0,0,0,0,0,0,0,16256,0,0);
var
 i                              : integer;
 CoefEchelle,                                   { coefficient de correction d'echelle du mesh }
 VOffset                        : single;       { valeur du déplacement vertical à appliquer au mesh }
 PTexture,                                      { position de la longueur de la section Texture }
 PSubset,                                       { position de la longueur de la section Subset }
 PIndices,                                      { position de la longueur de la section Indices }
 PVertexStream,                                 { position de la longueur de la section VertexStream }
 PMesh                          : longint;      { position de la longueur de la section Mesh }
 KWord                          : string;
 KeyWordFind                    : boolean;
 NameFOBJ                       : string;       { nom du ficheir OBJ }
 Texture                        : string;       { nom de la texture }
 MinN1, MinN2, MinN3,
 MAxN1, MaxN2, MaxN3            : Single;       { valeurs extremes des vertex dans le Mesh }
begin

  { retour à la ligne sur l'écran }
 WriteLN;

  { se placer à la fin du fichier Mmod }
 seek(FMmod,FileSize(FMmod));

  { écrire la longueur du mot cle 'Mesh' }
 WriteLI(length('Mesh'));

  { écrire le mot clé 'Mesh' }
 WriteTXT('Mesh');

  { mémoriser la position de la longueur de la section Mesh }
 PMesh:=FilePos(FMmod);

  { écrire 0 dans la longueur de la section en attendant la bonne valeur }
 WriteLI(0);

  { écrire le nombre associé '0' }
 WriteLI(0);

  { lire la ligne suivante dans le fichier source }
 STXM:=ReadFTXM;

  { initialiser le nombre de LODPhases et le nombre de Subsets }
 NbSubset    :=0;
 NbLODPhases :=0;
 NbVertex    :=0;
 NbIndices   :=0;
 NbIndex     :=0;

  { initialiser le fichier temporaire des indices }
 assign(FIndices,'FIndices.TMP');
 rewrite(FIndices,1);

  { lire tous les LOD }
 While StrMajuscule(KeyWord(STXM))='LOD' do begin
  LODPhase(STXM);
  STXM:=ReadFTXM;
 end;

  { écrire les indices }
 WriteIndices(NbIndices);

  { fermer et effacer le fichier temporaire des indices }
 close(FIndices);
 erase(FIndices);

  { Déterminer les valeurs Min/Max }
 MinN1:=TabSubset[0].MinN1; MinN2:=TabSubset[0].MinN2; MinN3:=TabSubset[0].MinN3;
 MaxN1:=TabSubset[0].MaxN1; MaxN2:=TabSubset[0].MaxN2; MaxN3:=TabSubset[0].MaxN3;
 for i:=1 to pred(NbSubset) do begin
  if TabSubset[i].MinN1<MinN1 then MinN1:=TabSubset[i].MinN1;
  if TabSubset[i].MinN2<MinN2 then MinN2:=TabSubset[i].MinN2;
  if TabSubset[i].MinN3<MinN3 then MinN3:=TabSubset[i].MinN3;
  if TabSubset[i].MaxN1>MinN1 then MaxN1:=TabSubset[i].MaxN1;
  if TabSubset[i].MaxN2>MinN2 then MaxN2:=TabSubset[i].MaxN2;
  if TabSubset[i].MaxN3>MinN3 then MaxN3:=TabSubset[i].MaxN3;
 end;

  { écrire les valeurs de BoundingBox et BoundingShere }
 WriteBoundingSPhere(MinN1, MinN2, MinN3, MaxN1, MAxN2, MAxN3);
 WriteBoundingBox(MinN1, MinN2, MinN3, MaxN1, MAxN2, MAxN3);

  { écrire les Subsets }
 WriteSubsets;

  { écrire la section LODPhases }
 WriteLODs;

   { écrire la longueur de la section Mesh }
 seek(FMmod,PMesh);
 WriteLI(FileSize(FMmod)-PMesh-4);

  { se replacer à la fin du fichier FMmod }
 seek(FMmod,FileSize(FMmod));

  { mettre à jour l'afficahge écran }
 Writeln('Nb lines compiled :');
 Write('        ');










(*

  { Extraire le nom du fichier OBJ }
 NameFOBJ:=KeyWord(STXM);

  { Vérifier que l'extension est '.OBJ' }
 if StrMajuscule(RightStr(NameFOBJ,4)) <> '.OBJ' then begin
  WriteLN;
  WriteLN(NameFOBJ,' isn''t an OBJ file !');
  Writeln;
  Arreter;  { le fichier n'est pas '.OBJ' : arreter }
 end;

  { initialiser le fichier source OBJ }
 assign(FOBJ,NameFOBJ);

  {$i-}
 reset(FOBJ);
  {$I+}

 if IOResult<>0 then begin
  WriteLN;
  WriteLN('==== file '+NameFOBJ+' not found / not opened ====');
  WriteLN;
  Arreter;
 end;

  { informer l'utilisateur }
 WriteLN('file '+NameFOBJ+' found and opened.');

  { Regarder s'il existe une texture, sinon lui appliquer la valeur 'White.tga' par défaut }
 STXM:=EjectFirstPresentKey(STXM);
 EjectTxt(STXM,length(NameFOBJ));
 if EjectAllPresentKey(STXM)<>'' then Texture:=KeyWord(STXM) else Texture :='White.tga';

  { regarder s'il existe un coefficient de réechelonnage }
 STXM:=EjectFirstPresentKey(STXM);
 EjectTxt(STXM,length(Texture));
 if EjectAllPresentKey(STXM)<>'' then CoefEchelle:=NumberR(STXM) else CoefEchelle:=1;

  { regarder s'il existe une valeur d'offset vertical }
 if EjectAllPresentKey(STXM)<>'' then VOffset:=NumberR(STXM) else VOffset:=0;

  { informer l'utilisateur }
 WriteLN('Texture : '+Texture);
 WriteLN('Coef rescaling = ',CoefEchelle:5:2);
 WriteLN('Vertical offset = ',VOffset:5:2);

  { se placer à la fin du fichier Mmod }
 seek(FMmod,FileSize(FMmod));

  { écrire la longueur du mot cle 'Mesh' }
 WriteLI(length('Mesh'));

  { écrire le mot clé 'Mesh' }
 WriteTXT('Mesh');

  { mémoriser la position de la longueur de la section Mesh }
 PMesh:=FilePos(FMmod);

  { écrire 0 dans la longueur de la section en attendant la bonne valeur }
 WriteLI(0);

  { écrire le nombre associé '0' }
 WriteLI(0);

  { écrire la longueur du mot cle 'VertexStream' }
 WriteLI(length('VertexStream'));

  { écrire le mot clé 'VertexStream' }
 WriteTXT('VertexStream');

  { mémoriser la position de la longueur de la section VertexStream }
 PVertexStream:=FilePos(FMmod);

  { écrire 0 dans la longueur de la section en attendant la bonne valeur }
 WriteLI(0);

  { écrire 0 dans le nombre de vertex en attendant la bonne valeur }
 WriteLI(0);

  { écrire la longueur du mot cle 'ship.mvfm' }
 WriteLI(length('ship.mvfm'));

  { écrire le mot clé 'ship.mvfm' }
 WriteTXT('ship.mvfm');

  { écrire les vertex }
 WriteVertex(NbVertex, MinN1, MinN2, MinN3, MaxN1, MAxN2, MAxN3, CoefEchelle, VOffset);

  { écrire la longueur de la section }
 seek(FMmod,PVertexStream);
 WriteLI(FileSize(FMmod)-PVertexStream-4);

  { écrire le nombre de vertex }
 WriteLI(NbVertex);

  { se replacer à la fin du fichier FMmod }
 seek(FMmod,FileSize(FMmod));

  { écrire la longueur du mot clé 'Indices' }
 WriteLI(Length('Indices'));

  { écrire le mot clé 'Indices' }
 WriteTXT('Indices');

  { mémoriser la position de la longueur de la section }
 PIndices:=FilePos(FMmod);

  { écrire 0 dans le longueur de la section en attendant la bonne valeur }
 WriteLI(0);

  { ecrire 0 dans le nombre d'indices en attendant la bonne valeur }
 WriteLI(0);

  { ecrire le nombre associé 101 }
 WriteLI(101);

  { écrire les indices }
 WriteIndices(NbIndices);

  { écrire la longueur de la section }
 seek(FMmod,PIndices);
 WriteLI(FileSize(FMmod)-PIndices-4);

  { écrire le nombre d'indices }
 WriteLI(NbIndices*3);

  { se replacer à la fin du fichier FMmod }
 seek(FMmod,FileSize(FMmod));

  { écrire la longueur du mot clé 'BoundingSphere }
 WriteLI(Length('BoundingSphere'));

  { écrire le mot clé 'BoundingSphere' }
 WriteTxt('BoundingSphere');

  { écrire la longueur de la section (=16) }
 WriteLI(16);

  { écrire les coordonnées du centre }
 WriteR((MinN1+MaxN1)/2);
 WriteR((MinN2+MaxN2)/2);
 WriteR((MinN3+MaxN3)/2);

  { calculer le rayon }
 LR1:=MaxN1-MinN1; LR2:=MaxN2-MinN2; LR3:=MaxN3-MinN3;
 RS:=sqrt((LR1*LR1)+(LR2*LR2)+(LR3*LR3))/2;

  { écrire le rayon }
 WriteR(RS);

  { écrire la longueur du mot clé 'BoundingBox' }
 WriteLI(Length('BoundingBox'));

  { écrire le mot clé 'BoundingSphere' }
 WriteTxt('BoundingBox');

  { écrire la longueur de la section (=24) }
 WriteLI(24);

  { écrire les valeurs extremes }
 WriteR(MinN1); WriteR(MinN2); WriteR(MinN3);
 WriteR(MaxN1); WriteR(MaxN2); WriteR(MaxN3);

  { écrire la longueur du mot cle 'Subset' }
 WriteLI(Length('Subset'));

  { écrire le mot clé 'Subset' };
 WriteTXT('Subset');

  { mémoriser la position de la longueur de la section Subset }
 PSubset:=FilePos(FMmod);

  { écrire 0 dans la longueur en attendant la bonne valeur }
 WriteLI(0);

  { écrire ne nombre associé 5 }
 WriteLI(5);

  { écrire les valeurs des pointeurs des vertex et des indices }
 WriteLI(0); WriteLI(NbVertex);
 WriteLI(0); WriteLI(NbIndices);

  { écrire la longueur du mot cle 'ship.mshd' }
 WriteLI(Length('ship.mshd'));

  { écrire 'ship.mshd' }
 WriteTXT('ship.mshd');

  { écrire la longueur de 'VertexStreamIndex' }
 WriteLI(length('VertexStreamIndex'));

  { écrire 'VertexStreamIndex' }
 WriteTXT('VertexStreamIndex');

  { écrire la longueur de la section (=4) }
 WriteLI(4);

  { écrire le nombre associé (=0) }
 WriteLI(0);



  { écrire la longueur du mot cle 'Texture' }
 WriteLI(Length('Texture'));

  { écrire 'Texture' }
 WriteTXT('Texture');

  { mémoriser la position de la longueur de la section }
 PTexture := FilePos(FMmod);

  { écrire 0 dans la longueur de la section en attendant la bonne valeur }
 WriteLI(0);

  { écrire le longueur du nom de la texture }
 WriteLI(Length(Texture));

  { écrire le nom de la texture }
 WriteTxt(Texture);

  { écrire le nombre associé (=0) }
 WriteLI(0);

  { écrire la longueur de la section Texture }
 seek(FMmod,PTexture);
 WriteLI(FileSize(FMmod)-PTexture-4);

  { se replacer à la fin du fichier FMmod }
 seek(FMmod,FileSize(FMmod));

  { écrire la longueur du mot cle 'Texture' }
 WriteLI(Length('Texture'));

  { écrire 'Texture' }
 WriteTXT('Texture');

  { mémoriser la position de la longueur de la section }
 PTexture := FilePos(FMmod);

  { écrire 0 dans la longueur de la section en attendant la bonne valeur }
 WriteLI(0);

  { écrire le longueur du nom de la texture }
 WriteLI(Length('Japo_nocolor.tga'));

  { écrire le nom de la texture }
 WriteTxt('Japo_nocolor.tga');

  { écrire le nombre associé (=1) }
 WriteLI(1);

  { écrire la longueur de la section Texture }
 seek(FMmod,PTexture);
 WriteLI(FileSize(FMmod)-PTexture-4);

  { se replacer à la fin du fichier FMmod }
 seek(FMmod,FileSize(FMmod));

  { écrire la longueur du mot cle 'Texture' }
 WriteLI(Length('Texture'));

  { écrire 'Texture' }
 WriteTXT('Texture');

  { mémoriser la position de la longueur de la section }
 PTexture := FilePos(FMmod);

  { écrire 0 dans la longueur de la section en attendant la bonne valeur }
 WriteLI(0);

  { écrire le longueur du nom de la texture }
 WriteLI(Length('No_shadow.tga'));

  { écrire le nom de la texture }
 WriteTxt('No_shadow.tga');

  { écrire le nombre associé (=2) }
 WriteLI(2);

  { écrire la longueur de la section Texture }
 seek(FMmod,PTexture);
 WriteLI(FileSize(FMmod)-PTexture-4);

  { se replacer à la fin du fichier FMmod }
 seek(FMmod,FileSize(FMmod));

  { écrire la longueur du mot clé 'LightingSettings' }
 WriteLI(length('LightingSettings'));

  { écrire 'LightingSettings' }
 WriteTXT('LightingSettings');

  { écrire la longueur de la section (=76) }
 WriteLI(76);

  { écrire les valeurs de LightingSettings }
 BlockWrite(FMmod,LightingSettingsNumber,76);

  { écrire la longueur du mot clé 'BoundingSphere }
 WriteLI(Length('BoundingSphere'));

  { écrire le mot clé 'BoundingSphere' }
 WriteTxt('BoundingSphere');

  { écrire la longueur de la section (=16) }
 WriteLI(16);

  { écrire les coordonnées du centre }
 WriteR((MinN1+MaxN1)/2);
 WriteR((MinN2+MaxN2)/2);
 WriteR((MinN3+MaxN3)/2);

  { écrire le rayon }
 WriteR(RS);

  { écrire la longueur de la section Subset }
 seek(FMmod,PSubset);
 WriteLI(FileSize(FMmod)-PSubset-4);

  { se replacer à la fin du fichier FMmod }
 seek(FMmod,FileSize(FMmod));

  { écrire la longueur du mot clé 'LODPhases' }
 WriteLI(length('LODPhases'));

  { écrire 'LODPhases' }
 WriteTXT('LODPhases');

  { écrire la longueur de la section (=20) }
 WriteLI(20);

  { écrire le nombre de phases (=1) }
 WriteLI(1);

  { écrire les nombre associé : 0.00 ; 0.98 ; 0 ; 0 }
 WriteR(0); WriteR(0.98); WriteLI(0); WriteLI(0);

  { écrire la longueur de la section Mesh }
 seek(FMmod,PMesh);
 WriteLI(FileSize(FMmod)-PMesh-4);

  { se replacer à la fin du fichier FMmod }
 seek(FMmod,FileSize(FMmod));

  { fermer le fichier source }
 close(FOBJ);

  { mettre à jour l'afficahge écran }
 Writeln('Nb lines compiled :');
 Write('        ');


 *)

end;

 {*****************************************************************************************************}
 { c'est une ligne de commande, lire la commande et lancer son exécution                               }
 {*****************************************************************************************************}

Procedure Command(var STXM : string);
var
 KWord          : string;
 KeyWordFind    : boolean;
begin

   { Ejecter le mot cle au début de la chaine de caractère }
 STXM:=EjectFirstPresentKey(STXM);
 EjectTxt(STXM,length('Command'));

    { Extraire le mot clef }
 KWord:=KeyWord(STXM);

   { exécuter la procédure correspondant au mot cle trouvé }
 KeyWordFind:=false;

 if StrMajuscule(KWord)='INSERTMESH' then begin InsertMesh(STXM); KeyWordFind:=true; end;

 if not KeyWordFind then Arreter;

 STXM:='';

end;

begin

end.
