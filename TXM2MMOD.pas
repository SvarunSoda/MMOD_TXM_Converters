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
 { Liste des procédures écrivant dans le fichier FMod.                                                 }
 { La variable STXM retourne la dernière ligne lue et invalide car destinée à la commande suivante.    }
 { Cette variable est mise à '' si la struture étant connue, la ligne suivante n'a pas été lue.        }
 {*****************************************************************************************************}
 {*****************************************************************************************************}
 {*****************************************************************************************************}

Procedure BoundingSphere(var STXM : string);
begin

  { écrire le longueur du mot cle }
 WriteLI(Length('BoundingSphere'));

  { écrire le mot clé }
 WriteTXT('BoundingSphere');

  { écrire le longueur de la section }
 WriteLI(16);

  { lire la ligne suivante dans le fichier source }
 STXM:=ReadFTXM;

  { écrire les valeurs des nombres }
 WriteR(NumberR(STXM)); WriteR(NumberR(STXM)); WriteR(NumberR(STXM)); WriteR(NumberR(STXM));

end;

Procedure BoundingBox(var STXM : string);
begin

  { écrire le longueur du mot cle }
 WriteLI(Length('BoundingBox'));

  { écrire le mot clé }
 WriteTXT('BoundingBox');

  { écrire le longueur de la section }
 WriteLI(24);

  { lire la ligne suivante dans le fichier source }
 STXM:=ReadFTXM;

  { écrire les valeurs des nombres }
 WriteR(NumberR(STXM)); WriteR(NumberR(STXM)); WriteR(NumberR(STXM));

  { lire la ligne suivante dans le fichier source }
 STXM:=ReadFTXM;

  { écrire les valeurs des nombres }
 WriteR(NumberR(STXM)); WriteR(NumberR(STXM)); WriteR(NumberR(STXM));

end;

Procedure Name(var STXM : string);
begin
  { écrire la longueur de 'Name' }
 WriteLI(Length('Name'));

  { écrire le mot cle }
 WriteTXT('Name');

  { Ejecter le mot cle au début de la chaine de caractère }
 EjectTxt(STXM,length('Name'));

  { Ejecter les premiere caractères de présentation }
 STXM:=EjectFirstPresentKey(STXM);

  {écrire les longueurs }
 WriteLI(Length(STXM)+4);
 WriteLI(Length(STXM));

  { écrire la texture }
 WriteTxt(STXM);

 STXM:='';
end;

Procedure Matrix(var STXM : string);
begin
  { écrire la longueur de 'Matrix' }
 WriteLI(Length('Matrix'));

  { écrire le mot cle }
 WriteTXT('Matrix');

  { écrire la longueur 64 }
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
  { écrire la longueur de 'Resource' }
 WriteLI(Length('Resource'));

  { écrire le mot cle }
 WriteTXT('Resource');

  { écrire la longueur=4 (pour 1 longint) }
 WriteLI(4);

  { Ejecter le mot cle au début de la chaine de caractère }
 EjectTxt(STXM,length('Resource'));

  { écrire le nombre associé }
 WriteLI(NumberLI(STXM));

end;

Procedure Flags(var STXM : string);
begin
  { écrire la longueur de 'Flags' }
 WriteLI(Length('Flags'));

  { écrire le mot cle }
 WriteTXT('Flags');

  { écrire la longueur=4 (pour 1 longint) }
 WriteLI(4);

  { Ejecter le mot cle au début de la chaine de caractère }
 EjectTxt(STXM,length('Flags'));

  { écrire le nombre associé }
 WriteLI(NumberLI(STXM));

end;

Procedure Parent(var STXM : string);
begin
  { écrire la longueur de 'Parent' }
 WriteLI(Length('Parent'));

  { écrire le mot cle }
 WriteTXT('Parent');

  { Ejecter le mot cle au début de la chaine de caractère }
 EjectTxt(STXM,length('Parent'));

  { Ecrire le nombre 4 }
 WriteLI(4);

  { Ecrire le nombre associé }
 WriteLI(NumberLI(STXM));

end;

Procedure Item(var STXM : string);
var
 KeyWordFind : boolean;
 KWord : string;
 LI,
 p : longint;        { position de la longueur de la section }
begin
  { écrire la longueur de 'Item' }
 WriteLI(Length('Item'));

  { écrire le mot cle }
 WriteTXT('Item');

  { Mémoriser la position dans le fichier }
 P:=FilePos(FMmod);

  { écrire zero dans la longueur en attendant de connaitre la bonne valeur }
 WriteLI(0);

  { lire la ligne suivante dans le fichier source }
 STXM:=ReadFTXM;

 Repeat

   {si STXM est vide, alors lire la ligne suivante }
  if EjectAllPresentKey(STXM) ='' then STXM:=ReadFTXM;

   { Extraire le mot clef }
  KWord:=KeyWord(STXM);

   { exécuter la procédure correspondant au mot cle trouvé }
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

  { écrire la longueur de la section }
 Seek(FMmod,p);
 WriteLI(LI);

  { se replacer à la fin du fichier}
 Seek(FMmod,FileSize(FMmod));

end;

Procedure Hierarchy(var STXM : string);
var
 KeyWordFind : boolean;
 KWord : string;
 LI,
 p : longint;        { position de la longueur de la section }
begin
  { écrire la longueur de 'Hierarchy' }
 WriteLI(Length('Hierarchy'));

  { écrire le mot cle }
 WriteTXT('Hierarchy');

  { Mémoriser la position dans le fichier }
 P:=FilePos(FMmod);

  { écrire zero dans la longueur en attendant de connaitre la bonne valeur }
 WriteLI(0);

  { lire la ligne suivante dans le fichier source }
 STXM:=ReadFTXM;

 Repeat

   {si STXM est vide, alors lire la ligne suivante }
  if EjectAllPresentKey(STXM) ='' then STXM:=ReadFTXM;

   { Extraire le mot clef }
  KWord:=KeyWord(STXM);

   { exécuter la procédure correspondant au mot cle trouvé }
  KeyWordFind:=false;
  if KWord='Item' then begin Item(STXM); KeyWordFind:=true; end;

 Until not KeyWordFind or EOF(FTXM);

  { calculer la longueur de la section }
 LI:=FileSize(FMmod)-p-4;

  { écrire la longueur de la section }
 Seek(FMmod,p);
 WriteLI(LI);

  { se replacer à la fin du fichier}
 Seek(FMmod,FileSize(FMmod));

end;

Procedure ShipMvfm(var STXM : string; var NbVertex : longint);
begin
  { écrire la longueur de 'ship.mvfm' }
 WriteLI(Length('ship.mvfm'));

  { écrire le mot cle }
 WriteTXT('ship.mvfm');

  { initialiser NbVertex }
 NbVertex:=0;

  { lire la ligne suivante dans le fichier source }
 STXM:=ReadFTXM;

 while (not CharOfTextInList(STXM,ListLetter)) and (not EOF(FTXM)) do begin

   { ce texte ne contient pas de lettre : lire les nombres et les écrire dans le fichier destination }
  inc(NbVertex);

   { lire 16 rééls et les écrire }
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
  { écrire la longueur de 'shipvc.mvfm' }
 WriteLI(Length('shipvc.mvfm'));

  { écrire le mot cle }
 WriteTXT('shipvc.mvfm');

  { initialiser NbVertex }
 NbVertex:=0;

  { lire la ligne suivante dans le fichier source }
 STXM:=ReadFTXM;

 while (not CharOfTextInList(STXM,ListLetter)) and (not EOF(FTXM)) do begin

   { ce texte ne contient pas de lettre : lire les nombres et les écrire dans le fichier destination }
  inc(NbVertex);

   { lire 16 rééls et les écrire }
  WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));
  WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));
  WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));
  WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));

   { lire 4 octets et les écrit }
  WriteB(NumberB(STXM));WriteB(NumberB(STXM));WriteB(NumberB(STXM));WriteB(NumberB(STXM));

   { lire la ligne suivante dans le fichier source }
  STXM:=ReadFTXM;

 end;
