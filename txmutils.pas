unit TXMUtils;

interface

uses TXMVar, crt;

Procedure Arreter;
Function StrMajuscule(s:string):string;
Function CharInList(C : char; Liste : string) : boolean;
Function CharOfTextInList(Text,List : string) : boolean;
Function EjectFirstPresentKey(S : string) : string;
Function EjectAllPresentKey(S : string) : string;
Function ReadFTXM : string;
Procedure EjectTxt(var STXM : string; I : integer);
Function KeyWord(S : string) : string;
Function NumberW(var S : string) : word;
Function NumberLI(var S : string) : longint;
Function NumberR(var S : string) : single;
Function NumberB(var S : string) : byte;
Procedure WriteW(W : word);
Procedure WriteLI(LI : longint);
Procedure WriteR(R : single);
Procedure WriteB(B : byte);
Procedure WriteTXT(TXT:string);
Procedure EjectTXTUntillKey(var S : string; C : char);
Procedure StopOnEscape;

implementation

 {******************************************************************************************************}
 { interrompt la conversion de fichier. Normalement suite à une erreur dans le fichier source           }
 {******************************************************************************************************}

Procedure Arreter;
var
 s: string;
begin

  { ferme les fichiers }
  {$i-}
 close(FRapport);
 close(FTXM);
 close(FMmod);
  {$i+}

  if IOResult=0 then ;   { lire IOResult pour pour débloquer l'éventuel erreur de fichier }

  { informer l'utilisateur }
 WriteLN;
 WriteLN('*************************');
 WriteLN('*************************');
 WriteLN('*                       *');
 WriteLN('*  CONVERSION HALTED!   *');
 WriteLN('*                       *');
 WriteLN('*************************');
 WriteLN('*************************');
 WriteLN;
 WriteLN('If there was an error, open the "RAPPORT.TXT" file for further details.');
 WriteLN;
 WriteLN('Press "ENTER" to exit.');
 ReadLN(S);

  { arrête le programme }
 halt;
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

  {*****************************************************************************************************}
  { retourne vrai si 'C' est contenu dans la chaine 'Liste', sinon faux                                 }
  {*****************************************************************************************************}

Function CharInList(C : char; Liste : string) : boolean;
var
 i : integer;
begin
 CharInList:=false; { est faux par défaut }
 for i:=1 to Length(Liste) do if C=Liste[i] then CharInList:=true;
end;

  {*****************************************************************************************************}
  { retourne vrai si une des lettre de Text est présente dans la chaine 'Liste', sinon faux             }
  {*****************************************************************************************************}

Function CharOfTextInList(Text,List : string) : boolean;
var
 i : integer;
begin
 CharOfTextInList:=false;         { est faux par défaut }
 for i:=1 to Length(Text) do if CharInList(Text[i],List) then CharOfTextInList:=true;
end;


  {*****************************************************************************************************}
  { Retourne la chaine 'S' débarassée de tous les caractères de présentation du début de 'S'            }
  {*****************************************************************************************************}

Function EjectFirstPresentKey(S : string) : string;
var
 i,j : integer;
 S1 : string; {stockage provisoir de la nouvelle chaine de caractère }
begin

 i:=1;

  { trouver le premier caractère qui ne soit pas un caractère de présentation }
 while (i<=length(S)) and CharInList(S[i],ListPresentKey) do inc(i);

  { construire la chaine sans les caractères de présentation }
 S1:='';
 if i<=Length(S) then for j:=i to Length(S) do S1:=S1+S[j];

  { affecter la bonne valeur à la fonction }
 EjectFirstPresentKey:=S1;


end;

  {*****************************************************************************************************}
  { retourne la chaine 'S' débarassée de tous ses caractères de présentation                            }
  {*****************************************************************************************************}

Function EjectAllPresentKey(S : string) : string;
var
 i : integer;
 S1 : string; { stockage provisoire de la nouvelle chaine de caractères }
begin

  { initialiser la nouvelle chaine de caractères }
 S1:='';

  { compléter la chaine quand ce n'est pas un caractère de présentation }
 for i:=1 to length(S) do if not(CharInList(S[i],ListPresentKey)) then S1:=S1+S[i];

  { affecter la bonne valeur à la fonction }
 EjectAllPresentKey:=S1;

end;

  {*****************************************************************************************************}
  { Lit la ligne suivante du fichier source et fait une copie de la lecture dans le fichier rapport     }
  {*****************************************************************************************************}

Function ReadFTXM : string;
var
 S : string;
begin

 StopOnEscape;

 Repeat
  if EOF(FTXM) then begin ReadFTXM:=''; exit; end;

  {lire une ligne dans le fichier source }
   {$i-}
  ReadLN(FTXM,S);
   {$i+}

  if (IOResult<>0) then begin
   writeln;
   writeln('========== READ ERROR on source file !!! =============');
   Arreter; { erreur de lecture : arrêter le programme }

  end;
   { incrémenté le nombre de ligne du fichier source compilées }
  inc(NLineCompiled);

   { ecrire sur l'écran le Nb de lignes compilées }
  Write(chr(8)); Write(chr(8)); Write(chr(8)); Write(chr(8)); Write(chr(8)); Write(chr(8)); Write(chr(8)); Write(chr(8));
  Write(NLineCompiled:8);

   { Ecrire la ligne lue dans le fichier Rapport }
  WriteLN(FRapport,S);
  close(FRapport);
  append(FRapport);

   { si c'est une ligne de remarque, lire la ligne suivante }
  if (S<>'') and (S[1]='#') then S:='';

 until EjectAllPresentKey(S)<>'';

  { Mettre à jour la valeur de la fonction }
 ReadFTXM := EjectFirstPresentKey(S);

end;

  {*****************************************************************************************************}
  { Ejecte les I premiers caractères de la chaine STXM                                                   }
  {*****************************************************************************************************}

Procedure EjectTxt(var STXM : string; I : integer);
var
 j : integer;
 B : byte absolute STXM;
begin

 if i<0 then Arreter;                                { impossible à réaliser }

 if i>Length(STXM) then i:=Length(STXM);             { si i est trop grand, ajuster sa }

  { déplacer les caractères de la chaine de i vers l'avant }
 for j:=1 to Length(STXM)-i do STXM[j]:=STXM[j+i];

  { mettre la chaine de caractère à la bonne longueur }
 dec(B,i);

end;

  {*****************************************************************************************************}
  { Trouve le mot clef au début de la chaine S                                                          }
  {*****************************************************************************************************}

Function KeyWord(S : string) : string;

var
 i,j : integer;
 S1,          {stockage provisoir de la chaine débarassée du mot clef }
 KW : string; {stockage provisoir du mot clef }

begin

  { ejecter les caractère de présentation du début de ligne }
 S:=EjectFirstPresentKey(S);

  { construire le mot clef en trouvant le 1er caractère n'étant pas dans la liste des lettres possibles }
 KW:='';
 i:=1;
 while (i<=length(S)) and CharInList(S[i], ListLetterKey) do begin
  KW:=KW+S[i];
  inc(i);
 end;

  { affecter la bonne valeur à la fonction }
 KeyWord:=KW;

end;

  {*****************************************************************************************************}
  { Trouve le nombre de type Word dans la chaine S et ejecte celui-ci de S                                         }
  {*****************************************************************************************************}

Function NumberW(var S : string) : word;
var
 i,j : integer;
 S1,          {stockage provisoir de la chaine débarassée du mot clef }
 KW : string; {stockage provisoir du mot clef }
 C : integer;
 W : word;
begin

  { ejecter les caractère de présentation du début de ligne }
 S:=EjectFirstPresentKey(S);

  { construire le mot clef en trouvant le 1er caractère n'étant pas dans la liste des lettres possibles }
 KW:='';
 i:=1;
 while (i<=length(S)) and CharInList(S[i], ListNumberKeyW) do begin
  KW:=KW+S[i];
  inc(i);
 end;

  { Ejecter le nombre en construisant une chaine de caractère sans celui-ci }
 S1:='';
 for j:=i to length(S) do S1:=S1+S[j];

  { affecter la nouvelle valeur à S }
 S:=S1;

  { affecter la bonne valeur à la fonction }
 val(KW,W,C);
 if C<>0 then arreter;  { Erreur de nombre, arrêter le programme }
 NumberW:=W;

end;

  {*****************************************************************************************************}
  { Trouve le nombre de type entier long dans la chaine S et ejecte celui-ci de S                       }
  {*****************************************************************************************************}

Function NumberLI(var S : string) : longint;
var
 i,j : integer;
 S1,          {stockage provisoir de la chaine débarassée du mot clef }
 KW : string; {stockage provisoir du mot clef }
 C : integer;
 LI : longint;
begin

  { ejecter les caractère de présentation du début de ligne }
 S:=EjectFirstPresentKey(S);

  { construire le mot clef en trouvant le 1er caractère n'étant pas dans la liste des lettres possibles }
 KW:='';
 i:=1;
 while (i<=length(S)) and CharInList(S[i], ListNumberKeyLI) do begin
  KW:=KW+S[i];
  inc(i);
 end;

  { Ejecter le nombre en construisant une chaine de caractère sans celui-ci }
 S1:='';
 for j:=i to length(S) do S1:=S1+S[j];

  { affecter la nouvelle valeur à S }
 S:=S1;

  { affecter la bonne valeur à la fonction }
 val(KW,LI,C);
 if C<>0 then arreter;  { Erreur de nombre, arreêter le programme }
 NumberLI:=LI;

end;

  {*****************************************************************************************************}
  { Trouve le nombre de type reel dans la chaine S et ejecte celui-ci de S                                         }
  {*****************************************************************************************************}

Function NumberR(var S : string) : single;
const
 Nan : array[1..4] of byte = (0,0,192,255);
 PlusInf : array[1..4] of byte = (0,0,128,127);
 MoinsInf : array[1..4] of byte = (0,0,128,255);
var
 i,j : integer;
 S1,          {stockage provisoir de la chaine débarassée du mot clef }
 KW : string; {stockage provisoir du mot clef }
 C : integer;
 R : single;
 MotSpecial : boolean;
 RNan : single absolute Nan;
 RPlusinf : single absolute PlusInf;
 RMoinsinf : single absolute MoinsInf;
begin

  { ejecter les caractère de présentation du début de ligne }
 S:=EjectFirstPresentKey(S);

  { regarder s'il s'agit d'un mot code 'Nan', '+Inf', ou '-Inf' }
 MotSpecial:=false;
 if (length(S)>=3) and (S[1]='N') and (S[2]='a') and (S[3]='n') then begin

   { il s'agit de 'Nan' }
  MotSpecial:=true;
  NumberR:=RNan;

   { éjecter les caractères correspondants }
  EjectTxt(S,LEngth('Nan'));
 end
 else
 begin

  if (length(S)>=4) and (S[1]='+') and (S[2]='I') and (S[3]='n') and (S[4]='f') then begin

    { il s'agit de '+Inf' }
   MotSpecial:=true;
   NumberR:=RPlusInf;

    { éjecter les caractères correspondants }
   EjectTxt(S,LEngth('+Inf'));

  end
  else
  begin

   if (length(S)>=4) and (S[1]='-') and (S[2]='I') and (S[3]='n') and (S[4]='f') then begin

     { il s'agit de '-Inf' }
    MotSpecial:=true;
    NumberR:=RMoinsInf;

     { éjecter les caractères correspondants }
    EjectTxt(S,LEngth('+Inf'));
   end;
  end;
 end;


 if not MotSpecial then begin

    { construire le mot clef en trouvant le 1er caractère n'étant pas dans la liste des lettres possibles }
  KW:='';
  i:=1;
  while (i<=length(S)) and CharInList(S[i], ListNumberKeyR) do begin
   KW:=KW+S[i];
   inc(i);
  end;

   { Ejecter le nombre en construisant une chaine de caractère sans celui-ci }
  S1:='';
  for j:=i to length(S) do S1:=S1+S[j];

   { affecter la nouvelle valeur à S }
  S:=S1;

   { affecter la bonne valeur à la fonction }
  val(KW,R,C);
  if C<>0 then arreter;  { Erreur de nombre, arreêter le programme }
  NumberR:=R;

 end;
end;

  {*****************************************************************************************************}
  { Trouve le nombre de type Byte dans la chaine S et ejecte celui-ci de S                                         }
  {*****************************************************************************************************}

Function NumberB(var S : string) : byte;
var
 i,j : integer;
 S1,          {stockage provisoir de la chaine débarassée du mot clef }
 KW : string; {stockage provisoir du mot clef }
 C : integer;
 B : byte;
begin

  { ejecter les caractère de présentation du début de ligne }
 S:=EjectFirstPresentKey(S);

  { construire le mot clef en trouvant le 1er caractère n'étant pas dans la liste des lettres possibles }
 KW:='';
 i:=1;
 while (i<=length(S)) and CharInList(S[i], ListNumberKeyLI) do begin
  KW:=KW+S[i];
  inc(i);
 end;

  { Ejecter le nombre en construisant une chaine de caractère sans celui-ci }
 S1:='';
 for j:=i to length(S) do S1:=S1+S[j];

  { affecter la nouvelle valeur à S }
 S:=S1;

  { affecter la bonne valeur à la fonction }
 val(KW,B,C);
 if C<>0 then arreter;  { Erreur de nombre, arreêter le programme }
 NumberB:=B;

end;

 {*****************************************************************************************************}
 { écrit W dans FMmod                                   }
 {*****************************************************************************************************}

Procedure WriteW(W : word);
var
 LI : longint;
 W2 : word;
begin
 if comparer then begin
  Seek(FComp,filePos(FMmod));
  BlockRead(FComp,W2,2);
  if W<>W2 then begin
   LI:=filepos(FMmod);
   WriteLN(FRComp,'position : ',LI,'. Valeur lue = ',W2,'. Valeur écrite = ',W);
  end;
 end;

 BlockWrite(FMmod,W,2);

end;

 {*****************************************************************************************************}
 { écrit LI dans FMmod                                   }
 {*****************************************************************************************************}

Procedure WriteLI(LI : longint);
var
 LI2,
 LI3 : longint;
begin
 if comparer then begin
  Seek(FComp,filePos(FMmod));
  BlockRead(FComp,LI2,4);
  if LI<>LI2 then begin
   LI3:=filepos(FMmod);
   WriteLN(FRComp,'position : ',LI3,'. Valeur lue = ',LI2,'. Valeur écrite = ',LI);
  end;
 end;

 BlockWrite(FMmod,LI,4);
end;

 {*****************************************************************************************************}
 { écrit R dans FMmod                                   }
 {*****************************************************************************************************}

Procedure WriteR(R : single);
begin
 BlockWrite(FMmod,R,4);
end;

 {*****************************************************************************************************}
 { écrit B dans FMmod                                   }
 {*****************************************************************************************************}

Procedure WriteB(B : byte);
var
 LI : longint;
 B2 : word;
begin
 if comparer then begin
  Seek(FComp,filePos(FMmod));
  BlockRead(FComp,B2,1);
  if B<>B2 then begin
   LI:=filepos(FMmod);
   WriteLN(FRComp,'position : ',LI,'. Valeur lue = ',B2,'. Valeur écrite = ',B);
  end;
 end;

 BlockWrite(FMmod,B,1);
end;

 {*****************************************************************************************************}
 { écrite TXT dans FMmod }
 {*****************************************************************************************************}

Procedure WriteTXT(TXT:string);
var
 LI : longint;
 TXT2 : string;
begin
 if comparer then begin
  Seek(FComp,filePos(FMmod));
  BlockRead(FComp,TXT2[1],Length(TXT));
  TXT2[0]:=chr(Length(TXT));
  if TXT<>TXT2 then begin
   LI:=filepos(FMmod);
   WriteLN(FRComp,'position : ',LI,'. Valeur lue = ',TXT2,'. Valeur écrite = ',TXT);
  end;
 end;

 if TXT<>'' then Blockwrite(FMmod,TXT[1],length(TXT));
end;

 {*****************************************************************************************************}
 { retirer les premiers caractères de S jusqu'à rencontrer C                                           }
 { C n'est pas éjecté                                                                                  }
 {*****************************************************************************************************}

Procedure EjectTXTUntillKey(var S : string; C : char);
begin
 while (Length(S)>0) and (S[1]<>C) do EjectTXT(S,1);
end;

Procedure StopOnEscape;
var
 key : char;
begin
 if Keypressed then begin
  Key:=Readkey;
  if key = Chr(27) then begin
   WriteLN;
   WriteLN('====== STOPPED BY THE USER ==========');
   arreter; { esc est pressé par l'utilisateur :> arreter le programme }
  end;
 end;
end;


begin
end.

