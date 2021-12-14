unit TXMVar;

interface

const

  { Liste des caractères de présentation (espace, tabulation, etc ... }
 ListPresentKey : string = chr(9)+' /=*#{}';

  { liste des lettres }
 ListLetter : string = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';

  { liste des caractères pouvant constituer un mot clef }
 ListLetterKey : string = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ.01234567894_:()';

  { Liste des caratères pouvant constituer un nombre reel }
 ListNumberKeyR : string = '0123456789.-eE';

  { Liste des caractères pouvant constituer un nombre entier signé }
 ListNumberKeyLI : string = '0123456789-';

  { Liste des caractères pouvant constituer un nombre entier positif }
 ListNumberKeyW : string = '0123456789';

 NLineCompiled : longint =0;       { nombre de lignes du fichier source compilées }

var

 FTXM : text;                      { fichier texte source }
 FMmod : file;                     { fichier mmod destination }
 FRapport : text;                  { fichier double du texte source de tout ce qui est lu - permet de retrouver une erreur }
 FComp : file;                     { fichier à comparer au fichier créé }
 FRComp : text;                    { fichier rapport de comparaison }

 Comparer : boolean;               { vrai si le fichier à comparer existe }

implementation

begin
end.

