Program TXM2MMOD;

{===============================================================}
{=                                                             =}
{=               convert TXM file to MMOD file                 =}
{=                                                             =}
{===============================================================}

uses dos,strutils, TXMCommand, TXMVar, TXMUtils;

const
 PrintSizeLI = false;

 {*****************************************************************************************************}
 {*****************************************************************************************************}
 {*****************************************************************************************************}
 { Liste des proc�dures �crivant dans le fichier FMod.                                                 }
 { La variable STXM retourne la derni�re ligne lue et invalide car destin�e � la commande suivante.    }
 { Cette variable est mise � '' si la struture �tant connue, la ligne suivante n'a pas �t� lue.        }
 {*****************************************************************************************************}
 {*****************************************************************************************************}
 {*****************************************************************************************************}

Procedure BoundingSphere(var STXM : string);
begin

  { �crire le longueur du mot cle }
 WriteLI(Length('BoundingSphere'));

  { �crire le mot cl� }
 WriteTXT('BoundingSphere');

  { �crire le longueur de la section }
 WriteLI(16);

  { lire la ligne suivante dans le fichier source }
 STXM:=ReadFTXM;

  { �crire les valeurs des nombres }
 WriteR(NumberR(STXM)); WriteR(NumberR(STXM)); WriteR(NumberR(STXM)); WriteR(NumberR(STXM));

end;

Procedure BoundingBox(var STXM : string);
begin

  { �crire le longueur du mot cle }
 WriteLI(Length('BoundingBox'));

  { �crire le mot cl� }
 WriteTXT('BoundingBox');

  { �crire le longueur de la section }
 WriteLI(24);

  { lire la ligne suivante dans le fichier source }
 STXM:=ReadFTXM;

  { �crire les valeurs des nombres }
 WriteR(NumberR(STXM)); WriteR(NumberR(STXM)); WriteR(NumberR(STXM));

  { lire la ligne suivante dans le fichier source }
 STXM:=ReadFTXM;

  { �crire les valeurs des nombres }
 WriteR(NumberR(STXM)); WriteR(NumberR(STXM)); WriteR(NumberR(STXM));

end;

Procedure Name(var STXM : string);
begin
  { �crire la longueur de 'Name' }
 WriteLI(Length('Name'));

  { �crire le mot cle }
 WriteTXT('Name');

  { Ejecter le mot cle au d�but de la chaine de caract�re }
 EjectTxt(STXM,length('Name'));

  { Ejecter les premiere caract�res de pr�sentation }
 STXM:=EjectFirstPresentKey(STXM);

  {�crire les longueurs }
 WriteLI(Length(STXM)+4);
 WriteLI(Length(STXM));

  { �crire la texture }
 WriteTxt(STXM);

 STXM:='';
end;

Procedure Matrix(var STXM : string);
begin
  { �crire la longueur de 'Matrix' }
 WriteLI(Length('Matrix'));

  { �crire le mot cle }
 WriteTXT('Matrix');

  { �crire la longueur 64 }
 WriteLI(64);

  { lire la ligne suivante }
 STXM:=ReadFTXM;

  { ecrire 4 valeurs }
 WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));

  { lire la ligne suivante }
 STXM:=ReadFTXM;

  { ecrire 4 valeurs }
 WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));

  { lire la ligne suivante }
 STXM:=ReadFTXM;

  { ecrire 4 valeurs }
 WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));

  { lire la ligne suivante }
 STXM:=ReadFTXM;

  { ecrire 4 valeurs }
 WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));

end;

Procedure Resource2(var STXM : string);
begin
  { �crire la longueur de 'Resource' }
 WriteLI(Length('Resource'));

  { �crire le mot cle }
 WriteTXT('Resource');

  { �crire la longueur=4 (pour 1 longint) }
 WriteLI(4);

  { Ejecter le mot cle au d�but de la chaine de caract�re }
 EjectTxt(STXM,length('Resource'));

  { �crire le nombre associ� }
 WriteLI(NumberLI(STXM));

end;

Procedure Flags(var STXM : string);
begin
  { �crire la longueur de 'Flags' }
 WriteLI(Length('Flags'));

  { �crire le mot cle }
 WriteTXT('Flags');

  { �crire la longueur=4 (pour 1 longint) }
 WriteLI(4);

  { Ejecter le mot cle au d�but de la chaine de caract�re }
 EjectTxt(STXM,length('Flags'));

  { �crire le nombre associ� }
 WriteLI(NumberLI(STXM));

end;

Procedure Parent(var STXM : string);
begin
  { �crire la longueur de 'Parent' }
 WriteLI(Length('Parent'));

  { �crire le mot cle }
 WriteTXT('Parent');

  { Ejecter le mot cle au d�but de la chaine de caract�re }
 EjectTxt(STXM,length('Parent'));

  { Ecrire le nombre 4 }
 WriteLI(4);

  { Ecrire le nombre associ� }
 WriteLI(NumberLI(STXM));

end;

Procedure Item(var STXM : string);
var
 KeyWordFind : boolean;
 KWord : string;
 LI,
 p : longint;        { position de la longueur de la section }
begin
  { �crire la longueur de 'Item' }
 WriteLI(Length('Item'));

  { �crire le mot cle }
 WriteTXT('Item');

  { M�moriser la position dans le fichier }
 P:=FilePos(FMmod);

  { �crire zero dans la longueur en attendant de connaitre la bonne valeur }
 WriteLI(0);

  { lire la ligne suivante dans le fichier source }
 STXM:=ReadFTXM;

 Repeat

   {si STXM est vide, alors lire la ligne suivante }
  if EjectAllPresentKey(STXM) ='' then STXM:=ReadFTXM;

   { Extraire le mot clef }
  KWord:=KeyWord(STXM);

   { ex�cuter la proc�dure correspondant au mot cle trouv� }
  KeyWordFind:=false;
  if KWord='Name' then begin Name(STXM); KeyWordFind:=true; end;
  if KWord='Matrix' then begin Matrix(STXM); KeyWordFind:=true; end;
  if KWord='Resource' then begin Resource2(STXM); KeyWordFind:=true; end;
  if KWord='Flags' then begin Flags(STXM); KeyWordFind:=true; end;
  if KWord='BoundingSphere' then begin BoundingSphere(STXM); KeyWordFind:=true; end;
  if KWord='BoundingBox' then begin BoundingBox(STXM); KeyWordFind:=true; end;
  if KWord='Parent' then begin Parent(STXM); KeyWordFind:=true; end;

 Until not KeyWordFind or EOF(FTXM);

  { calculer la longueur de la section }
 LI:=FileSize(FMmod)-p-4;

  { �crire la longueur de la section }
 Seek(FMmod,p);
 WriteLI(LI);

  { se replacer � la fin du fichier}
 Seek(FMmod,FileSize(FMmod));

end;

Procedure Hierarchy(var STXM : string);
var
 KeyWordFind : boolean;
 KWord : string;
 LI,
 p : longint;        { position de la longueur de la section }
begin
  { �crire la longueur de 'Hierarchy' }
 WriteLI(Length('Hierarchy'));

  { �crire le mot cle }
 WriteTXT('Hierarchy');

  { M�moriser la position dans le fichier }
 P:=FilePos(FMmod);

  { �crire zero dans la longueur en attendant de connaitre la bonne valeur }
 WriteLI(0);

  { lire la ligne suivante dans le fichier source }
 STXM:=ReadFTXM;

 Repeat

   {si STXM est vide, alors lire la ligne suivante }
  if EjectAllPresentKey(STXM) ='' then STXM:=ReadFTXM;

   { Extraire le mot clef }
  KWord:=KeyWord(STXM);

   { ex�cuter la proc�dure correspondant au mot cle trouv� }
  KeyWordFind:=false;
  if KWord='Item' then begin Item(STXM); KeyWordFind:=true; end;

 Until not KeyWordFind or EOF(FTXM);

  { calculer la longueur de la section }
 LI:=FileSize(FMmod)-p-4;

  { �crire la longueur de la section }
 Seek(FMmod,p);
 WriteLI(LI);

  { se replacer � la fin du fichier}
 Seek(FMmod,FileSize(FMmod));

end;

Procedure ShipMvfm(var STXM : string; var NbVertex : longint);
begin
  { �crire la longueur de 'ship.mvfm' }
 WriteLI(Length('ship.mvfm'));

  { �crire le mot cle }
 WriteTXT('ship.mvfm');

  { initialiser NbVertex }
 NbVertex:=0;

  { lire la ligne suivante dans le fichier source }
 STXM:=ReadFTXM;

 while (not CharOfTextInList(STXM,ListLetter)) and (not EOF(FTXM)) do begin

   { ce texte ne contient pas de lettre : lire les nombres et les �crire dans le fichier destination }
  inc(NbVertex);

   { lire 16 r��ls et les �crire }
  WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));
  WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));
  WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));
  WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));

   { lire la ligne suivante dans le fichier source }
  STXM:=ReadFTXM;

 end;
end;

Procedure ShipVcMvfm(var STXM : string; var NbVertex : longint);
begin
  { �crire la longueur de 'shipvc.mvfm' }
 WriteLI(Length('shipvc.mvfm'));

  { �crire le mot cle }
 WriteTXT('shipvc.mvfm');

  { initialiser NbVertex }
 NbVertex:=0;

  { lire la ligne suivante dans le fichier source }
 STXM:=ReadFTXM;

 while (not CharOfTextInList(STXM,ListLetter)) and (not EOF(FTXM)) do begin

   { ce texte ne contient pas de lettre : lire les nombres et les �crire dans le fichier destination }
  inc(NbVertex);

   { lire 16 r��ls et les �crire }
  WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));
  WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));
  WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));
  WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));

   { lire 4 octets et les �crit }
  WriteB(NumberB(STXM));WriteB(NumberB(STXM));WriteB(NumberB(STXM));WriteB(NumberB(STXM));

   { lire la ligne suivante dans le fichier source }
  STXM:=ReadFTXM;

 end;
