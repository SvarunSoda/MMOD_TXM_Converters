program MMODHierarchy;

uses dos,strutils;

var
 FRec : SearchRec;
 Fmmod : file;
 Ftxt : text;
 NbResource,
 NbMesh,
 NbAux,
 NbGeomMesh,
 NbConvexObject,
 NbNote,
 NbGroupParams,
 NbAnimatinChannels,
 NbGeom                    : integer;

const
 PremiereRecherche : boolean = true;

Function ReadKeyWord : string;
var
 LI : longint;
 S : string;
begin
 ReadKeyWord:='';                       { valeur par défaut }
  {$I-}
 BlockRead(FMmod,LI,4);                 { lit la longueur du mot }
  {$I+}

 if IOResult<>0 then exit;

  {$I-}
 BlockRead(FMmod,S[1],LI);                 { lit le mot clef }
  {$I+}
 S[0]:=chr(LI);

 if IOResult=0 then ReadKeyWord:=S;     { met à jour la valeur de la fonction }

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

Procedure ReadResource;
var
 NbMesh : integer;
 PosEnd,                           { position de la fin de la section Resource }
 LI,
 LSection,
 PosNextSection            : longint;
 S,
 KeyWord,
 KeyWord2            : string;
 KeyWordFound : boolean;
 R : single;
begin
 BlockRead(FMmod,LSection,4);            { lire la longueur de la section }
 PosEnd:=FilePos(FMmod)+LSection;        { mémoriser la position de la fin de la section }
 NbMesh:=0;

  { rechercher les 'Mesh' }
 while FilePos(FMmod)<PosEnd do begin
  KeyWord:=ReadKeyWord;

  if KeyWord<>'' then begin

   BlockRead(FMmod,LSection,4);
   PosNextSection:=FilePos(FMmod)+LSection;
   KeyWordFound:=false;

   if (KeyWord='Mesh') or (KeyWord='MatrixIndexedMesh') then begin

    KeyWordFound:=true;
    Writeln(FTxt,'Resource ',NbResource:3,' : Mesh ',NbMesh);

    inc(NbMesh);

   end;

   if KeyWord='Aux' then begin

    KeyWordFound:=true;

    while FilePos(FMmod)<PosNextSection do begin

     KeyWord2:=ReadKeyWord;
     if KeyWord2=('Identifier') then begin

      BlockRead(FMmod,LI,4);
      Write(FTxt,'Resource ',NbResource:3,' : Aux ',ReadKeyWord,' ');
      BlockRead(FMmod,LI,4);
      WriteLN(FTxt,LI);

      Break;

     end
     else
     begin
      BlockRead(FMmod,LI,4);
      Seek(FMmod,FilePos(FMmod)+LI);
     end;
    end;

    inc(NbAux);

   end;

   if KeyWord='GeomMesh' then begin

    KeyWordFound:=true;
    Writeln(FTxt,'Resource ',NbResource:3,' : GeomMesh ',NbGeomMesh);

    inc(NbGeomMesh);

   end;

   if KeyWord='ConvexObject' then begin

    KeyWordFound:=true;
    Writeln(FTxt,'Resource ',NbResource:3,' : ConvexObject ',NbConvexObject);

    inc(NbConvexObject);

   end;

   if KeyWord='Note' then begin

    KeyWordFound:=true;
    Writeln(FTxt,'Resource ',NbResource:3,' : Note ',ReadKeyWord);

    inc(NbNote);

   end;

   if KeyWord='GroupParams' then begin

    KeyWordFound:=true;
    BlockRead(FMmod,R,4);
    Writeln(FTxt,'Resource ',NbResource:3,' : GroupParams ',R:14:6);

    inc(NbGroupParams);

   end;

   if KeyWord='AnimationChannels' then begin

    KeyWordFound:=true;
    Writeln(FTxt,'Resource ',NbResource:3,' : AnimationChannels ',NbAnimatinChannels);

    inc(NbAnimatinChannels);

   end;

   if KeyWord='Geom' then begin

    KeyWordFound:=true;
    Writeln(FTxt,'Resource ',NbResource:3,' : Geom ',NbGeom);

    inc(NbGeom);

   end;

   if KeyWord='SceneError' then begin

    KeyWordFound:=true;
    Writeln(FTxt,'Resource ',NbResource:3,' : SceneError ');

   end;

   if KeyWordFound then begin

    { se placer sur la section suivante }
    Seek(FMmod,PosNextSection);

   end
   else
   begin

    WriteLN('**************************');
    Writeln(KeyWord,' UNKNOWN !!!');
    WriteLN('**************************');
    Writeln('Program stopped');
    Writeln('Entrer to go on');
    ReadLN;
    halt;

   end;

   inc(NbResource);

  end;
 end;

 Writeln(FTxt);
 WriteLN(FTxt,'Nb Mesh : ',NbMesh);
 Writeln(FTxt,'Nb GeomMesh : ',NbGeomMEsh);
 WriteLN(Ftxt,'Nb Geom : ',NbGeom);
 Writeln(FTxt,'Nb ConvexObject : ',NbConvexObject);
 WriteLN(FTxt,'Nb Aux : ',NbAux);
 WriteLN(FTxt,'Nb Note : ',NbNote);
 WriteLN(FTxt,'Nb AnimatinChannels : ',NbAnimatinChannels);
 WriteLN(FTxt,'Nb GroupParams : ',NbGroupParams);