end;

Procedure RopeMvfm(var STXM : string; var NbVertex : longint);
begin
  { écrire la longueur de 'rope.mvfm' }
 WriteLI(Length('rope.mvfm'));

  { écrire le mot cle }
 WriteTXT('rope.mvfm');

  { initialiser NbVertex }
 NbVertex:=0;

  { lire la ligne suivante dans le fichier source }
 STXM:=ReadFTXM;

 while (not CharOfTextInList(STXM,ListLetter)) and (not EOF(FTXM)) do begin

   { ce texte ne contient pas de lettre : lire les nombres et les écrire dans le fichier destination }
  inc(NbVertex);

   { lire 9 rééls et les écrire }
  WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));
  WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));
  WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));

   { lire la ligne suivante dans le fichier source }
  STXM:=ReadFTXM;

 end;
end;

Procedure SimpleMvfm(var STXM : string; var NbVertex : longint);
begin
  { écrire la longueur de 'simple.mvfm' }
 WriteLI(Length('simple.mvfm'));

  { écrire le mot cle }
 WriteTXT('simple.mvfm');

  { initialiser NbVertex }
 NbVertex:=0;

  { lire la ligne suivante dans le fichier source }
 STXM:=ReadFTXM;

 while (not CharOfTextInList(STXM,ListLetter)) and (not EOF(FTXM)) do begin

   { ce texte ne contient pas de lettre : lire les nombres et les écrire dans le fichier destination }
  inc(NbVertex);

   { lire 8 rééls et les écrire }
  WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));
  WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));

   { lire la ligne suivante dans le fichier source }
  STXM:=ReadFTXM;

 end;
end;

Procedure GunVcMvfm(var STXM : string; var NbVertex : longint);
begin
  { écrire la longueur de 'gunvc.mvfm' }
 WriteLI(Length('gunvc.mvfm'));

  { écrire le mot cle }
 WriteTXT('gunvc.mvfm');

  { initialiser NbVertex }
 NbVertex:=0;

  { lire la ligne suivante dans le fichier source }
 STXM:=ReadFTXM;

 while (not CharOfTextInList(STXM,ListLetter)) and (not EOF(FTXM)) do begin

   { ce texte ne contient pas de lettre : lire les nombres et les écrire dans le fichier destination }
  inc(NbVertex);

   { lire 8 réél et les écrire }
  WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));
  WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));

   { lire 4 octets et les écrit }
  WriteB(NumberB(STXM));WriteB(NumberB(STXM));WriteB(NumberB(STXM));WriteB(NumberB(STXM));

   { lire la ligne suivante dans le fichier source }
  STXM:=ReadFTXM;

 end;
end;

Procedure SimpleIndexedMvfm(var STXM : string; var NbVertex : longint);
begin
  { écrire la longueur de 'simpleindexed.mvfm' }
 WriteLI(Length('simpleindexed.mvfm'));

  { écrire le mot cle }
 WriteTXT('simpleindexed.mvfm');

  { initialiser NbVertex }
 NbVertex:=0;

  { lire la ligne suivante dans le fichier source }
 STXM:=ReadFTXM;

 while (not CharOfTextInList(STXM,ListLetter)) and (not EOF(FTXM)) do begin

   { ce texte ne contient pas de lettre : lire les nombres et les écrire dans le fichier destination }
  inc(NbVertex);

   { lire 9 réél et les écrire }
  WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));
  WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));
  WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));

   { lire la ligne suivante dans le fichier source }
  STXM:=ReadFTXM;

 end;
end;

Procedure BTerrain2Mvfm(var STXM : string; var NbVertex : longint);
begin
  { écrire la longueur de 'bterrain2.mvfm' }
 WriteLI(Length('bterrain2.mvfm'));

  { écrire le mot cle }
 WriteTXT('bterrain2.mvfm');

  { initialiser NbVertex }
 NbVertex:=0;

  { lire la ligne suivante dans le fichier source }
 STXM:=ReadFTXM;

 while (not CharOfTextInList(STXM,ListLetter)) and (not EOF(FTXM)) do begin

   { ce texte ne contient pas de lettre : lire les nombres et les écrire dans le fichier destination }
  inc(NbVertex);

   { lire 10 réél et les écrire }
  WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));
  WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));

   { lire la ligne suivante dans le fichier source }
  STXM:=ReadFTXM;

 end;
end;

Procedure PositionMvfm(var STXM : string; var NbVertex : longint);
begin
  { écrire la longueur de 'position.mvfm' }
 WriteLI(Length('position.mvfm'));

  { écrire le mot cle }
 WriteTXT('position.mvfm');

  { initialiser NbVertex }
 NbVertex:=0;

  { lire la ligne suivante dans le fichier source }
 STXM:=ReadFTXM;

 while (not CharOfTextInList(STXM,ListLetter)) and (not EOF(FTXM)) do begin

   { ce texte ne contient pas de lettre : lire les nombres et les écrire dans le fichier destination }
  inc(NbVertex);

   { lire 3 rééls et les écrire }
  WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));

   { lire la ligne suivante dans le fichier source }
  STXM:=ReadFTXM;

 end;
end;

Procedure AirPlaneMvfm(var STXM : string; var NbVertex : longint);
begin
  { écrire la longueur de 'airplane.mvfm' }
 WriteLI(Length('airplane.mvfm'));

  { écrire le mot cle }
 WriteTXT('airplane.mvfm');

  { initialiser NbVertex }
 NbVertex:=0;

  { lire la ligne suivante dans le fichier source }
 STXM:=ReadFTXM;

 while (not CharOfTextInList(STXM,ListLetter)) and (not EOF(FTXM)) do begin

   { ce texte ne contient pas de lettre : lire les nombres et les écrire dans le fichier destination }
  inc(NbVertex);

   { lire 14 rééls et les écrire }
  WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));
  WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));

   { lire la ligne suivante dans le fichier source }
  STXM:=ReadFTXM;

 end;
end;

Procedure AirFieldMvfm(var STXM : string; var NbVertex : longint);
begin
  { écrire la longueur de 'airfield.mvfm' }
 WriteLI(Length('airfield.mvfm'));

  { écrire le mot cle }
 WriteTXT('airfield.mvfm');

  { initialiser NbVertex }
 NbVertex:=0;

  { lire la ligne suivante dans le fichier source }
 STXM:=ReadFTXM;

 while (not CharOfTextInList(STXM,ListLetter)) and (not EOF(FTXM)) do begin

   { ce texte ne contient pas de lettre : lire les nombres et les écrire dans le fichier destination }
  inc(NbVertex);

   { lire 10 rééls et les écrire }
  WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));
  WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));

   { lire la ligne suivante dans le fichier source }
  STXM:=ReadFTXM;

 end;
end;