end;

Procedure RopeMvfm(var STXM : string; var NbVertex : longint);
begin
  { �crire la longueur de 'rope.mvfm' }
 WriteLI(Length('rope.mvfm'));

  { �crire le mot cle }
 WriteTXT('rope.mvfm');

  { initialiser NbVertex }
 NbVertex:=0;

  { lire la ligne suivante dans le fichier source }
 STXM:=ReadFTXM;

 while (not CharOfTextInList(STXM,ListLetter)) and (not EOF(FTXM)) do begin

   { ce texte ne contient pas de lettre : lire les nombres et les �crire dans le fichier destination }
  inc(NbVertex);

   { lire 9 r��ls et les �crire }
  WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));
  WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));
  WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));

   { lire la ligne suivante dans le fichier source }
  STXM:=ReadFTXM;

 end;
end;

Procedure SimpleMvfm(var STXM : string; var NbVertex : longint);
begin
  { �crire la longueur de 'simple.mvfm' }
 WriteLI(Length('simple.mvfm'));

  { �crire le mot cle }
 WriteTXT('simple.mvfm');

  { initialiser NbVertex }
 NbVertex:=0;

  { lire la ligne suivante dans le fichier source }
 STXM:=ReadFTXM;

 while (not CharOfTextInList(STXM,ListLetter)) and (not EOF(FTXM)) do begin

   { ce texte ne contient pas de lettre : lire les nombres et les �crire dans le fichier destination }
  inc(NbVertex);

   { lire 8 r��ls et les �crire }
  WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));
  WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));

   { lire la ligne suivante dans le fichier source }
  STXM:=ReadFTXM;

 end;
end;

Procedure GunVcMvfm(var STXM : string; var NbVertex : longint);
begin
  { �crire la longueur de 'gunvc.mvfm' }
 WriteLI(Length('gunvc.mvfm'));

  { �crire le mot cle }
 WriteTXT('gunvc.mvfm');

  { initialiser NbVertex }
 NbVertex:=0;

  { lire la ligne suivante dans le fichier source }
 STXM:=ReadFTXM;

 while (not CharOfTextInList(STXM,ListLetter)) and (not EOF(FTXM)) do begin

   { ce texte ne contient pas de lettre : lire les nombres et les �crire dans le fichier destination }
  inc(NbVertex);

   { lire 8 r��l et les �crire }
  WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));
  WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));

   { lire 4 octets et les �crit }
  WriteB(NumberB(STXM));WriteB(NumberB(STXM));WriteB(NumberB(STXM));WriteB(NumberB(STXM));

   { lire la ligne suivante dans le fichier source }
  STXM:=ReadFTXM;

 end;
end;

Procedure SimpleIndexedMvfm(var STXM : string; var NbVertex : longint);
begin
  { �crire la longueur de 'simpleindexed.mvfm' }
 WriteLI(Length('simpleindexed.mvfm'));

  { �crire le mot cle }
 WriteTXT('simpleindexed.mvfm');

  { initialiser NbVertex }
 NbVertex:=0;

  { lire la ligne suivante dans le fichier source }
 STXM:=ReadFTXM;

 while (not CharOfTextInList(STXM,ListLetter)) and (not EOF(FTXM)) do begin

   { ce texte ne contient pas de lettre : lire les nombres et les �crire dans le fichier destination }
  inc(NbVertex);

   { lire 9 r��l et les �crire }
  WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));
  WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));
  WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));

   { lire la ligne suivante dans le fichier source }
  STXM:=ReadFTXM;

 end;
end;

Procedure BTerrain2Mvfm(var STXM : string; var NbVertex : longint);
begin
  { �crire la longueur de 'bterrain2.mvfm' }
 WriteLI(Length('bterrain2.mvfm'));

  { �crire le mot cle }
 WriteTXT('bterrain2.mvfm');

  { initialiser NbVertex }
 NbVertex:=0;

  { lire la ligne suivante dans le fichier source }
 STXM:=ReadFTXM;

 while (not CharOfTextInList(STXM,ListLetter)) and (not EOF(FTXM)) do begin

   { ce texte ne contient pas de lettre : lire les nombres et les �crire dans le fichier destination }
  inc(NbVertex);

   { lire 10 r��l et les �crire }
  WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));
  WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));

   { lire la ligne suivante dans le fichier source }
  STXM:=ReadFTXM;

 end;
end;

Procedure PositionMvfm(var STXM : string; var NbVertex : longint);
begin
  { �crire la longueur de 'position.mvfm' }
 WriteLI(Length('position.mvfm'));

  { �crire le mot cle }
 WriteTXT('position.mvfm');

  { initialiser NbVertex }
 NbVertex:=0;

  { lire la ligne suivante dans le fichier source }
 STXM:=ReadFTXM;

 while (not CharOfTextInList(STXM,ListLetter)) and (not EOF(FTXM)) do begin

   { ce texte ne contient pas de lettre : lire les nombres et les �crire dans le fichier destination }
  inc(NbVertex);

   { lire 3 r��ls et les �crire }
  WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));

   { lire la ligne suivante dans le fichier source }
  STXM:=ReadFTXM;

 end;
end;

Procedure AirPlaneMvfm(var STXM : string; var NbVertex : longint);
begin
  { �crire la longueur de 'airplane.mvfm' }
 WriteLI(Length('airplane.mvfm'));

  { �crire le mot cle }
 WriteTXT('airplane.mvfm');

  { initialiser NbVertex }
 NbVertex:=0;

  { lire la ligne suivante dans le fichier source }
 STXM:=ReadFTXM;

 while (not CharOfTextInList(STXM,ListLetter)) and (not EOF(FTXM)) do begin

   { ce texte ne contient pas de lettre : lire les nombres et les �crire dans le fichier destination }
  inc(NbVertex);

   { lire 14 r��ls et les �crire }
  WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));
  WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));

   { lire la ligne suivante dans le fichier source }
  STXM:=ReadFTXM;

 end;
end;

Procedure AirFieldMvfm(var STXM : string; var NbVertex : longint);
begin
  { �crire la longueur de 'airfield.mvfm' }
 WriteLI(Length('airfield.mvfm'));

  { �crire le mot cle }
 WriteTXT('airfield.mvfm');

  { initialiser NbVertex }
 NbVertex:=0;

  { lire la ligne suivante dans le fichier source }
 STXM:=ReadFTXM;

 while (not CharOfTextInList(STXM,ListLetter)) and (not EOF(FTXM)) do begin

   { ce texte ne contient pas de lettre : lire les nombres et les �crire dans le fichier destination }
  inc(NbVertex);

   { lire 10 r��ls et les �crire }
  WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));
  WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));

   { lire la ligne suivante dans le fichier source }
  STXM:=ReadFTXM;

 end;
end;

Procedure ShoreMvfm(var STXM : string; var NbVertex : longint);
begin
  { �crire la longueur de 'shore.mvfm' }
 WriteLI(Length('shore.mvfm'));

  { �crire le mot cle }
 WriteTXT('shore.mvfm');

  { initialiser NbVertex }
 NbVertex:=0;

  { lire la ligne suivante dans le fichier source }
 STXM:=ReadFTXM;

 while (not CharOfTextInList(STXM,ListLetter)) and (not EOF(FTXM)) do begin

   { ce texte ne contient pas de lettre : lire les nombres et les �crire dans le fichier destination }
  inc(NbVertex);

   { lire 5 r��ls et les �crire }
  WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));
  WriteR(NumberR(STXM));WriteR(NumberR(STXM));

   { lire 4 octets et les �crit }
  WriteB(NumberB(STXM));WriteB(NumberB(STXM));WriteB(NumberB(STXM));WriteB(NumberB(STXM));

   { lire la ligne suivante dans le fichier source }
  STXM:=ReadFTXM;

 end;
end;