end;

Procedure ReadHierarchy;
var
 S : string;
 i : integer;
 NbItem : integer;
 LI,
 LSection,
 NextSection,
 PosEnd,
 PosBeginItem,
 PosEndItem : longint;
 KeyWord : string;
begin
 BlockRead(FMmod,LSection,4);            { lire la longueur de la section }
 PosEnd:=FilePos(FMmod)+LSection;        { mémoriser la position de la fin de la section }

 NbItem:=0;

 while FilePos(FMmod)<PosEnd do begin
  KeyWord:=ReadKeyWord;

  if KeyWord='Item' then begin
   Writeln(FTxt);
   Write(FTxt,'Item ',NbItem:3,' : ');
   BlockRead(FMmod,LSection,4);
   PosBeginItem:=FilePos(FMmod);
   PosEndItem:=FilePos(FMmod)+LSection;

    { trouver le nom de l'item }
   While FilePos(FMmod)<PosEndItem do begin
    if ReadKeyWord='Name' then begin
     BlockRead(FMmod,LSection,4);
     WriteLN(FTxt,ReadKeyWord);
     Break;
    end
    else
    begin
     BlockRead(FMmod,LSection,4);
     Seek(FMmod,FilePos(FMmod)+LSection);
    end;

   end;

    { lire les resources de l'item }
   Seek(FMmod,PosBeginItem);
   While FilePos(FMmod)<PosEndItem do begin
    KeyWord:=ReadKeyWord;
    BlockRead(FMmod,LSection,4);
    NextSection:=FilePos(FMmod)+LSection;
    if KeyWord='Parent' then begin
     BlockRead(FMmod,LI,4);
     WriteLN(FTxt,Chr(9),'Parent ',LI);
    end;
    if KeyWord='Resource' then begin
     BlockRead(FMmod,LI,4);
     Reset(FTxt);
     for i:=0 to LI do ReadLN(Ftxt,S);
     append(FTxt);
     WriteLN(FTxt,Chr(9)+S);
    end;

    seek(FMmod,NextSection);

   end;

   inc(NbItem);

  end;
 end;
end;

Procedure ReadFMmod;
var
 keyword : string;
 LI : longint;
begin

  { initialisation des variables }
 NbResource           :=0;
 NbMesh               :=0;
 NbAux                :=0;
 NbGeomMesh           :=0;
 NbConvexObject       :=0;
 NbNote               :=0;
 NbGroupParams        :=0;
 NbAnimatinChannels   :=0;
 NbGeom               :=0;

 if ReadKeyWord = 'MMOD' then begin

   { éjecter les deux nombres suivants }
  BlockRead(FMmod,LI,4);
  BlockRead(FMmod,LI,4);

   { Trouver 'Resource' }
  Repeat

    { lire le mot clef }
   KeyWord:=ReadKeyWord;

   if KeyWord='Resource' then begin

     { Resource a été trouvé }
    ReadResource;

   end
   else
   begin

    if KeyWord='Hierarchy' then begin

      { Hierarchy a été trouvé }
     ReadHierarchy;

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
   end;
  until KeyWord='';
 end
 else
 begin
  Writeln(' ================== ce fichier n''est pas au format MMOD  ================ ');
  ReadLN;
  halt;
 end;


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

 NbFile := 0;

 while FindNextMmodFile(NameF) do begin

  Writeln(NameF,' read');

  assign(FMmod,NameF);
  reset(FMmod,1);

  NameF:=LeftStr(NameF,Length(NameF)-5);

  assign(FTxt,NameF+'_Hierarchy.TXT');
  Rewrite(FTxt);

  ReadFMmod;

  Close(FTxt);
  close(FMmod);

  inc(NbFile);
 end;

 str(NbFile,S);
 WriteLN;
 if NbFile=0 then
  WriteLN('NO MMOD FILE FOUND !')
 else
  if NbFile=1 then
    WriteLN('1 file read')
   else
    WriteLN(S+' files read');
 WriteLN('Presse "ENTER" to go on.');
 ReadLN(S);

end.