Procedure ShoreMvfm(var STXM : string; var NbVertex : longint);
begin
  { écrire la longueur de 'shore.mvfm' }
 WriteLI(Length('shore.mvfm'));

  { écrire le mot cle }
 WriteTXT('shore.mvfm');

  { initialiser NbVertex }
 NbVertex:=0;

  { lire la ligne suivante dans le fichier source }
 STXM:=ReadFTXM;

 while (not CharOfTextInList(STXM,ListLetter)) and (not EOF(FTXM)) do begin

   { ce texte ne contient pas de lettre : lire les nombres et les écrire dans le fichier destination }
  inc(NbVertex);

   { lire 5 rééls et les écrire }
  WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));
  WriteR(NumberR(STXM));WriteR(NumberR(STXM));

   { lire 4 octets et les écrit }
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
  { écrire la longueur de 'VertexStream' }
 WriteLI(Length('VertexStream'));

  { écrire le mot cle }
 WriteTXT('VertexStream');

  { Mémoriser la position dans le fichier }
 P:=FilePos(FMmod);

  { écrire zero dans la longueur en attendant de connaitre la bonne valeur }
 WriteLI(0);

  { écrire zero dans le nombre de vertex en attendant de connaitre la bonne valeur }
 WriteLI(0);

  { lire la ligne suivante dans le fichier source }
 STXM:=ReadFTXM;

  { Extraire le mot clef }
 KWord:=KeyWord(STXM);

  { exécuter la procédure correspondant au mot cle trouvé }
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

  { écrire la longueur de la section }
 Seek(FMmod,p);
 WriteLI(LI);

  { écrire le nombre de vertex }
 WriteLI(NbVertex);

  { se replacer à la fin du fichier}
 Seek(FMmod,FileSize(FMmod));

end;