Procedure VertexStream(var STXM : string);
var
 KeyWordFind : boolean;
 KWord : string;
 LI,
 NbVertex : longint;   { Nombre de vertex }
 p : longint;          { pointe sur l'emplacement de la longueur de la section }
begin
  { �crire la longueur de 'VertexStream' }
 WriteLI(Length('VertexStream'));

  { �crire le mot cle }
 WriteTXT('VertexStream');

  { M�moriser la position dans le fichier }
 P:=FilePos(FMmod);

  { �crire zero dans la longueur en attendant de connaitre la bonne valeur }
 WriteLI(0);

  { �crire zero dans le nombre de vertex en attendant de connaitre la bonne valeur }
 WriteLI(0);

  { lire la ligne suivante dans le fichier source }
 STXM:=ReadFTXM;

  { Extraire le mot clef }
 KWord:=KeyWord(STXM);

  { ex�cuter la proc�dure correspondant au mot cle trouv� }
 KeyWordFind:=false;
 if KWord='ship.mvfm' then begin ShipMvfm(STXM,NbVertex); KeyWordFind:=true; end;
 if KWord='shipvc.mvfm' then begin ShipVcMvfm(STXM,NbVertex); KeyWordFind:=true; end;
 if KWord='rope.mvfm' then begin RopeMvfm(STXM,NbVertex); KeyWordFind:=true; end;
 if KWord='simple.mvfm' then begin SimpleMvfm(STXM,NbVertex); KeyWordFind:=true; end;
 if KWord='gunvc.mvfm' then begin GunVCMvfm(STXM,NbVertex); KeyWordFind:=true; end;
 if KWord='simpleindexed.mvfm' then begin SimpleIndexedMvfm(STXM,NbVertex); KeyWordFind:=true; end;
 if KWord='bterrain2.mvfm' then begin BTerrain2Mvfm(STXM,NbVertex); KeyWordFind:=true; end;
 if KWord='position.mvfm' then begin PositionMvfm(STXM,NbVertex); KeyWordFind:=true; end;
 if KWord='airplane.mvfm' then begin AirPlaneMvfm(STXM,NbVertex); KeyWordFind:=true; end;
 if KWord='airfield.mvfm' then begin AirFieldMvfm(STXM,NbVertex); KeyWordFind:=true; end;
 if KWord='shore.mvfm' then begin ShoreMvfm(STXM,NbVertex); KeyWordFind:=true; end;

 if not KeyWordFind then Arreter;

  { calculer la longueur de la section }
 LI:=FileSize(FMmod)-p-4;

  { �crire la longueur de la section }
 Seek(FMmod,p);
 WriteLI(LI);

  { �crire le nombre de vertex }
 WriteLI(NbVertex);

  { se replacer � la fin du fichier}
 Seek(FMmod,FileSize(FMmod));

end;

Procedure IndicesStripPS2(var STXM : string);
begin
  { ne fait rien. Juste �vacuer la ligne de commentaire }
 STXM:=ReadFTXM;
 STXM:='';
end;

Procedure Indices(var STXM : string);
var
 LI,
 p,                     { pointe la longueur de la section }
 NbIndices, IndicesType, Iterations, I : longint;   { nombres d'indice dans la section }
 {IndiceValue : word;}
 {IndiceString : string;}
begin
  { �crire la longueur de 'Indices' }
 WriteLI(Length('Indices'));

  { �crire le mot cle }
 WriteTXT('Indices');

  { M�moriser la position dans le fichier }
 P:=FilePos(FMmod);

  { �crire zero dans la longueur en attendant de connaitre la bonne valeur }
 WriteLI(0);

  { �crirezero dans le nombre d'indices en attendant de connaitre la bonne valeur }
 WriteLI(0);

  { Ejecter le mot cle au d�but de la chaine de caract�re }
 EjectTxt(STXM,length('Indices'));

  { Ecrire le nombre associ� }
 
 IndicesType:=NumberLI(STXM);
 WriteLI(IndicesType);

 if IndicesType = 102 then begin
  
  Iterations:=6;
 
 end;
 if IndicesType = 101 then begin
  
  Iterations:=3;
 
 end;

  { initialiser NbIndices }
 NbIndices:=0;

  { lire la ligne suivante dans le fichier source }
 STXM:=ReadFTXM;

 while (not CharOfTextInList(STXM,ListLetter)) and not(EOF(FTXM)) do begin

   { ce texte ne contient pas de lettre : lire les nombres et les �crire dans le fichier destination }
  inc(NbIndices,3);
  
  { lire 3 entiers et les �crire }
  for i:=1 to Iterations do begin
   
   WriteW(NumberW(STXM));
   
  end;
  
   { lire 3 entiers et les �crire }
  {TEST1:=NumberLI(STXM);
  TEST2:=NumberLI(STXM);
  TEST3:=NumberLI(STXM);
  WriteLN(FRapport, 'INDICES!!!!!!!!!!!!!!: '+IntToStr(TEST1)+' BLAH '+IntToStr(TEST2)+' BLAH '+IntToStr(TEST3));
  WriteLI(TEST1);WriteLI(TEST2);WriteLI(TEST3);}

   { lire la ligne suivante dans le fichier source }
  STXM:=ReadFTXM;

 end;

  { calculer la longueur de la section }
 LI:=FileSize(FMmod)-p-4;

  { �crire la longueur de la section }
 Seek(FMmod,p);
 WriteLI(LI);

  { �crire le nombre d'indices }
 WriteLI(NbIndices);

  {se positionner � la fin du fichier }
 seek(FMmod,filesize(FMmod));

end;

Procedure SubSetPS2(var STXM : string);
begin
  { ne fait rien. Juste �vacuer la ligne de commentaire }
 STXM:=ReadFTXM;
 STXM:='';
end;

Procedure MSHD(var STXM : string; KWord : string);
begin

  { �crire la longueur du mot cle }
 WriteLI(Length(KWord));

  { �crire le mot cl� }
 WriteTxt(KWord);

  { Ejecter le mot cle au d�but de la chaine de caract�re }
 EjectTxt(STXM,length(KWord));

end;

Procedure VertexStreamIndex(var STXM : string);
begin
  { �crire la longueur de 'VertexStreamIndex' }
 WriteLI(Length('VertexStreamIndex'));

  { �crire le mot cle }
 WriteTXT('VertexStreamIndex');

  { �crire la longueur=4 (pour 1 longint) }
 WriteLI(4);

  { Ejecter le mot cle au d�but de la chaine de caract�re }
 EjectTxt(STXM,length('VertexStreamIndex'));

  { �crire le nombre associ� }
 WriteLI(NumberLI(STXM));

end;

Procedure Texture(var STXM : string);
var
 NameTexture : string;
begin
  { �crire la longueur de 'Texture' }
 WriteLI(Length('Texture'));

  { �crire le mot cle }
 WriteTXT('Texture');

  { Ejecter le mot cle au d�but de la chaine de caract�re }
 EjectTxt(STXM,length('Texture'));

  { Lire le nom de la texture }
 NameTexture:=KeyWord(STXM);

  {�crire les longueurs }
 WriteLI(Length(NameTexture)+8);
 WriteLI(Length(NameTexture));

  { �crire la texture }
 WriteTxt(NameTexture);

  { Ejecter le nom de la texture au d�but de la chaine de caract�re }
 STXM:=EjectFirstPresentKey(STXM);
 EjectTxt(STXM,length(NameTexture));

  { �crire le nombre associ� }
 WriteLI(NumberLI(STXM));

end;

Procedure LightingSettings(var STXM : string);
var
 i : integer;
begin
  { �crire la longueur de 'LightingSettings' }
 WriteLI(Length('LightingSettings'));

  { �crire le mot cle }
 WriteTXT('LightingSettings');

  { �crire la taille 76 }
 WriteLI(76);

  { Ejecter le mot cle au d�but de la chaine de caract�re }
 EjectTxt(STXM,length('LightingSettings'));

  { Ecrire le nombre associ� }
 WriteLI(NumberLI(STXM));

  { lire les 3 lignes de 6 reels }
 STXM:=ReadFTXM;
 WriteR(NumberR(STXM)); WriteR(NumberR(STXM)); WriteR(NumberR(STXM));
 WriteR(NumberR(STXM)); WriteR(NumberR(STXM)); WriteR(NumberR(STXM));

 STXM:=ReadFTXM;
 WriteR(NumberR(STXM)); WriteR(NumberR(STXM)); WriteR(NumberR(STXM));
 WriteR(NumberR(STXM)); WriteR(NumberR(STXM)); WriteR(NumberR(STXM));

 STXM:=ReadFTXM;
 WriteR(NumberR(STXM)); WriteR(NumberR(STXM)); WriteR(NumberR(STXM));
 WriteR(NumberR(STXM)); WriteR(NumberR(STXM)); WriteR(NumberR(STXM));

 STXM:='';

end;

Procedure SubSet(var STXM : string);
var
 KeyWordFind : boolean;
 KWord : string;
 LI,
 p : longint;        { position de la longueur de la section }
 i : integer;
 S : string;         { recherche de .mshd }
begin
  { �crire la longueur de 'Subset' }
 WriteLI(Length('Subset'));

  { �crire le mot cle }
 WriteTXT('Subset');

  { M�moriser la position dans le fichier }
 P:=FilePos(FMmod);

  { �crire zero dans la longueur en attendant de connaitre la bonne valeur }
 WriteLI(0);

  { Ejecter le mot cle au d�but de la chaine de caract�re }
 EjectTxt(STXM,length('Subset'));

  { Ecrire les nombres associ�s }
 WriteLI(NumberLI(STXM));
 WriteLI(NumberLI(STXM));
 WriteLI(NumberLI(STXM));
 WriteLI(NumberLI(STXM));
 WriteLI(NumberLI(STXM));

  { lire la ligne suivante dans le fichier source }
 STXM:=ReadFTXM;

 Repeat

   {si STXM est vide, alors lire la ligne suivante }
  if EjectAllPresentKey(STXM) ='' then STXM:=ReadFTXM;

   { Extraire le mot clef }
  KWord:=KeyWord(STXM);

   { ex�cuter la proc�dure correspondant au mot cle trouv� }
  KeyWordFind:=false;

   { Commencer par regarder si le mot cle n'est pas au format *.mshd }
  S:='';
  for i:=1 to 5 do S:=S+KWord[length(KWord)-5+i];  { mettre les 5 derniers caract�res dans S }

  if S='.mshd' then begin MSHD(STXM,KWord); KeyWordFind:=true; end;

  if KWord='VertexStreamIndex' then begin VertexStreamIndex(STXM); KeyWordFind:=true; end;
  if KWord='Texture' then begin Texture(STXM); KeyWordFind:=true; end;
  if KWord='LightingSettings' then begin LightingSettings(STXM); KeyWordFind:=true; end;
  if KWord='BoundingSphere' then begin BoundingSphere(STXM); KeyWordFind:=true; end;

 Until not KeyWordFind or EOF(FTXM);

  { calculer la longueur de la section }
 LI:=FileSize(FMmod)-p-4;

  { �crire la longueur de la section }
 Seek(FMmod,p);
 WriteLI(LI);

  { se replacer � la fin du fichier}
 Seek(FMmod,FileSize(FMmod));

end;

Procedure LODPhases(var STXM : string);
var
 p,                     { position de la taille du block }
 LI,
 NbPhases : longint;    { nombre de phases dans le lods }

begin
  { �crire la longueur de 'LODPhases' }
 WriteLI(Length('LODPhases'));

  { �crire le mot cle }
 WriteTXT('LODPhases');

  { M�moriser la position dans le fichier }
 P:=FilePos(FMmod);

  { �crire zero dans la longueur en attendant de connaitre la bonne valeur }
 WriteLI(0);

  { Ejecter le mot cle au d�but de la chaine de caract�re }
 EjectTxt(STXM,length('LODPhases'));

  { Lire le nombre de phases }
 NbPhases:=NumberLI(STXM);

  { �crire le nombre de phases }
 WriteLI(NbPhases);

  { �crire les LODPhases }
 for LI:=1 to NbPhases do begin

   { lire la ligne suivante }
  STXM:=ReadFTXM;

   { �crire les 4 nombres (2reels + 2LI) }
  WriteR(NumberR(STXM)); WriteR(NumberR(STXM)); WriteLI(NumberLI(STXM)); WriteLI(NumberLI(STXM));
 end;

  { calculer la longueur de la section }
 LI:=FileSize(FMmod)-p-4;

  { �crire la longueur de la section }
 Seek(FMmod,p);
 WriteLI(LI);

  { se replacer � la fin du fichier}
 Seek(FMmod,FileSize(FMmod));

end;

Procedure Mesh(var STXM : string);
var
 KeyWordFind : boolean;
 KWord : string;
 LI,
 p : longint;          { pointe sur l'emplacement de la longueur de la section }
begin
  { �crire la longueur de 'Mesh' }
 WriteLI(Length('Mesh'));

  { �crire le mot cle }
 WriteTXT('Mesh');

  { M�moriser la position dans le fichier }
 P:=FilePos(FMmod);

  { �crire zero dans la longueur en attendant de connaitre la bonne valeur }
 WriteLI(0);

  { Ejecter le mot cle au d�but de la chaine de caract�re }
 EjectTxt(STXM,length('Mesh'));

  { Ecrire le nombre associ� }
 WriteLI(NumberLI(STXM));

  { lire la ligne suivante dans le fichier source }
 STXM:=EjectFirstPresentKey(ReadFTXM);

 Repeat

   {si STXM est vide, alors lire la ligne suivante }
  if EjectAllPresentKey(STXM) ='' then STXM:=ReadFTXM;

   { Extraire le mot clef }
  KWord:=KeyWord(STXM);

   { ex�cuter la proc�dure correspondant au mot cle trouv� }
  KeyWordFind:=false;
  if KWord='VertexStream' then begin VertexStream(STXM); KeyWordFind:=true; end;
  if KWord='IndicesStripPS2' then begin IndicesStripPS2(STXM); KeyWordFind:=true; end;
  if KWord='Indices' then begin Indices(STXM); KeyWordFind:=true; end;
  if KWord='BoundingSphere' then begin BoundingSphere(STXM); KeyWordFind:=true; end;
  if KWord='BoundingBox' then begin BoundingBox(STXM); KeyWordFind:=true; end;
  if KWord='SubSetPS2' then begin SubSetPS2(STXM); KeyWordFind:=true; end;
  if KWord='Subset' then begin Subset(STXM); KeyWordFind:=true; end;
  if KWord='LODPhases' then begin LODPhases(STXM); KeyWordFind:=true; end;

 Until not KeyWordFind or EOF(FTXM);

  { calculer la longueur de la section }
 LI:=FileSize(FMmod)-p-4;

  { �crire la longueur de la section }
 Seek(FMmod,p);
 WriteLI(LI);

  { se replacer � la fin du fichier}
 Seek(FMmod,FileSize(FMmod));

end;

Procedure Identifier(var STXM : string);
var
 LI,
 p : longint;   { position de la longueur de la section }
begin
  { �crire la longueur de 'Mesh' }
 WriteLI(Length('Identifier'));

  { �crire le mot cle }
 WriteTXT('Identifier');

  { M�moriser la position dans le fichier }
 P:=FilePos(FMmod);

  { �crire zero dans la longueur en attendant de connaitre la bonne valeur }
 WriteLI(0);

  { Ejecter le mot cle au d�but de la chaine de caract�re }
 EjectTxt(STXM,length('Identifier'));

  { lire la ligne suivante }
 STXM:=ReadFTXM;

  { �crire le longueur du nom }
 WriteLI(Length(STXM));

  { �crire le nom }
 WriteTxt(STXM);

  { lire la ligne suivante }
 STXM:=ReadFTXM;

  { �crire le num�ro associ� }
 WriteLI(NumberLI(STXM));

  { calculer la longueur de la section }
 LI:=FileSize(FMmod)-p-4;

  { �crire la longueur de la section }
 Seek(FMmod,p);
 WriteLI(LI);

  { se replacer � la fin du fichier}
 Seek(FMmod,FileSize(FMmod));

end;

Procedure Category(var STXM : string);
var
 LI,
 p : longint;   { m�morise � la position de la longueur du bloc }
begin
  { �crire la longueur de 'Category' }
 WriteLI(Length('Category'));

  { �crire le mot cle }
 WriteTXT('Category');

  { M�moriser la position dans le fichier }
 P:=FilePos(FMmod);

  { �crire zero dans la longueur en attendant de connaitre la bonne valeur }
 WriteLI(0);

  { �crire 0 dans la longueur du mot en attendant de connaitre la bonne valeur }
 WriteLI(0);

  { lire la ligne suivante dans le fichier source }
 STXM:=ReadFTXM;

  { �crire le mot }
 WriteTxt(STXM);

  { calculer la longueur de la section }
 LI:=FileSize(FMmod)-p-4;

  { �crire la longueur de la section }
 Seek(FMmod,p);
 WriteLI(LI);

  {�crire la longueur du mot }
 WriteLI(LI-4);

  {se positionner � la fin du fichier }
 seek(FMmod,filesize(FMmod));

 STXM:='';

end;

Procedure Points(var STXM : string);
var
 LI,
 p : longint;   { m�morise � la position de la longueur du bloc }
begin
  { �crire la longueur de 'Points' }
 WriteLI(Length('Points'));

  { �crire le mot cle }
 WriteTXT('Points');

  { M�moriser la position dans le fichier }
 P:=FilePos(FMmod);

  { �crire zero dans la longueur en attendant de connaitre la bonne valeur }
 WriteLI(0);

  { lire la ligne suivante dans le fichier source }
 STXM:=ReadFTXM;

 while (not CharOfTextInList(STXM,ListLetter)) and not(EOF(FTXM)) do begin

   { ce texte ne contient pas de lettre : lire les nombres et les �crire dans le fichier destination }

   { lire 3 reels et les �crire }
  WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));

   { lire la ligne suivante dans le fichier source }
  STXM:=ReadFTXM;

 end;

  { calculer la longueur de la section }
 LI:=FileSize(FMmod)-p-4;

  { �crire la longueur de la section }
 Seek(FMmod,p);
 WriteLI(LI);

  {se positionner � la fin du fichier }
 seek(FMmod,filesize(FMmod));

end;

Procedure Aux(var STXM : string);
var
 KeyWordFind : boolean;
 KWord : string;
 LI,
 p : longint;          { pointe sur l'emplacement de la longueur de la section }
begin
  { �crire la longueur de 'Aux' }
 WriteLI(Length('Aux'));

  { �crire le mot cle }
 WriteTXT('Aux');

  { M�moriser la position dans le fichier }
 P:=FilePos(FMmod);

  { �crire zero dans la longueur en attendant de connaitre la bonne valeur }
 WriteLI(0);

  { lire la ligne suivante dans le fichier source }
 STXM:=ReadFTXM;

 Repeat

   {si STXM est vide, alors lire la ligne suivante }
  if EjectAllPresentKey(STXM) ='' then STXM:=ReadFTXM;

   { Extraire le mot clef }
  KWord:=KeyWord(STXM);

   { ex�cuter la proc�dure correspondant au mot cle trouv� }
  KeyWordFind:=false;
  if KWord='Identifier' then begin Identifier(STXM); KeyWordFind:=true; end;
  if KWord='Category' then begin Category(STXM); KeyWordFind:=true; end;
  if KWord='Points' then begin Points(STXM); KeyWordFind:=true; end;

 Until not KeyWordFind or EOF(FTXM);

  { calculer la longueur de la section }
 LI:=FileSize(FMmod)-p-4;

  { �crire la longueur de la section }
 Seek(FMmod,p);
 WriteLI(LI);

  { se replacer � la fin du fichier}
 Seek(FMmod,FileSize(FMmod));

end;

Procedure GeomMesh(var STXM : string);
var
 NbLTab,                     { Nb de ligne du tableau }
 NbIndices,                  { Nb d'indices }
 NbName,                     { Nb d'�l�ments }
 NbPoints,                   { nombre de points }
 LI,
 p1,                         { poiteur provisoir }
 p : longint;                { m�morise la position de la longueur de le section }

begin
  { �crire la longueur de 'GeomMesh' }
 WriteLI(Length('GeomMesh'));

  { �crire le mot cle }
 WriteTXT('GeomMesh');

  { M�moriser la position dans le fichier }
 P:=FilePos(FMmod);

  { �crire zero dans la longueur en attendant de connaitre la bonne valeur }
 WriteLI(0);

  { �crire zero dans le nombre d'�l�ment en attendant de connaitre la bonne valeur }
 WriteLI(0);

  { initialiser le nombre d'�l�ments }
 NbName:=0;

 Repeat

   { lire la ligne suivante }
  STXM:=ReadFTXM;

  if not (STXM='END') then begin
    { cette ligne contient un �l�ment : le lire et l'�crire }

    { �crire la longueur du mot }
   WriteLI(Length(STXM));

    { �crire le mot }
   WriteTxt(STXM);

    { lire la ligne suivante }
   STXM:=ReadFTXM;

    { Ecrire le nombre associ� }
   WriteLI(NumberLI(STXM));

   inc(NbName);
  end;
 Until (EjectAllPresentKey(STXM)='END') or EOF(FTXM);

  {se positionner sur le Nombre d'�l�ments }
 seek(FMmod,p+4);

  { �crire le nombre d'�l�ments }
 WriteLI(NbName);

  { se replacer � la fin du fichier }
 seek(FMmod,FileSize(FMmod));

  { m�moriser la position du nombre de points }
 p1:=FilePos(FMmod);

  { �crire zero dans le nombre de points en attendant de connaitre la bonne valeur }
 WriteLI(0);

  { initialiser NbPoints }
 NbPoints:=0;

 Repeat

   { lire la ligne suivante }
  STXM:=ReadFTXM;

  if not (EjectAllPresentKey(STXM)='END') then begin
    { cette ligne contient un �l�ment : le lire et l'�crire }

    { lire et �crire 3 reels }
   WriteR(NumberR(STXM)); WriteR(NumberR(STXM)); WriteR(NumberR(STXM));

   inc(NbPoints);

  end;

 Until (EjectAllPresentKey(STXM)='END') or EOF(FTXM);

   {se positionner sur le Nombre de points }
 seek(FMmod,p1);

  { �crire le nombre de points }
 WriteLI(NbPoints);

  { se replacer � la fin du fichier }
 seek(FMmod,FileSize(FMmod));

  { m�moriser la position du nombre d'indices }
 p1:=FilePos(FMmod);

  { �crire zero dans le nombre d'indices en attendant de connaitre la bonne valeur }
 WriteLI(0);

  { initialiser le nombre d'indices }
 NbIndices:=0;

 Repeat

   { lire la ligne suivante }
  STXM:=ReadFTXM;

  if not (EjectAllPresentKey(STXM)='END') then begin
    { cette ligne contient un �l�ment : le lire et l'�crire }

    { lire et �crire 2 entiers }
   WriteLI(NumberLI(STXM)); WriteLI(NumberLI(STXM));

   inc(NbIndices);

  end;

 Until (EjectAllPresentKey(STXM)='END') or EOF(FTXM);

   {se positionner sur le Nombre d'indices }
 seek(FMmod,p1);

  { �crire le nombre d'indices }
 WriteLI(NbIndices);

   { se replacer � la fin du fichier }
 seek(FMmod,FileSize(FMmod));

  { m�moriser la position du nombre de ligne de table }
 p1:=FilePos(FMmod);

  { �crire zero dans le nombre de ligne de la table en attendant de connaitre la bonne valeur }
 WriteLI(0);

  { initialiser le nombre de lignes du tableau }
 NbLTab:=0;

  { lire la ligne suivante dans le fichier source }
 STXM:=ReadFTXM;

 while (not CharOfTextInList(STXM,ListLetter)) and not(EOF(FTXM)) do begin

   { ce texte ne contient pas de lettre : lire les nombres et les �crire dans le fichier destination }

   { lire 8 entiers long et les �crire }
  WriteLI(NumberLI(STXM));WriteLI(NumberLI(STXM));WriteLI(NumberLI(STXM));WriteLI(NumberLI(STXM));
  WriteLI(NumberLI(STXM));WriteLI(NumberLI(STXM));WriteLI(NumberLI(STXM));WriteLI(NumberLI(STXM));

  inc(NbLTab);

   { lire la ligne suivante dans le fichier source }
  STXM:=ReadFTXM;

 end;

   {se positionner sur le Nombre de lignes du tableau }
 seek(FMmod,p1);

  { �crire le nombre d'indices }
 WriteLI(NbLTab);

  { calculer la longueur de la section }
 LI:=FileSize(FMmod)-p-4;

  { �crire la longueur de la section }
 Seek(FMmod,p);
 WriteLI(LI);

  { se replacer � la fin du fichier}
 Seek(FMmod,FileSize(FMmod));

end;

Procedure ConvexObject(var STXM : string);
var
 i : integer;
 NbObject,              { nombre d'objets }
 NbSubObject,           { nombre de sous-objets }
 LI,
 p,                     { position de la longueur de la section }
 pObj,                  { position du nombre d'object }
 pSubObj : longint;     { position du nombre de sous objet }
begin
  { �crire la longueur de 'ConvexObject' }
 WriteLI(Length('ConvexObject'));

  { �crire le mot cle }
 WriteTXT('ConvexObject');

  { M�moriser la position dans le fichier }
 P:=FilePos(FMmod);

  { �crire zero dans la longueur en attendant de connaitre la bonne valeur }
 WriteLI(0);

  { �jecter le mot cle du d�but de la STXM }
 EjectTxt(STXM, length('ConvexObject'));

  { v�rifier s'il reste quelque chose � lire, si oui �crire le nombre entier pr�sent }
 if EjectAllPresentKey(STXM)<>'' then WriteLI(NumberLI(STXM));

  { 1 ere SECTION ============================================================================== }

  { initialiser le nombre d'objets }
 NbObject:=0;

  { M�moriser la position du nombre d'objets de la premiere section }
 pObj:=FilePos(FMmod);

  { �crire zero dans la longueur en attendant de connaitre la bonne valeur }
 WriteLI(0);

 Repeat

  STXM:=ReadFTXM;

  if not (EjectAllPresentKey(STXM)='END') and not (EOF(FTXM))then begin
   { cette ligne contient un �l�ment : le lire et l'�crire }

    { lire et �crire 3 nombres re�ls }

   WriteR(NumberR(STXM)); WriteR(NumberR(STXM)); WriteR(NumberR(STXM));

   for i:=1 to 3 do begin

     { m�moriser la position du nombre d'�l�ments de la sous-section }
    pSubObj:=FilePos(FMmod);

     { �crire zero dans la longueur en attendant de connaitre la bonne valeur }
    WriteLI(0);

     { lire la ligne suivante }
    STXM:=ReadFTXM;

     { initialiser le nombre de sous-objets }
    NbSubObject:=0;

     { tant qu'il y a quelque chose d'�crit, lire le nombre suivant et incr�menter NbSubObject }
    while EjectAllPresentKey(STXM)<>'' do begin

      { lire et �crire 1 nombre entier }
     WriteLI(NumberLI(STXM));

     inc(NbSubObject);

    end;

     {se positionner sur le Nombre de sous-objets }
    seek(FMmod,pSubObj);

     { �crire le nombre de sous objets }
    WriteLI(NbSubObject);

     { se replacer � la fin du fichier }
    seek(FMmod,FileSize(FMmod));

   end;

   inc(NbObject);

  end;

 Until (EjectAllPresentKey(STXM)='END') or EOF(FTXM);

   {se positionner sur le Nombre d'objets }
 seek(FMmod,pObj);

  { �crire le nombre d'indices }
 WriteLI(NbObject);

  { se replacer � la fin du fichier}
 Seek(FMmod,FileSize(FMmod));

  { 2 eme SECTION ============================================================================== }

  { initialiser le nombre d'objets }
 NbObject:=0;

  { M�moriser la position du nombre d'objets de la premiere section }
 pObj:=FilePos(FMmod);

  { �crire zero dans la longueur en attendant de connaitre la bonne valeur }
 WriteLI(0);

 Repeat

  STXM:=ReadFTXM;

  if not (EjectAllPresentKey(STXM)='END') and not (EOF(FTXM))then begin
   { cette ligne contient un �l�ment : le lire et l'�crire }

    { lire et �crire 3 nombres re�ls }

   WriteR(NumberR(STXM)); WriteR(NumberR(STXM)); WriteR(NumberR(STXM));

   for i:=1 to 2 do begin

     { m�moriser la position du nombre d'�l�ments de la sous-section }
    pSubObj:=FilePos(FMmod);

     { �crire zero dans la longueur en attendant de connaitre la bonne valeur }
    WriteLI(0);

     { lire la ligne suivante }
    STXM:=ReadFTXM;

     { initialiser le nombre de sous-objets }
    NbSubObject:=0;

     { tant qu'il y a quelque chose d'�crit, lire le nombre suivant et incr�menter NbSubObject }
    while EjectAllPresentKey(STXM)<>'' do begin

      { lire et �crire 1 nombre entier }
     WriteLI(NumberLI(STXM));

     inc(NbSubObject);

    end;

     {se positionner sur le Nombre de sous-objets }
    seek(FMmod,pSubObj);

     { �crire le nombre de sous objets }
    WriteLI(NbSubObject);

     { se replacer � la fin du fichier }
    seek(FMmod,FileSize(FMmod));

   end;

   inc(NbObject);

  end;

 Until (EjectAllPresentKey(STXM)='END') or EOF(FTXM);

  { se positionner sur le Nombre d'objets }
 seek(FMmod,pObj);

  { �crire le nombre d'objets }
 WriteLI(NbObject);

  { se replacer � la fin du fichier}
 Seek(FMmod,FileSize(FMmod));

  { 3 eme SECTION ============================================================================== }

  { M�moriser la position du nombre d'objets }
 PObj:=FilePos(FMmod);

  { �crire zero dans la longueur en attendant de connaitre la bonne valeur }
 WriteLI(0);

 { lire la section }
 { initialiser le nombre d'objets }
 NbObject:=0;

 Repeat

   { lire la ligne suivante }
  STXM:=ReadFTXM;

  if not (EjectAllPresentKey(STXM)='END') and not (EOF(FTXM))then begin
    { cette ligne contient un �l�ment : le lire et l'�crire }

    { lire et �crire 5 nombres re�ls }
   WriteR(NumberR(STXM)); WriteR(NumberR(STXM)); WriteR(NumberR(STXM)); WriteR(NumberR(STXM)); WriteR(NumberR(STXM));

   inc(NbObject);

  end;
 Until (EjectAllPresentKey(STXM)='END') or EOF(FTXM);

  {se positionner sur le Nombre d'objets }
 seek(FMmod,pObj);

  { �crire le nombre d'objets }
 WriteLI(NbObject);

  { se replacer � la fin du fichier }
 seek(FMmod,FileSize(FMmod));

   { m�moriser la position du nombre d'objets }
 pObj:=FilePos(FMmod);

  { �crire zero dans le nombre de ligne de la table en attendant de connaitre la bonne valeur }
 WriteLI(0);

  { initialiser le nombre de lignes du tableau }
 NbObject:=0;

  { lire la ligne suivante dans le fichier source }
 STXM:=ReadFTXM;

 while (not CharOfTextInList(STXM,ListLetter)) and not(EOF(FTXM)) do begin

   { ce texte ne contient pas de lettre : lire les nombres et les �crire dans le fichier destination }

   { lire 3 r�els et les �crire }
  WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));

  inc(NbObject);

   { lire la ligne suivante dans le fichier source }
  STXM:=ReadFTXM;

 end;

   {se positionner sur le Nombre d'objets }
 seek(FMmod,pObj);

  { �crire le nombre d'objets }
 WriteLI(NbObject);

  { calculer la longueur de la section }
 LI:=FileSize(FMmod)-p-4;

  { �crire la longueur de la section }
 Seek(FMmod,p);
 WriteLI(LI);

  { se replacer � la fin du fichier}
 Seek(FMmod,FileSize(FMmod));

end;

Procedure Note(var STXM : string);
begin
   { �crire la longueur de 'Note' }
 WriteLI(Length('Note'));

  { �crire le mot cle }
 WriteTXT('Note');

  { �jecter le mot cle du d�but de la STXM }
 EjectTxt(STXM, length('Note'));

  { �jecter les premiers caract�res de pr�sentation }
 STXM:=EjectFirstPresentKey(STXM);

  { �crire la longueur de la section }
 WriteLI(Length(STXM)+4);

  { �crire la longueur du texte }
 WriteLI(Length(STXM));

  { �crire le texte }
 WriteTxt(STXM);

 STXM:='';
end;

Procedure GroupParams(var STXM : string);
begin
   { �crire la longueur de 'GroupParams' }
 WriteLI(Length('GroupParams'));

  { �crire le mot cle }
 WriteTXT('GroupParams');

  { �jecter le mot cle du d�but de la STXM }
 EjectTxt(STXM, length('GroupParams'));

  { �crire le nombre '4'}
 WriteLI(4);

  { lire et �crire 1 nombre r�el }
 WriteR(NumberR(STXM));

end;

Procedure Geom(var STXM : string);
begin
  STXM:='A1';
end;

Procedure SceneError(var STXM : string);
begin
  { �jecter la ligne suivante }
 STXM:=ReadFTXM;
 STXM:='';
end;

Procedure WeightMapNames(var STXM : string);
var
 LI,
 p,                 { position de la longueur de la section }
 NbName : longint;  { nombre de noms }
begin
  { �crire la longueur de 'WeightMapNames' }
 WriteLI(Length('WeightMapNames'));

  { �crire le mot cle }
 WriteTXT('WeightMapNames');

  { M�moriser la position dans le fichier }
 P:=FilePos(FMmod);

  { �crire zero dans la longueur en attendant de connaitre la bonne valeur }
 WriteLI(0);

 Repeat

   { lire la ligne suivante }
  STXM:=ReadFTXM;

  if STXM<>'END' then begin

   inc(NbName);

    { �crire la longueur du nom }
   WriteLI(Length(STXM));

    { �crire le nom }
   WriteTXT(STXM);

  end;
 until (STXM='END') or (EOF(FTXM));

  { calculer la longueur de la section }
 LI:=FileSize(FMmod)-p-4;

  { �crire la longueur de la section }
 Seek(FMmod,p);
 WriteLI(LI);

  { se replacer � la fin du fichier}
 Seek(FMmod,FileSize(FMmod));

 STXM:='';

end;

Procedure MatrixIndexedMesh(var STXM : string);
var
 KeyWordFind : boolean;
 KWord : string;
 LI,
 p : longint;          { pointe sur l'emplacement de la longueur de la section }
begin
  { �crire la longueur de 'MatrixIndexedMesh' }
 WriteLI(Length('MatrixIndexedMesh'));

  { �crire le mot cle }
 WriteTXT('MatrixIndexedMesh');

  { M�moriser la position dans le fichier }
 P:=FilePos(FMmod);

  { �crire zero dans la longueur en attendant de connaitre la bonne valeur }
 WriteLI(0);

  { Ejecter le mot cle au d�but de la chaine de caract�re }
 EjectTxt(STXM,length('MatrixIndexedMesh'));

  { Ecrire le nombre associ� }
 WriteLI(NumberLI(STXM));

  { lire la ligne suivante dans le fichier source }
 STXM:=EjectFirstPresentKey(ReadFTXM);

 Repeat

   {si STXM est vide, alors lire la ligne suivante }
  if EjectAllPresentKey(STXM) ='' then STXM:=ReadFTXM;

   { Extraire le mot clef }
  KWord:=KeyWord(STXM);

   { ex�cuter la proc�dure correspondant au mot cle trouv� }
  KeyWordFind:=false;
  if KWord='VertexStream' then begin VertexStream(STXM); KeyWordFind:=true; end;
  if KWord='Indices' then begin Indices(STXM); KeyWordFind:=true; end;
  if KWord='BoundingSphere' then begin BoundingSphere(STXM); KeyWordFind:=true; end;
  if KWord='BoundingBox' then begin BoundingBox(STXM); KeyWordFind:=true; end;
  if KWord='SubSetPS2' then begin SubSetPS2(STXM); KeyWordFind:=true; end;
  if KWord='Subset' then begin Subset(STXM); KeyWordFind:=true; end;
  if KWord='LODPhases' then begin LODPhases(STXM); KeyWordFind:=true; end;
  if KWord='WeightMapNames' then begin WeightMapNames(STXM); KeyWordFind:=true; end;

 Until not KeyWordFind or EOF(FTXM);

  { calculer la longueur de la section }
 LI:=FileSize(FMmod)-p-4;

  { �crire la longueur de la section }
 Seek(FMmod,p);
 WriteLI(LI);

  { se replacer � la fin du fichier}
 Seek(FMmod,FileSize(FMmod));

end;

Procedure CloudSystem(var STXM : string);
var
 NbPoints,         { Nb de points dans le nuage }
 LI,
 p : longint;      { position de la longueur de la section }
begin
   { �crire la longueur de 'CloudSystem' }
 WriteLI(Length('CloudSystem'));

  { �crire le mot cle }
 WriteTXT('CloudSystem');

  { M�moriser la position dans le fichier }
 P:=FilePos(FMmod);

  { �crire zero dans la longueur en attendant de connaitre la bonne valeur }
 WriteLI(0);

  { �crirezero dans le nombre d'indices en attendant de connaitre la bonne valeur }
 WriteLI(0);

  { initialiser le Nb de points }
 NbPoints:=0;

  { lire la ligne suivante dans le fichier source }
 STXM:=ReadFTXM;

 while (not CharOfTextInList(STXM,ListLetter)) and not(EOF(FTXM)) do begin

   { ce texte ne contient pas de lettre : lire les nombres et les �crire dans le fichier destination }
  inc(NbPoints);

   { lire 4 r�els et les �crire }
  WriteR(NumberR(STXM)); WriteR(NumberR(STXM)); WriteR(NumberR(STXM)); WriteR(NumberR(STXM));

   { lire la ligne suivante dans le fichier source }
  STXM:=ReadFTXM;

 end;

  { calculer la longueur de la section }
 LI:=FileSize(FMmod)-p-4;

  { �crire la longueur de la section }
 Seek(FMmod,p);
 WriteLI(LI);

  { �crire le nombre de points }
 WriteLI(NbPoints);

  {se positionner � la fin du fichier }
 seek(FMmod,filesize(FMmod));

end;

Procedure PositionX(var STXM : string);
begin
   { �crire la longueur de 'Position.X' }
 WriteLI(Length('Position.X'));

  { �crire le mot cle }
 WriteTXT('Position.X');

  { �jecter le mot cle du d�but de la STXM }
 EjectTxt(STXM, length('Position.X'));

  { lire et �crire les deux nombres associ�s }
 WriteLI(NumberLI(STXM)); WriteLI(NumberLI(STXM));

end;

Procedure PositionY(var STXM : string);
begin
   { �crire la longueur de 'Position.Y' }
 WriteLI(Length('Position.Y'));

  { �crire le mot cle }
 WriteTXT('Position.Y');

  { �jecter le mot cle du d�but de la STXM }
 EjectTxt(STXM, length('Position.Y'));

  { lire et �crire les deux nombres associ�s }
 WriteLI(NumberLI(STXM)); WriteLI(NumberLI(STXM));

end;

Procedure PositionZ(var STXM : string);
begin
   { �crire la longueur de 'Position.Z' }
 WriteLI(Length('Position.Z'));

  { �crire le mot cle }
 WriteTXT('Position.Z');

  { �jecter le mot cle du d�but de la STXM }
 EjectTxt(STXM, length('Position.Z'));

  { lire et �crire les deux nombres associ�s }
 WriteLI(NumberLI(STXM)); WriteLI(NumberLI(STXM));

end;

Procedure RotationH(var STXM : string);
begin
   { �crire la longueur de 'Rotation.H' }
 WriteLI(Length('Rotation.H'));

  { �crire le mot cle }
 WriteTXT('Rotation.H');

  { �jecter le mot cle du d�but de la STXM }
 EjectTxt(STXM, length('Rotation.H'));

  { lire et �crire les deux nombres associ�s }
 WriteLI(NumberLI(STXM)); WriteLI(NumberLI(STXM));

end;

Procedure RotationP(var STXM : string);
begin
   { �crire la longueur de 'Rotation.P' }
 WriteLI(Length('Rotation.P'));

  { �crire le mot cle }
 WriteTXT('Rotation.P');

  { �jecter le mot cle du d�but de la STXM }
 EjectTxt(STXM, length('Rotation.P'));

  { lire et �crire les deux nombres associ�s }
 WriteLI(NumberLI(STXM)); WriteLI(NumberLI(STXM));

end;

Procedure RotationB(var STXM : string);
begin
   { �crire la longueur de 'Rotation.B' }
 WriteLI(Length('Rotation.B'));

  { �crire le mot cle }
 WriteTXT('Rotation.B');

  { �jecter le mot cle du d�but de la STXM }
 EjectTxt(STXM, length('Rotation.B'));

  { lire et �crire les deux nombres associ�s }
 WriteLI(NumberLI(STXM)); WriteLI(NumberLI(STXM));

end;

Procedure ScaleX(var STXM : string);
begin
   { �crire la longueur de 'Scale.X' }
 WriteLI(Length('Scale.X'));

  { �crire le mot cle }
 WriteTXT('Scale.X');

  { �jecter le mot cle du d�but de la STXM }
 EjectTxt(STXM, length('Scale.X'));

  { lire et �crire les deux nombres associ�s }
 WriteLI(NumberLI(STXM)); WriteLI(NumberLI(STXM));

end;

Procedure ScaleY(var STXM : string);
begin
   { �crire la longueur de 'Scale.Y' }
 WriteLI(Length('Scale.Y'));

  { �crire le mot cle }
 WriteTXT('Scale.Y');

  { �jecter le mot cle du d�but de la STXM }
 EjectTxt(STXM, length('Scale.Y'));

  { lire et �crire les deux nombres associ�s }
 WriteLI(NumberLI(STXM)); WriteLI(NumberLI(STXM));

end;

Procedure ScaleZ(var STXM : string);
begin
   { �crire la longueur de 'Scale.Z' }
 WriteLI(Length('Scale.Z'));

  { �crire le mot cle }
 WriteTXT('Scale.Z');

  { �jecter le mot cle du d�but de la STXM }
 EjectTxt(STXM, length('Scale.Z'));

  { lire et �crire les deux nombres associ�s }
 WriteLI(NumberLI(STXM)); WriteLI(NumberLI(STXM));

end;

Procedure AnimationKey(var STXM : string);
begin
   { �crire la longueur de 'AnimationKey' }
 WriteLI(Length('AnimationKey'));

  { �crire le mot cle }
 WriteTXT('AnimationKey');

  { �crire le nombre '40' }
 WriteLI(40);

  { �jecter le mot cle du d�but de la STXM }
 EjectTxt(STXM, length('AnimationKey'));

  { lire et �crire le nombre associ� }
 WriteLI(NumberLI(STXM));

  { lire la ligne suivante }
 STXM:=ReadFTXM;

  { lire et �crire 9 nombres re�l }
 WriteR(NumberR(STXM)); WriteR(NumberR(STXM)); WriteR(NumberR(STXM)); WriteR(NumberR(STXM)); WriteR(NumberR(STXM));
 WriteR(NumberR(STXM)); WriteR(NumberR(STXM)); WriteR(NumberR(STXM)); WriteR(NumberR(STXM));

end;

Procedure ChannelAnimation(var STXM : string);
var
 KeyWordFind : boolean;
 KWord : string;
 LI,
 p : longint;          { pointe sur l'emplacement de la longueur de la section }
begin
  { �crire la longueur de 'ChannelAnimation' }
 WriteLI(Length('ChannelAnimation'));

  { �crire le mot cle }
 WriteTXT('ChannelAnimation');

  { M�moriser la position dans le fichier }
 P:=FilePos(FMmod);

  { �crire zero dans la longueur en attendant de connaitre la bonne valeur }
 WriteLI(0);

  { lire la ligne suivante dans le fichier source }
 STXM:=ReadFTXM;

 Repeat

   {si STXM est vide, alors lire la ligne suivante }
  if EjectAllPresentKey(STXM) ='' then STXM:=ReadFTXM;

   { Extraire le mot clef }
  KWord:=KeyWord(STXM);

   { ex�cuter la proc�dure correspondant au mot cle trouv� }
  KeyWordFind:=false;

  if KWord='Position.X' then begin PositionX(STXM); KeyWordFind:=true; end;
  if KWord='Position.Y' then begin PositionY(STXM); KeyWordFind:=true; end;
  if KWord='Position.Z' then begin PositionZ(STXM); KeyWordFind:=true; end;
  if KWord='Rotation.H' then begin RotationH(STXM); KeyWordFind:=true; end;
  if KWord='Rotation.P' then begin RotationP(STXM); KeyWordFind:=true; end;
  if KWord='Rotation.B' then begin RotationB(STXM); KeyWordFind:=true; end;
  if KWord='Scale.X' then begin ScaleX(STXM); KeyWordFind:=true; end;
  if KWord='Scale.Y' then begin ScaleY(STXM); KeyWordFind:=true; end;
  if KWord='Scale.Z' then begin ScaleZ(STXM); KeyWordFind:=true; end;
  if KWord='AnimationKey' then begin AnimationKey(STXM); KeyWordFind:=true; end;

 Until not KeyWordFind or EOF(FTXM);

  { calculer la longueur de la section }
 LI:=FileSize(FMmod)-p-4;

  { �crire la longueur de la section }
 Seek(FMmod,p);
 WriteLI(LI);

  { se replacer � la fin du fichier}
 Seek(FMmod,FileSize(FMmod));

end;

Procedure AnimationGroupName(var STXM : string);
var
 LI,
 p : longint;   { m�morise � la position de la longueur du bloc }
begin
  { �crire la longueur de 'AnimationGroupName' }
 WriteLI(Length('AnimationGroupName'));

  { �crire le mot cle }
 WriteTXT('AnimationGroupName');

  { M�moriser la position dans le fichier }
 P:=FilePos(FMmod);

  { �crire zero dans la longueur en attendant de connaitre la bonne valeur }
 WriteLI(0);

  { �crire 0 dans la longueur du mot en attendant de connaitre la bonne valeur }
 WriteLI(0);

  { lire la ligne suivante dans le fichier source }
 STXM:=ReadFTXM;

  { �crire le mot }
 WriteTxt(KeyWord(STXM));

  { Ejecter le mot cle au d�but de la chaine de caract�re }
 EjectTxt(STXM,length(KeyWord(STXM)));

  { calculer la longueur de la section }
 LI:=FileSize(FMmod)-p-4;

  { �crire la longueur de la section }
 Seek(FMmod,p);
 WriteLI(LI);

  {�crire la longueur du mot }
 WriteLI(LI-4);

  {se positionner � la fin du fichier }
 seek(FMmod,filesize(FMmod));

end;


Procedure AnimationChannels(var STXM : string);
var
 KeyWordFind : boolean;
 KWord : string;
 LI,
 p : longint;          { pointe sur l'emplacement de la longueur de la section }
begin
  { �crire la longueur de 'AnimationChannels' }
 WriteLI(Length('AnimationChannels'));

  { �crire le mot cle }
 WriteTXT('AnimationChannels');

  { M�moriser la position dans le fichier }
 P:=FilePos(FMmod);

  { �crire zero dans la longueur en attendant de connaitre la bonne valeur }
 WriteLI(0);

  { lire la ligne suivante dans le fichier source }
 STXM:=ReadFTXM;

 Repeat

   {si STXM est vide, alors lire la ligne suivante }
  if EjectAllPresentKey(STXM) ='' then STXM:=ReadFTXM;

   { Extraire le mot clef }
  KWord:=KeyWord(STXM);

   { ex�cuter la proc�dure correspondant au mot cle trouv� }
  KeyWordFind:=false;

  if KWord='AnimationGroupName' then begin AnimationGroupName(STXM); KeyWordFind:=true; end;
  if KWord='ChannelAnimation' then begin ChannelAnimation(STXM); KeyWordFind:=true; end;

 Until not KeyWordFind or EOF(FTXM);

  { calculer la longueur de la section }
 LI:=FileSize(FMmod)-p-4;

  { �crire la longueur de la section }
 Seek(FMmod,p);
 WriteLI(LI);

  { se replacer � la fin du fichier}
 Seek(FMmod,FileSize(FMmod));

end;

Procedure Resource(var STXM:string);
var
 KeyWordFind : boolean;
 KWord : string;
 LI,
 p : longint;          { pointe sur l'emplacement de la longueur de la section }
begin
  { �crire la longueur de 'Resource' }
 WriteLI(Length('Resource'));

  { �crire le mot cle }
 WriteTXT('Resource');

  { M�moriser la position dans le fichier }
 P:=FilePos(FMmod);

  { �crire zero dans la longueur en attendant de connaitre la bonne valeur }
 WriteLI(0);

  { lire la ligne suivante dans le fichier source }
 STXM:=ReadFTXM;

 Repeat

   {si STXM est vide, alors lire la ligne suivante }
  if EjectAllPresentKey(STXM) ='' then STXM:=ReadFTXM;

   { Extraire le mot clef }
  KWord:=KeyWord(STXM);

   { ex�cuter la proc�dure correspondant au mot cle trouv� }
  KeyWordFind:=false;

  if KWord='Mesh' then begin Mesh(STXM); KeyWordFind:=true; end;
  if KWord='Aux' then begin Aux(STXM); KeyWordFind:=true; end;
  if KWord='GeomMesh' then begin GeomMesh(STXM); KeyWordFind:=true; end;
  if KWord='ConvexObject' then begin ConvexObject(STXM); KeyWordFind:=true; end;
  if KWord='Note' then begin Note(STXM); KeyWordFind:=true; end;
  if KWord='GroupParams' then begin GroupParams(STXM); KeyWordFind:=true; end;
  if KWord='Geom' then begin Geom(STXM); KeyWordFind:=true; end;
  if KWord='SceneError' then begin SceneError(STXM); KeyWordFind:=true; end;
  if KWord='MatrixIndexedMesh' then begin MatrixIndexedMesh(STXM); KeyWordFind:=true; end;
  if KWord='CloudSystem' then begin CloudSystem(STXM); KeyWordFind:=true; end;
  if KWord='AnimationChannels' then begin AnimationChannels(STXM); KeyWordFind:=true; end;
  if StrMajuscule(KWord)='COMMAND' then begin Command(STXM); KeyWordFind:=true; end;

 Until not KeyWordFind or EOF(FTXM);

  { calculer la longueur de la section }
 LI:=FileSize(FMmod)-p-4;

  { �crire la longueur de la section }
 Seek(FMmod,p);
 WriteLI(LI);

  { se replacer � la fin du fichier}
 Seek(FMmod,FileSize(FMmod));

end;

Procedure MMOD(var STXM:string);
var
 KeyWordFind : boolean;
 KWord : string;
 LI,
 p : longint;          { pointe sur l'emplacement de la longueur de la section }
begin
  { �crire le longueur de 'MMOD' }
 WriteLI(Length('MMOD'));

  { �crire le mot cle }
 WriteTXT('MMOD');

  { M�moriser la position dans le fichier }
 P:=FilePos(FMmod);

  { �crire zero dans la longueur en attendant de connaitre la bonne valeur }
 WriteLI(0);

  { Ejecter le mot cle au d�but de la chaine de caract�re }
 EjectTxt(STXM,length('MMOD'));

  { Ecrire le nombre associ� }
 WriteLI(NumberLI(STXM));

  { lire la ligne suivante }
 STXM:=ReadFTXM;

 Repeat

   {si STXM est vide, alors lire la ligne suivante }
  if EjectAllPresentKey(STXM) ='' then STXM:=ReadFTXM;

   { Extraire le mot clef }
  KWord:=KeyWord(STXM);

   { ex�cuter la proc�dure correspondant au mot cle trouv� }
  KeyWordFind:=false;

  if KWord='BoundingSphere' then begin BoundingSphere(STXM); KeyWordFind:=true; end;
  if KWord='BoundingBox' then begin BoundingBox(STXM); KeyWordFind:=true; end;
  if KWord='Resource' then begin Resource(STXM); KeyWordFind:=true; end;
  if KWord='Hierarchy' then begin Hierarchy(STXM); KeyWordFind:=true; end;

 Until not KeyWordFind or EOF(FTXM);

  { calculer la longueur de la section }
 LI:=FileSize(FMmod)-p-4;

  { �crire la longueur de la section }
 Seek(FMmod,p);
 WriteLI(LI);

  { se replacer � la fin du fichier}
 Seek(FMmod,FileSize(FMmod));

end;

 {*****************************************************************************************************}
 { Converti le fichier TXM vers MMOD                                                                   }
 {*****************************************************************************************************}

Procedure ConvertTXM2Mmod;
var
 STXM : string;             { ligne lue dans le fichier source }
 KWord : string;            { mot clef trouv� }
 KeyWordFind : boolean;
begin
 STXM:='';
 repeat

   {si STXM est vide, alors lire la ligne suivante }
  if EjectAllPresentKey(STXM) ='' then STXM:=ReadFTXM;

  if STXM<>'' then begin
    { lire le mot clef }
   KWord:=KeyWord(STXM);

    { ex�cuter le proc�dure correspondant au mot clef trouv� }
   KeyWordFind:=false;
   if KWord='MMOD' then begin MMOD(STXM); KeyWordFind:=true; end;

    { si pas de mot clef trouv�, arr�ter le programme }
   if not KeyWordFind then Arreter;
  end;
 until EOF(FTXM);
end;

 {*****************************************************************************************************}
 { trouve tous les fichier source .TXM du r�pertoire et lance la conversion pour chacun d'eux          }
 {*****************************************************************************************************}

Procedure ConvertAllTXM2Mmod;
var
 F : SearchRec;                  { variable de fichier pour la recherche des fichier dans le r�pertoire courant }
 W : word;
 S,
 NameF : string;                 { stockage provisoir d'un nom de fichier }
 i,
 NbFile : integer;               { nombre de fichiers converstis }
 B : byte absolute NameF;        { pointe sur la longueur de NameF }
begin
 FindFirst('*.TXM',W,F);               { Trouver le 1er fichier .TXM }
 NbFile:=0;                            { initialiser le nombre de fichiers }

  { assigner le fichier RAPPORT }
 assign(FRapport,'RAPPORT.TXT');
 
 WriteLN('TXM to MMOD Converter v1.1');
 WriteLN;
 
 while DosError=0 do begin             { si le fichier existe, continuer }

   { contruire une chaine de caract�re comportant le nom du fichier .TXM trouv� }
  NameF:=F.Name;

   { v�rifier l'extension de fichier }
  if StrMajuscule(RightStr(NameF,4)) = '.TXM' then begin
	
    { afficher le nom de fichier source }
   WriteLN;
   WriteLN('----------------------------------------------------------------');
   Write('Found '+NameF+', converting to ');

    { assigner le fichier source }
   assign(FTXM,NameF);

    { construire le nom du fichier de destination }
   dec(B,3);                { retirer les 3 derniers caract�res - l'extension }

    { afficher le nom de fichier destination }
   WriteLN(NameF+'mmod');
   WriteLN;
   WriteLN('TXM lines processed:');
   Write('        ');

    {assigner le fichier destination }
   assign(FMmod,NameF+'mmod');

    { assigner le fichier de comparaison }
   assign(FComp,NameF+'M2');

    {Initialiser les fichier}
   Reset(FTXM);
   Rewrite(FMmod,1);
   Rewrite(FRapport);

   {$i-}
   Reset(FComp,1);
   {$i+}

    { regarder s'il y a un fichier � comparer }
   if IOResult=0 then Comparer:=true else Comparer:=false;

    { s'il le faut, initialiser le fichier rapport de comparaison }
   if Comparer then begin
    assign(FRComp,NameF+'TXC');
    Rewrite(FRComp);
    WriteLN(FRComp,'Fichier converti : '+NameF);
   end;

    { ecrire l'entete dans le fichier rapport }
   WriteLN(FRapport,'Converted file: '+NameF);
   WriteLN(FRapport);
   WriteLN(FRapport,'If there was a conversion error, scroll down to the very bottom of this file to see the line at which the error occured.');
   WriteLN(FRapport);
   WriteLN(FRapport,'Common TXM errors:');
   WriteLN(FRapport,'- Presence of the "Nan" or "+/-Inf" errors');
   WriteLN(FRapport,'- Presence of absurdly large float values');
   WriteLN(FRapport,'- Invalid texture file names');
   WriteLN(FRapport,'- Lack of a "LODPhases" section right before an "Aux" entry');
   WriteLN(FRapport);
   WriteLN(FRapport,'-------- TXM START --------');

    { initialiser le nombre de lignes compil�es }
   NLineCompiled:=0;

   inc(NbFile);                    { + 1 fichier }

    { Creer le fichier Mmod � partir du fichier TXM }
   ConvertTXM2Mmod;

    { afficher � l'�cran : 'completed'); }
   writeLN;
   writeLN('completed.');
   WriteLN('----------------------------------------------------------------');
   WriteLN;

    {fermer les fichiers }
   close(FTXM);
   close(FMmod);
   close(FRapport);
   erase(FRapport);
   if comparer then close(FRComp);

  end;

   { rechercher le fichier suivant }
  FindNext(F);
 end;

  { affichage pour information de l'utilisateur }
 WriteLN; WriteLN;

 if NbFile=0 then
  WriteLN('ERROR: No TXM file found in directory!')
 else
  if NbFile=1 then WriteLN('1 file succesfully converted!')
   else WriteLN(NbFile,' files successfully converted!');

 WriteLN('Press "ENTER" to exit.');
 ReadLN(S);

end;

begin

  {lancer la conversion de tous les fichier TXM pr�sent dans le r�pertoire }
 ConvertAllTXM2Mmod;

end.