Procedure IndicesStripPS2(var STXM : string);
begin
  { ne fait rien. Juste évacuer la ligne de commentaire }
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
  { écrire la longueur de 'Indices' }
 WriteLI(Length('Indices'));

  { écrire le mot cle }
 WriteTXT('Indices');

  { Mémoriser la position dans le fichier }
 P:=FilePos(FMmod);

  { écrire zero dans la longueur en attendant de connaitre la bonne valeur }
 WriteLI(0);

  { écrirezero dans le nombre d'indices en attendant de connaitre la bonne valeur }
 WriteLI(0);

  { Ejecter le mot cle au début de la chaine de caractère }
 EjectTxt(STXM,length('Indices'));

  { Ecrire le nombre associé }
 
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

   { ce texte ne contient pas de lettre : lire les nombres et les écrire dans le fichier destination }
  inc(NbIndices,3);
  
  { lire 3 entiers et les écrire }
  for i:=1 to Iterations do begin
   
   WriteW(NumberW(STXM));
   
  end;
  
   { lire 3 entiers et les écrire }
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

  { écrire la longueur de la section }
 Seek(FMmod,p);
 WriteLI(LI);

  { écrire le nombre d'indices }
 WriteLI(NbIndices);

  {se positionner à la fin du fichier }
 seek(FMmod,filesize(FMmod));

end;

Procedure SubSetPS2(var STXM : string);
begin
  { ne fait rien. Juste évacuer la ligne de commentaire }
 STXM:=ReadFTXM;
 STXM:='';
end;

Procedure MSHD(var STXM : string; KWord : string);
begin

  { écrire la longueur du mot cle }
 WriteLI(Length(KWord));

  { écrire le mot clé }
 WriteTxt(KWord);

  { Ejecter le mot cle au début de la chaine de caractère }
 EjectTxt(STXM,length(KWord));

end;

Procedure VertexStreamIndex(var STXM : string);
begin
  { écrire la longueur de 'VertexStreamIndex' }
 WriteLI(Length('VertexStreamIndex'));

  { écrire le mot cle }
 WriteTXT('VertexStreamIndex');

  { écrire la longueur=4 (pour 1 longint) }
 WriteLI(4);

  { Ejecter le mot cle au début de la chaine de caractère }
 EjectTxt(STXM,length('VertexStreamIndex'));

  { écrire le nombre associé }
 WriteLI(NumberLI(STXM));

end;

Procedure Texture(var STXM : string);
var
 NameTexture : string;
begin
  { écrire la longueur de 'Texture' }
 WriteLI(Length('Texture'));

  { écrire le mot cle }
 WriteTXT('Texture');

  { Ejecter le mot cle au début de la chaine de caractère }
 EjectTxt(STXM,length('Texture'));

  { Lire le nom de la texture }
 NameTexture:=KeyWord(STXM);

  {écrire les longueurs }
 WriteLI(Length(NameTexture)+8);
 WriteLI(Length(NameTexture));

  { écrire la texture }
 WriteTxt(NameTexture);

  { Ejecter le nom de la texture au début de la chaine de caractère }
 STXM:=EjectFirstPresentKey(STXM);
 EjectTxt(STXM,length(NameTexture));

  { écrire le nombre associé }
 WriteLI(NumberLI(STXM));

end;

Procedure LightingSettings(var STXM : string);
var
 i : integer;
begin
  { écrire la longueur de 'LightingSettings' }
 WriteLI(Length('LightingSettings'));

  { écrire le mot cle }
 WriteTXT('LightingSettings');

  { écrire la taille 76 }
 WriteLI(76);

  { Ejecter le mot cle au début de la chaine de caractère }
 EjectTxt(STXM,length('LightingSettings'));

  { Ecrire le nombre associé }
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
  { écrire la longueur de 'Subset' }
 WriteLI(Length('Subset'));

  { écrire le mot cle }
 WriteTXT('Subset');

  { Mémoriser la position dans le fichier }
 P:=FilePos(FMmod);

  { écrire zero dans la longueur en attendant de connaitre la bonne valeur }
 WriteLI(0);

  { Ejecter le mot cle au début de la chaine de caractère }
 EjectTxt(STXM,length('Subset'));

  { Ecrire les nombres associés }
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

   { exécuter la procédure correspondant au mot cle trouvé }
  KeyWordFind:=false;

   { Commencer par regarder si le mot cle n'est pas au format *.mshd }
  S:='';
  for i:=1 to 5 do S:=S+KWord[length(KWord)-5+i];  { mettre les 5 derniers caractères dans S }

  if S='.mshd' then begin MSHD(STXM,KWord); KeyWordFind:=true; end;

  if KWord='VertexStreamIndex' then begin VertexStreamIndex(STXM); KeyWordFind:=true; end;
  if KWord='Texture' then begin Texture(STXM); KeyWordFind:=true; end;
  if KWord='LightingSettings' then begin LightingSettings(STXM); KeyWordFind:=true; end;
  if KWord='BoundingSphere' then begin BoundingSphere(STXM); KeyWordFind:=true; end;

 Until not KeyWordFind or EOF(FTXM);

  { calculer la longueur de la section }
 LI:=FileSize(FMmod)-p-4;

  { écrire la longueur de la section }
 Seek(FMmod,p);
 WriteLI(LI);

  { se replacer à la fin du fichier}
 Seek(FMmod,FileSize(FMmod));

end;

Procedure LODPhases(var STXM : string);
var
 p,                     { position de la taille du block }
 LI,
 NbPhases : longint;    { nombre de phases dans le lods }

begin
  { écrire la longueur de 'LODPhases' }
 WriteLI(Length('LODPhases'));

  { écrire le mot cle }
 WriteTXT('LODPhases');

  { Mémoriser la position dans le fichier }
 P:=FilePos(FMmod);

  { écrire zero dans la longueur en attendant de connaitre la bonne valeur }
 WriteLI(0);

  { Ejecter le mot cle au début de la chaine de caractère }
 EjectTxt(STXM,length('LODPhases'));

  { Lire le nombre de phases }
 NbPhases:=NumberLI(STXM);

  { écrire le nombre de phases }
 WriteLI(NbPhases);

  { écrire les LODPhases }
 for LI:=1 to NbPhases do begin

   { lire la ligne suivante }
  STXM:=ReadFTXM;

   { écrire les 4 nombres (2reels + 2LI) }
  WriteR(NumberR(STXM)); WriteR(NumberR(STXM)); WriteLI(NumberLI(STXM)); WriteLI(NumberLI(STXM));
 end;

  { calculer la longueur de la section }
 LI:=FileSize(FMmod)-p-4;

  { écrire la longueur de la section }
 Seek(FMmod,p);
 WriteLI(LI);

  { se replacer à la fin du fichier}
 Seek(FMmod,FileSize(FMmod));

end;

Procedure Mesh(var STXM : string);
var
 KeyWordFind : boolean;
 KWord : string;
 LI,
 p : longint;          { pointe sur l'emplacement de la longueur de la section }
begin
  { écrire la longueur de 'Mesh' }
 WriteLI(Length('Mesh'));

  { écrire le mot cle }
 WriteTXT('Mesh');

  { Mémoriser la position dans le fichier }
 P:=FilePos(FMmod);

  { écrire zero dans la longueur en attendant de connaitre la bonne valeur }
 WriteLI(0);

  { Ejecter le mot cle au début de la chaine de caractère }
 EjectTxt(STXM,length('Mesh'));

  { Ecrire le nombre associé }
 WriteLI(NumberLI(STXM));

  { lire la ligne suivante dans le fichier source }
 STXM:=EjectFirstPresentKey(ReadFTXM);

 Repeat

   {si STXM est vide, alors lire la ligne suivante }
  if EjectAllPresentKey(STXM) ='' then STXM:=ReadFTXM;

   { Extraire le mot clef }
  KWord:=KeyWord(STXM);

   { exécuter la procédure correspondant au mot cle trouvé }
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

  { écrire la longueur de la section }
 Seek(FMmod,p);
 WriteLI(LI);

  { se replacer à la fin du fichier}
 Seek(FMmod,FileSize(FMmod));

end;

Procedure Identifier(var STXM : string);
var
 LI,
 p : longint;   { position de la longueur de la section }
begin
  { écrire la longueur de 'Mesh' }
 WriteLI(Length('Identifier'));

  { écrire le mot cle }
 WriteTXT('Identifier');

  { Mémoriser la position dans le fichier }
 P:=FilePos(FMmod);

  { écrire zero dans la longueur en attendant de connaitre la bonne valeur }
 WriteLI(0);

  { Ejecter le mot cle au début de la chaine de caractère }
 EjectTxt(STXM,length('Identifier'));

  { lire la ligne suivante }
 STXM:=ReadFTXM;

  { écrire le longueur du nom }
 WriteLI(Length(STXM));

  { écrire le nom }
 WriteTxt(STXM);

  { lire la ligne suivante }
 STXM:=ReadFTXM;

  { écrire le numéro associé }
 WriteLI(NumberLI(STXM));

  { calculer la longueur de la section }
 LI:=FileSize(FMmod)-p-4;

  { écrire la longueur de la section }
 Seek(FMmod,p);
 WriteLI(LI);

  { se replacer à la fin du fichier}
 Seek(FMmod,FileSize(FMmod));

end;

Procedure Category(var STXM : string);
var
 LI,
 p : longint;   { mémorise à la position de la longueur du bloc }
begin
  { écrire la longueur de 'Category' }
 WriteLI(Length('Category'));

  { écrire le mot cle }
 WriteTXT('Category');

  { Mémoriser la position dans le fichier }
 P:=FilePos(FMmod);

  { écrire zero dans la longueur en attendant de connaitre la bonne valeur }
 WriteLI(0);

  { écrire 0 dans la longueur du mot en attendant de connaitre la bonne valeur }
 WriteLI(0);

  { lire la ligne suivante dans le fichier source }
 STXM:=ReadFTXM;

  { écrire le mot }
 WriteTxt(STXM);

  { calculer la longueur de la section }
 LI:=FileSize(FMmod)-p-4;

  { écrire la longueur de la section }
 Seek(FMmod,p);
 WriteLI(LI);

  {écrire la longueur du mot }
 WriteLI(LI-4);

  {se positionner à la fin du fichier }
 seek(FMmod,filesize(FMmod));

 STXM:='';

end;

Procedure Points(var STXM : string);
var
 LI,
 p : longint;   { mémorise à la position de la longueur du bloc }
begin
  { écrire la longueur de 'Points' }
 WriteLI(Length('Points'));

  { écrire le mot cle }
 WriteTXT('Points');

  { Mémoriser la position dans le fichier }
 P:=FilePos(FMmod);

  { écrire zero dans la longueur en attendant de connaitre la bonne valeur }
 WriteLI(0);

  { lire la ligne suivante dans le fichier source }
 STXM:=ReadFTXM;

 while (not CharOfTextInList(STXM,ListLetter)) and not(EOF(FTXM)) do begin

   { ce texte ne contient pas de lettre : lire les nombres et les écrire dans le fichier destination }

   { lire 3 reels et les écrire }
  WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));

   { lire la ligne suivante dans le fichier source }
  STXM:=ReadFTXM;

 end;

  { calculer la longueur de la section }
 LI:=FileSize(FMmod)-p-4;

  { écrire la longueur de la section }
 Seek(FMmod,p);
 WriteLI(LI);

  {se positionner à la fin du fichier }
 seek(FMmod,filesize(FMmod));

end;

Procedure Aux(var STXM : string);
var
 KeyWordFind : boolean;
 KWord : string;
 LI,
 p : longint;          { pointe sur l'emplacement de la longueur de la section }
begin
  { écrire la longueur de 'Aux' }
 WriteLI(Length('Aux'));

  { écrire le mot cle }
 WriteTXT('Aux');

  { Mémoriser la position dans le fichier }
 P:=FilePos(FMmod);

  { écrire zero dans la longueur en attendant de connaitre la bonne valeur }
 WriteLI(0);

  { lire la ligne suivante dans le fichier source }
 STXM:=ReadFTXM;

 Repeat

   {si STXM est vide, alors lire la ligne suivante }
  if EjectAllPresentKey(STXM) ='' then STXM:=ReadFTXM;

   { Extraire le mot clef }
  KWord:=KeyWord(STXM);

   { exécuter la procédure correspondant au mot cle trouvé }
  KeyWordFind:=false;
  if KWord='Identifier' then begin Identifier(STXM); KeyWordFind:=true; end;
  if KWord='Category' then begin Category(STXM); KeyWordFind:=true; end;
  if KWord='Points' then begin Points(STXM); KeyWordFind:=true; end;

 Until not KeyWordFind or EOF(FTXM);

  { calculer la longueur de la section }
 LI:=FileSize(FMmod)-p-4;

  { écrire la longueur de la section }
 Seek(FMmod,p);
 WriteLI(LI);

  { se replacer à la fin du fichier}
 Seek(FMmod,FileSize(FMmod));

end;

Procedure GeomMesh(var STXM : string);
var
 NbLTab,                     { Nb de ligne du tableau }
 NbIndices,                  { Nb d'indices }
 NbName,                     { Nb d'éléments }
 NbPoints,                   { nombre de points }
 LI,
 p1,                         { poiteur provisoir }
 p : longint;                { mémorise la position de la longueur de le section }

begin
  { écrire la longueur de 'GeomMesh' }
 WriteLI(Length('GeomMesh'));

  { écrire le mot cle }
 WriteTXT('GeomMesh');

  { Mémoriser la position dans le fichier }
 P:=FilePos(FMmod);

  { écrire zero dans la longueur en attendant de connaitre la bonne valeur }
 WriteLI(0);

  { écrire zero dans le nombre d'élément en attendant de connaitre la bonne valeur }
 WriteLI(0);

  { initialiser le nombre d'éléments }
 NbName:=0;

 Repeat

   { lire la ligne suivante }
  STXM:=ReadFTXM;

  if not (STXM='END') then begin
    { cette ligne contient un élément : le lire et l'écrire }

    { écrire la longueur du mot }
   WriteLI(Length(STXM));

    { écrire le mot }
   WriteTxt(STXM);

    { lire la ligne suivante }
   STXM:=ReadFTXM;

    { Ecrire le nombre associé }
   WriteLI(NumberLI(STXM));

   inc(NbName);
  end;
 Until (EjectAllPresentKey(STXM)='END') or EOF(FTXM);

  {se positionner sur le Nombre d'éléments }
 seek(FMmod,p+4);

  { écrire le nombre d'éléments }
 WriteLI(NbName);

  { se replacer à la fin du fichier }
 seek(FMmod,FileSize(FMmod));

  { mémoriser la position du nombre de points }
 p1:=FilePos(FMmod);

  { écrire zero dans le nombre de points en attendant de connaitre la bonne valeur }
 WriteLI(0);

  { initialiser NbPoints }
 NbPoints:=0;

 Repeat

   { lire la ligne suivante }
  STXM:=ReadFTXM;

  if not (EjectAllPresentKey(STXM)='END') then begin
    { cette ligne contient un élément : le lire et l'écrire }

    { lire et écrire 3 reels }
   WriteR(NumberR(STXM)); WriteR(NumberR(STXM)); WriteR(NumberR(STXM));

   inc(NbPoints);

  end;

 Until (EjectAllPresentKey(STXM)='END') or EOF(FTXM);

   {se positionner sur le Nombre de points }
 seek(FMmod,p1);

  { écrire le nombre de points }
 WriteLI(NbPoints);

  { se replacer à la fin du fichier }
 seek(FMmod,FileSize(FMmod));

  { mémoriser la position du nombre d'indices }
 p1:=FilePos(FMmod);

  { écrire zero dans le nombre d'indices en attendant de connaitre la bonne valeur }
 WriteLI(0);

  { initialiser le nombre d'indices }
 NbIndices:=0;

 Repeat

   { lire la ligne suivante }
  STXM:=ReadFTXM;

  if not (EjectAllPresentKey(STXM)='END') then begin
    { cette ligne contient un élément : le lire et l'écrire }

    { lire et écrire 2 entiers }
   WriteLI(NumberLI(STXM)); WriteLI(NumberLI(STXM));

   inc(NbIndices);

  end;

 Until (EjectAllPresentKey(STXM)='END') or EOF(FTXM);

   {se positionner sur le Nombre d'indices }
 seek(FMmod,p1);

  { écrire le nombre d'indices }
 WriteLI(NbIndices);

   { se replacer à la fin du fichier }
 seek(FMmod,FileSize(FMmod));

  { mémoriser la position du nombre de ligne de table }
 p1:=FilePos(FMmod);

  { écrire zero dans le nombre de ligne de la table en attendant de connaitre la bonne valeur }
 WriteLI(0);

  { initialiser le nombre de lignes du tableau }
 NbLTab:=0;

  { lire la ligne suivante dans le fichier source }
 STXM:=ReadFTXM;

 while (not CharOfTextInList(STXM,ListLetter)) and not(EOF(FTXM)) do begin

   { ce texte ne contient pas de lettre : lire les nombres et les écrire dans le fichier destination }

   { lire 8 entiers long et les écrire }
  WriteLI(NumberLI(STXM));WriteLI(NumberLI(STXM));WriteLI(NumberLI(STXM));WriteLI(NumberLI(STXM));
  WriteLI(NumberLI(STXM));WriteLI(NumberLI(STXM));WriteLI(NumberLI(STXM));WriteLI(NumberLI(STXM));

  inc(NbLTab);

   { lire la ligne suivante dans le fichier source }
  STXM:=ReadFTXM;

 end;

   {se positionner sur le Nombre de lignes du tableau }
 seek(FMmod,p1);

  { écrire le nombre d'indices }
 WriteLI(NbLTab);

  { calculer la longueur de la section }
 LI:=FileSize(FMmod)-p-4;

  { écrire la longueur de la section }
 Seek(FMmod,p);
 WriteLI(LI);

  { se replacer à la fin du fichier}
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
  { écrire la longueur de 'ConvexObject' }
 WriteLI(Length('ConvexObject'));

  { écrire le mot cle }
 WriteTXT('ConvexObject');

  { Mémoriser la position dans le fichier }
 P:=FilePos(FMmod);

  { écrire zero dans la longueur en attendant de connaitre la bonne valeur }
 WriteLI(0);

  { éjecter le mot cle du début de la STXM }
 EjectTxt(STXM, length('ConvexObject'));

  { vérifier s'il reste quelque chose à lire, si oui écrire le nombre entier présent }
 if EjectAllPresentKey(STXM)<>'' then WriteLI(NumberLI(STXM));

  { 1 ere SECTION ============================================================================== }

  { initialiser le nombre d'objets }
 NbObject:=0;

  { Mémoriser la position du nombre d'objets de la premiere section }
 pObj:=FilePos(FMmod);

  { écrire zero dans la longueur en attendant de connaitre la bonne valeur }
 WriteLI(0);

 Repeat

  STXM:=ReadFTXM;

  if not (EjectAllPresentKey(STXM)='END') and not (EOF(FTXM))then begin
   { cette ligne contient un élément : le lire et l'écrire }

    { lire et écrire 3 nombres reéls }

   WriteR(NumberR(STXM)); WriteR(NumberR(STXM)); WriteR(NumberR(STXM));

   for i:=1 to 3 do begin

     { mémoriser la position du nombre d'éléments de la sous-section }
    pSubObj:=FilePos(FMmod);

     { écrire zero dans la longueur en attendant de connaitre la bonne valeur }
    WriteLI(0);

     { lire la ligne suivante }
    STXM:=ReadFTXM;

     { initialiser le nombre de sous-objets }
    NbSubObject:=0;

     { tant qu'il y a quelque chose d'écrit, lire le nombre suivant et incrémenter NbSubObject }
    while EjectAllPresentKey(STXM)<>'' do begin

      { lire et écrire 1 nombre entier }
     WriteLI(NumberLI(STXM));

     inc(NbSubObject);

    end;

     {se positionner sur le Nombre de sous-objets }
    seek(FMmod,pSubObj);

     { écrire le nombre de sous objets }
    WriteLI(NbSubObject);

     { se replacer à la fin du fichier }
    seek(FMmod,FileSize(FMmod));

   end;

   inc(NbObject);

  end;

 Until (EjectAllPresentKey(STXM)='END') or EOF(FTXM);

   {se positionner sur le Nombre d'objets }
 seek(FMmod,pObj);

  { écrire le nombre d'indices }
 WriteLI(NbObject);

  { se replacer à la fin du fichier}
 Seek(FMmod,FileSize(FMmod));

  { 2 eme SECTION ============================================================================== }

  { initialiser le nombre d'objets }
 NbObject:=0;

  { Mémoriser la position du nombre d'objets de la premiere section }
 pObj:=FilePos(FMmod);

  { écrire zero dans la longueur en attendant de connaitre la bonne valeur }
 WriteLI(0);

 Repeat

  STXM:=ReadFTXM;

  if not (EjectAllPresentKey(STXM)='END') and not (EOF(FTXM))then begin
   { cette ligne contient un élément : le lire et l'écrire }

    { lire et écrire 3 nombres reéls }

   WriteR(NumberR(STXM)); WriteR(NumberR(STXM)); WriteR(NumberR(STXM));

   for i:=1 to 2 do begin

     { mémoriser la position du nombre d'éléments de la sous-section }
    pSubObj:=FilePos(FMmod);

     { écrire zero dans la longueur en attendant de connaitre la bonne valeur }
    WriteLI(0);

     { lire la ligne suivante }
    STXM:=ReadFTXM;

     { initialiser le nombre de sous-objets }
    NbSubObject:=0;

     { tant qu'il y a quelque chose d'écrit, lire le nombre suivant et incrémenter NbSubObject }
    while EjectAllPresentKey(STXM)<>'' do begin

      { lire et écrire 1 nombre entier }
     WriteLI(NumberLI(STXM));

     inc(NbSubObject);

    end;

     {se positionner sur le Nombre de sous-objets }
    seek(FMmod,pSubObj);

     { écrire le nombre de sous objets }
    WriteLI(NbSubObject);

     { se replacer à la fin du fichier }
    seek(FMmod,FileSize(FMmod));

   end;

   inc(NbObject);

  end;

 Until (EjectAllPresentKey(STXM)='END') or EOF(FTXM);

  { se positionner sur le Nombre d'objets }
 seek(FMmod,pObj);

  { écrire le nombre d'objets }
 WriteLI(NbObject);

  { se replacer à la fin du fichier}
 Seek(FMmod,FileSize(FMmod));

  { 3 eme SECTION ============================================================================== }

  { Mémoriser la position du nombre d'objets }
 PObj:=FilePos(FMmod);

  { écrire zero dans la longueur en attendant de connaitre la bonne valeur }
 WriteLI(0);

 { lire la section }
 { initialiser le nombre d'objets }
 NbObject:=0;

 Repeat

   { lire la ligne suivante }
  STXM:=ReadFTXM;

  if not (EjectAllPresentKey(STXM)='END') and not (EOF(FTXM))then begin
    { cette ligne contient un élément : le lire et l'écrire }

    { lire et écrire 5 nombres reéls }
   WriteR(NumberR(STXM)); WriteR(NumberR(STXM)); WriteR(NumberR(STXM)); WriteR(NumberR(STXM)); WriteR(NumberR(STXM));

   inc(NbObject);

  end;
 Until (EjectAllPresentKey(STXM)='END') or EOF(FTXM);

  {se positionner sur le Nombre d'objets }
 seek(FMmod,pObj);

  { écrire le nombre d'objets }
 WriteLI(NbObject);

  { se replacer à la fin du fichier }
 seek(FMmod,FileSize(FMmod));

   { mémoriser la position du nombre d'objets }
 pObj:=FilePos(FMmod);

  { écrire zero dans le nombre de ligne de la table en attendant de connaitre la bonne valeur }
 WriteLI(0);

  { initialiser le nombre de lignes du tableau }
 NbObject:=0;

  { lire la ligne suivante dans le fichier source }
 STXM:=ReadFTXM;

 while (not CharOfTextInList(STXM,ListLetter)) and not(EOF(FTXM)) do begin

   { ce texte ne contient pas de lettre : lire les nombres et les écrire dans le fichier destination }

   { lire 3 réels et les écrire }
  WriteR(NumberR(STXM));WriteR(NumberR(STXM));WriteR(NumberR(STXM));

  inc(NbObject);

   { lire la ligne suivante dans le fichier source }
  STXM:=ReadFTXM;

 end;

   {se positionner sur le Nombre d'objets }
 seek(FMmod,pObj);

  { écrire le nombre d'objets }
 WriteLI(NbObject);

  { calculer la longueur de la section }
 LI:=FileSize(FMmod)-p-4;

  { écrire la longueur de la section }
 Seek(FMmod,p);
 WriteLI(LI);

  { se replacer à la fin du fichier}
 Seek(FMmod,FileSize(FMmod));

end;

Procedure Note(var STXM : string);
begin
   { écrire la longueur de 'Note' }
 WriteLI(Length('Note'));

  { écrire le mot cle }
 WriteTXT('Note');

  { éjecter le mot cle du début de la STXM }
 EjectTxt(STXM, length('Note'));

  { éjecter les premiers caractères de présentation }
 STXM:=EjectFirstPresentKey(STXM);

  { écrire la longueur de la section }
 WriteLI(Length(STXM)+4);

  { écrire la longueur du texte }
 WriteLI(Length(STXM));

  { écrire le texte }
 WriteTxt(STXM);

 STXM:='';
end;

Procedure GroupParams(var STXM : string);
begin
   { écrire la longueur de 'GroupParams' }
 WriteLI(Length('GroupParams'));

  { écrire le mot cle }
 WriteTXT('GroupParams');

  { éjecter le mot cle du début de la STXM }
 EjectTxt(STXM, length('GroupParams'));

  { écrire le nombre '4'}
 WriteLI(4);

  { lire et écrire 1 nombre réel }
 WriteR(NumberR(STXM));

end;

Procedure Geom(var STXM : string);
begin
  STXM:='A1';
end;

Procedure SceneError(var STXM : string);
begin
  { éjecter la ligne suivante }
 STXM:=ReadFTXM;
 STXM:='';
end;

Procedure WeightMapNames(var STXM : string);
var
 LI,
 p,                 { position de la longueur de la section }
 NbName : longint;  { nombre de noms }
begin
  { écrire la longueur de 'WeightMapNames' }
 WriteLI(Length('WeightMapNames'));

  { écrire le mot cle }
 WriteTXT('WeightMapNames');

  { Mémoriser la position dans le fichier }
 P:=FilePos(FMmod);

  { écrire zero dans la longueur en attendant de connaitre la bonne valeur }
 WriteLI(0);

 Repeat

   { lire la ligne suivante }
  STXM:=ReadFTXM;

  if STXM<>'END' then begin

   inc(NbName);

    { écrire la longueur du nom }
   WriteLI(Length(STXM));

    { écrire le nom }
   WriteTXT(STXM);

  end;
 until (STXM='END') or (EOF(FTXM));

  { calculer la longueur de la section }
 LI:=FileSize(FMmod)-p-4;

  { écrire la longueur de la section }
 Seek(FMmod,p);
 WriteLI(LI);

  { se replacer à la fin du fichier}
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
  { écrire la longueur de 'MatrixIndexedMesh' }
 WriteLI(Length('MatrixIndexedMesh'));

  { écrire le mot cle }
 WriteTXT('MatrixIndexedMesh');

  { Mémoriser la position dans le fichier }
 P:=FilePos(FMmod);

  { écrire zero dans la longueur en attendant de connaitre la bonne valeur }
 WriteLI(0);

  { Ejecter le mot cle au début de la chaine de caractère }
 EjectTxt(STXM,length('MatrixIndexedMesh'));

  { Ecrire le nombre associé }
 WriteLI(NumberLI(STXM));

  { lire la ligne suivante dans le fichier source }
 STXM:=EjectFirstPresentKey(ReadFTXM);

 Repeat

   {si STXM est vide, alors lire la ligne suivante }
  if EjectAllPresentKey(STXM) ='' then STXM:=ReadFTXM;

   { Extraire le mot clef }
  KWord:=KeyWord(STXM);

   { exécuter la procédure correspondant au mot cle trouvé }
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

  { écrire la longueur de la section }
 Seek(FMmod,p);
 WriteLI(LI);

  { se replacer à la fin du fichier}
 Seek(FMmod,FileSize(FMmod));

end;

Procedure CloudSystem(var STXM : string);
var
 NbPoints,         { Nb de points dans le nuage }
 LI,
 p : longint;      { position de la longueur de la section }
begin
   { écrire la longueur de 'CloudSystem' }
 WriteLI(Length('CloudSystem'));

  { écrire le mot cle }
 WriteTXT('CloudSystem');

  { Mémoriser la position dans le fichier }
 P:=FilePos(FMmod);

  { écrire zero dans la longueur en attendant de connaitre la bonne valeur }
 WriteLI(0);

  { écrirezero dans le nombre d'indices en attendant de connaitre la bonne valeur }
 WriteLI(0);

  { initialiser le Nb de points }
 NbPoints:=0;

  { lire la ligne suivante dans le fichier source }
 STXM:=ReadFTXM;

 while (not CharOfTextInList(STXM,ListLetter)) and not(EOF(FTXM)) do begin

   { ce texte ne contient pas de lettre : lire les nombres et les écrire dans le fichier destination }
  inc(NbPoints);

   { lire 4 réels et les écrire }
  WriteR(NumberR(STXM)); WriteR(NumberR(STXM)); WriteR(NumberR(STXM)); WriteR(NumberR(STXM));

   { lire la ligne suivante dans le fichier source }
  STXM:=ReadFTXM;

 end;

  { calculer la longueur de la section }
 LI:=FileSize(FMmod)-p-4;

  { écrire la longueur de la section }
 Seek(FMmod,p);
 WriteLI(LI);

  { écrire le nombre de points }
 WriteLI(NbPoints);

  {se positionner à la fin du fichier }
 seek(FMmod,filesize(FMmod));

end;

Procedure PositionX(var STXM : string);
begin
   { écrire la longueur de 'Position.X' }
 WriteLI(Length('Position.X'));

  { écrire le mot cle }
 WriteTXT('Position.X');

  { éjecter le mot cle du début de la STXM }
 EjectTxt(STXM, length('Position.X'));

  { lire et écrire les deux nombres associés }
 WriteLI(NumberLI(STXM)); WriteLI(NumberLI(STXM));

end;

Procedure PositionY(var STXM : string);
begin
   { écrire la longueur de 'Position.Y' }
 WriteLI(Length('Position.Y'));

  { écrire le mot cle }
 WriteTXT('Position.Y');

  { éjecter le mot cle du début de la STXM }
 EjectTxt(STXM, length('Position.Y'));

  { lire et écrire les deux nombres associés }
 WriteLI(NumberLI(STXM)); WriteLI(NumberLI(STXM));

end;

Procedure PositionZ(var STXM : string);
begin
   { écrire la longueur de 'Position.Z' }
 WriteLI(Length('Position.Z'));

  { écrire le mot cle }
 WriteTXT('Position.Z');

  { éjecter le mot cle du début de la STXM }
 EjectTxt(STXM, length('Position.Z'));

  { lire et écrire les deux nombres associés }
 WriteLI(NumberLI(STXM)); WriteLI(NumberLI(STXM));

end;

Procedure RotationH(var STXM : string);
begin
   { écrire la longueur de 'Rotation.H' }
 WriteLI(Length('Rotation.H'));

  { écrire le mot cle }
 WriteTXT('Rotation.H');

  { éjecter le mot cle du début de la STXM }
 EjectTxt(STXM, length('Rotation.H'));

  { lire et écrire les deux nombres associés }
 WriteLI(NumberLI(STXM)); WriteLI(NumberLI(STXM));

end;

Procedure RotationP(var STXM : string);
begin
   { écrire la longueur de 'Rotation.P' }
 WriteLI(Length('Rotation.P'));

  { écrire le mot cle }
 WriteTXT('Rotation.P');

  { éjecter le mot cle du début de la STXM }
 EjectTxt(STXM, length('Rotation.P'));

  { lire et écrire les deux nombres associés }
 WriteLI(NumberLI(STXM)); WriteLI(NumberLI(STXM));

end;

Procedure RotationB(var STXM : string);
begin
   { écrire la longueur de 'Rotation.B' }
 WriteLI(Length('Rotation.B'));

  { écrire le mot cle }
 WriteTXT('Rotation.B');

  { éjecter le mot cle du début de la STXM }
 EjectTxt(STXM, length('Rotation.B'));

  { lire et écrire les deux nombres associés }
 WriteLI(NumberLI(STXM)); WriteLI(NumberLI(STXM));

end;

Procedure ScaleX(var STXM : string);
begin
   { écrire la longueur de 'Scale.X' }
 WriteLI(Length('Scale.X'));

  { écrire le mot cle }
 WriteTXT('Scale.X');

  { éjecter le mot cle du début de la STXM }
 EjectTxt(STXM, length('Scale.X'));

  { lire et écrire les deux nombres associés }
 WriteLI(NumberLI(STXM)); WriteLI(NumberLI(STXM));

end;

Procedure ScaleY(var STXM : string);
begin
   { écrire la longueur de 'Scale.Y' }
 WriteLI(Length('Scale.Y'));

  { écrire le mot cle }
 WriteTXT('Scale.Y');

  { éjecter le mot cle du début de la STXM }
 EjectTxt(STXM, length('Scale.Y'));

  { lire et écrire les deux nombres associés }
 WriteLI(NumberLI(STXM)); WriteLI(NumberLI(STXM));

end;

Procedure ScaleZ(var STXM : string);
begin
   { écrire la longueur de 'Scale.Z' }
 WriteLI(Length('Scale.Z'));

  { écrire le mot cle }
 WriteTXT('Scale.Z');

  { éjecter le mot cle du début de la STXM }
 EjectTxt(STXM, length('Scale.Z'));

  { lire et écrire les deux nombres associés }
 WriteLI(NumberLI(STXM)); WriteLI(NumberLI(STXM));

end;

Procedure AnimationKey(var STXM : string);
begin
   { écrire la longueur de 'AnimationKey' }
 WriteLI(Length('AnimationKey'));

  { écrire le mot cle }
 WriteTXT('AnimationKey');

  { écrire le nombre '40' }
 WriteLI(40);

  { éjecter le mot cle du début de la STXM }
 EjectTxt(STXM, length('AnimationKey'));

  { lire et écrire le nombre associé }
 WriteLI(NumberLI(STXM));

  { lire la ligne suivante }
 STXM:=ReadFTXM;

  { lire et écrire 9 nombres reél }
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
  { écrire la longueur de 'ChannelAnimation' }
 WriteLI(Length('ChannelAnimation'));

  { écrire le mot cle }
 WriteTXT('ChannelAnimation');

  { Mémoriser la position dans le fichier }
 P:=FilePos(FMmod);

  { écrire zero dans la longueur en attendant de connaitre la bonne valeur }
 WriteLI(0);

  { lire la ligne suivante dans le fichier source }
 STXM:=ReadFTXM;

 Repeat

   {si STXM est vide, alors lire la ligne suivante }
  if EjectAllPresentKey(STXM) ='' then STXM:=ReadFTXM;

   { Extraire le mot clef }
  KWord:=KeyWord(STXM);

   { exécuter la procédure correspondant au mot cle trouvé }
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

  { écrire la longueur de la section }
 Seek(FMmod,p);
 WriteLI(LI);

  { se replacer à la fin du fichier}
 Seek(FMmod,FileSize(FMmod));

end;

Procedure AnimationGroupName(var STXM : string);
var
 LI,
 p : longint;   { mémorise à la position de la longueur du bloc }
begin
  { écrire la longueur de 'AnimationGroupName' }
 WriteLI(Length('AnimationGroupName'));

  { écrire le mot cle }
 WriteTXT('AnimationGroupName');

  { Mémoriser la position dans le fichier }
 P:=FilePos(FMmod);

  { écrire zero dans la longueur en attendant de connaitre la bonne valeur }
 WriteLI(0);

  { écrire 0 dans la longueur du mot en attendant de connaitre la bonne valeur }
 WriteLI(0);

  { lire la ligne suivante dans le fichier source }
 STXM:=ReadFTXM;

  { écrire le mot }
 WriteTxt(KeyWord(STXM));

  { Ejecter le mot cle au début de la chaine de caractère }
 EjectTxt(STXM,length(KeyWord(STXM)));

  { calculer la longueur de la section }
 LI:=FileSize(FMmod)-p-4;

  { écrire la longueur de la section }
 Seek(FMmod,p);
 WriteLI(LI);

  {écrire la longueur du mot }
 WriteLI(LI-4);

  {se positionner à la fin du fichier }
 seek(FMmod,filesize(FMmod));

end;


Procedure AnimationChannels(var STXM : string);
var
 KeyWordFind : boolean;
 KWord : string;
 LI,
 p : longint;          { pointe sur l'emplacement de la longueur de la section }
begin
  { écrire la longueur de 'AnimationChannels' }
 WriteLI(Length('AnimationChannels'));

  { écrire le mot cle }
 WriteTXT('AnimationChannels');

  { Mémoriser la position dans le fichier }
 P:=FilePos(FMmod);

  { écrire zero dans la longueur en attendant de connaitre la bonne valeur }
 WriteLI(0);

  { lire la ligne suivante dans le fichier source }
 STXM:=ReadFTXM;

 Repeat

   {si STXM est vide, alors lire la ligne suivante }
  if EjectAllPresentKey(STXM) ='' then STXM:=ReadFTXM;

   { Extraire le mot clef }
  KWord:=KeyWord(STXM);

   { exécuter la procédure correspondant au mot cle trouvé }
  KeyWordFind:=false;

  if KWord='AnimationGroupName' then begin AnimationGroupName(STXM); KeyWordFind:=true; end;
  if KWord='ChannelAnimation' then begin ChannelAnimation(STXM); KeyWordFind:=true; end;

 Until not KeyWordFind or EOF(FTXM);

  { calculer la longueur de la section }
 LI:=FileSize(FMmod)-p-4;

  { écrire la longueur de la section }
 Seek(FMmod,p);
 WriteLI(LI);

  { se replacer à la fin du fichier}
 Seek(FMmod,FileSize(FMmod));

end;

Procedure Resource(var STXM:string);
var
 KeyWordFind : boolean;
 KWord : string;
 LI,
 p : longint;          { pointe sur l'emplacement de la longueur de la section }
begin
  { écrire la longueur de 'Resource' }
 WriteLI(Length('Resource'));

  { écrire le mot cle }
 WriteTXT('Resource');

  { Mémoriser la position dans le fichier }
 P:=FilePos(FMmod);

  { écrire zero dans la longueur en attendant de connaitre la bonne valeur }
 WriteLI(0);

  { lire la ligne suivante dans le fichier source }
 STXM:=ReadFTXM;

 Repeat

   {si STXM est vide, alors lire la ligne suivante }
  if EjectAllPresentKey(STXM) ='' then STXM:=ReadFTXM;

   { Extraire le mot clef }
  KWord:=KeyWord(STXM);

   { exécuter la procédure correspondant au mot cle trouvé }
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

  { écrire la longueur de la section }
 Seek(FMmod,p);
 WriteLI(LI);

  { se replacer à la fin du fichier}
 Seek(FMmod,FileSize(FMmod));

end;

Procedure MMOD(var STXM:string);
var
 KeyWordFind : boolean;
 KWord : string;
 LI,
 p : longint;          { pointe sur l'emplacement de la longueur de la section }
begin
  { écrire le longueur de 'MMOD' }
 WriteLI(Length('MMOD'));

  { écrire le mot cle }
 WriteTXT('MMOD');

  { Mémoriser la position dans le fichier }
 P:=FilePos(FMmod);

  { écrire zero dans la longueur en attendant de connaitre la bonne valeur }
 WriteLI(0);

  { Ejecter le mot cle au début de la chaine de caractère }
 EjectTxt(STXM,length('MMOD'));

  { Ecrire le nombre associé }
 WriteLI(NumberLI(STXM));

  { lire la ligne suivante }
 STXM:=ReadFTXM;

 Repeat

   {si STXM est vide, alors lire la ligne suivante }
  if EjectAllPresentKey(STXM) ='' then STXM:=ReadFTXM;

   { Extraire le mot clef }
  KWord:=KeyWord(STXM);

   { exécuter la procédure correspondant au mot cle trouvé }
  KeyWordFind:=false;

  if KWord='BoundingSphere' then begin BoundingSphere(STXM); KeyWordFind:=true; end;
  if KWord='BoundingBox' then begin BoundingBox(STXM); KeyWordFind:=true; end;
  if KWord='Resource' then begin Resource(STXM); KeyWordFind:=true; end;
  if KWord='Hierarchy' then begin Hierarchy(STXM); KeyWordFind:=true; end;

 Until not KeyWordFind or EOF(FTXM);

  { calculer la longueur de la section }
 LI:=FileSize(FMmod)-p-4;

  { écrire la longueur de la section }
 Seek(FMmod,p);
 WriteLI(LI);

  { se replacer à la fin du fichier}
 Seek(FMmod,FileSize(FMmod));

end;

 {*****************************************************************************************************}
 { Converti le fichier TXM vers MMOD                                                                   }
 {*****************************************************************************************************}

Procedure ConvertTXM2Mmod;
var
 STXM : string;             { ligne lue dans le fichier source }
 KWord : string;            { mot clef trouvé }
 KeyWordFind : boolean;
begin
 STXM:='';
 repeat

   {si STXM est vide, alors lire la ligne suivante }
  if EjectAllPresentKey(STXM) ='' then STXM:=ReadFTXM;

  if STXM<>'' then begin
    { lire le mot clef }
   KWord:=KeyWord(STXM);

    { exécuter le procédure correspondant au mot clef trouvé }
   KeyWordFind:=false;
   if KWord='MMOD' then begin MMOD(STXM); KeyWordFind:=true; end;

    { si pas de mot clef trouvé, arrêter le programme }
   if not KeyWordFind then Arreter;
  end;
 until EOF(FTXM);
end;

 {*****************************************************************************************************}
 { trouve tous les fichier source .TXM du répertoire et lance la conversion pour chacun d'eux          }
 {*****************************************************************************************************}

Procedure ConvertAllTXM2Mmod;
var
 F : SearchRec;                  { variable de fichier pour la recherche des fichier dans le répertoire courant }
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

   { contruire une chaine de caractère comportant le nom du fichier .TXM trouvé }
  NameF:=F.Name;

   { vérifier l'extension de fichier }
  if StrMajuscule(RightStr(NameF,4)) = '.TXM' then begin
	
    { afficher le nom de fichier source }
   WriteLN;
   WriteLN('----------------------------------------------------------------');
   Write('Found '+NameF+', converting to ');

    { assigner le fichier source }
   assign(FTXM,NameF);

    { construire le nom du fichier de destination }
   dec(B,3);                { retirer les 3 derniers caractères - l'extension }

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

    { regarder s'il y a un fichier à comparer }
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

    { initialiser le nombre de lignes compilées }
   NLineCompiled:=0;

   inc(NbFile);                    { + 1 fichier }

    { Creer le fichier Mmod à partir du fichier TXM }
   ConvertTXM2Mmod;

    { afficher à l'écran : 'completed'); }
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

  {lancer la conversion de tous les fichier TXM présent dans le répertoire }
 ConvertAllTXM2Mmod;

end.
