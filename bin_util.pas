unit Bin_Util;


interface

type
 Float_16 = word;

Function decompress_Float_16(value : Float_16) : single;
Function BitToLeft(DW : DWord ; N :integer) : DWord;
Function BitToRight(DW : DWord ; N :integer) : DWord;
Function ORL(DW1, DW2 : DWord) : DWord;
Function ANDL(DW1, DW2 : DWord) : DWord;
Function XORL(DW1, DW2 : DWord) : DWord;

implementation

const
 Tab_Bit : array[0..pred(8*4)] of DWord =
  ($1,       $2,       $4,       $8,       $10,       $20,       $40,       $80,
   $100,     $200,     $400,     $800,     $1000,     $2000,     $4000,     $8000,
   $10000,   $20000,   $40000,   $80000,   $100000,   $200000,   $400000,   $800000,
   $1000000, $2000000, $4000000, $8000000, $10000000, $20000000, $40000000, $80000000);

type
 T_Bool32 = array[0..pred(8*4)] of boolean;

 { décale les bit de DW de N vers la gauche }

Function BitToLeft(DW : DWord ; N :integer) : DWord;
var
 i  : integer;
begin
 for i:=1 to N do DW:=DW*2;
 BitToLeft:=DW;
end;

 { décale les bit de DW de N vers la droite }

Function BitToRight(DW : DWord ; N :integer) : DWord;
var
 i : integer;
begin
 for i:=1 to N do DW:=DW div 2;
 BitToRight:=DW;
end;

 { retourne un OR logique bit à bit entre DW1 et DW2 }
Function ORL(DW1, DW2 : DWord) : DWord;
var
 DW3 : DWord;
 Bool1, Bool2 : T_Bool32;
 i : integer;
begin

 for i:=0 to 31 do begin

   { remplir Bool1 }
  if DW1>=Tab_Bit[31-i] then begin
   Bool1[31-i]:=true;
   dec(DW1,Tab_Bit[31-i]);
  end
  else
   Bool1[31-i]:=false;

   { remplir Bool2 }
  if DW2>=Tab_Bit[31-i] then begin
   Bool2[31-i]:=true;
   dec(DW2,Tab_Bit[31-i]);
  end
  else
   Bool2[31-i]:=false;
 end;

 DW3:=0;

 for i:=0 to 31 do
  if (Bool1[i] or Bool2[i]) then inc(DW3,Tab_Bit[i]);

 ORL:=DW3;
end;


 { retourne un AND logique bit à bit entre DW1 et DW2 }
Function ANDL(DW1, DW2 : DWord) : DWord;
var
 DW3 : DWord;
 Bool1, Bool2 : T_Bool32;
 i : integer;
begin

 for i:=0 to 31 do begin

   { remplir Bool1 }
  if DW1>=Tab_Bit[31-i] then begin
   Bool1[31-i]:=true;
   dec(DW1,Tab_Bit[31-i]);
  end
  else
   Bool1[31-i]:=false;

   { remplir Bool2 }
  if DW2>=Tab_Bit[31-i] then begin
   Bool2[31-i]:=true;
   dec(DW2,Tab_Bit[31-i]);
  end
  else
   Bool2[31-i]:=false;
 end;
 DW3:=0;

 for i:=0 to 31 do
  if (Bool1[i] and Bool2[i]) then inc(DW3,Tab_Bit[i]);

 ANDL:=DW3;
end;

 { retourne un XOR logique bit à bit entre DW1 et DW2 }
Function XORL(DW1, DW2 : DWord) : DWord;
var
 DW3 : DWord;
 Bool1, Bool2 : T_Bool32;
 i : integer;
begin
 for i:=0 to 31 do begin

   { remplir Bool1 }
  if DW1>=Tab_Bit[31-i] then begin
   Bool1[31-i]:=true;
   dec(DW1,Tab_Bit[31-i]);
  end
  else
   Bool1[31-i]:=false;

   { remplir Bool2 }
  if DW2>=Tab_Bit[31-i] then begin
   Bool2[31-i]:=true;
   dec(DW2,Tab_Bit[31-i]);
  end
  else
   Bool2[31-i]:=false;
 end;
 DW3:=0;

 for i:=0 to 31 do
  if (Bool1[i] xor Bool2[i]) then inc(DW3,Tab_Bit[i]);

 XORL:=DW3;
end;


Function decompress_Float_16(value : Float_16) : single;

 var
  IVF1   : word absolute value;
  S,E,M : DWord;
  R      : single absolute S;
  ABCDEFG      : string;

begin
 S:=ANDL(BitToRight(IVF1,15),  $00000001);
 E:=ANDL(BitToRight(IVF1,10),  $0000001F);
 M:=ANDL(IVF1,                 $000003FF);
 if E=0 then begin
  if m=0 then begin
   decompress_Float_16:=BitToLeft(S,31);
   exit;
  end
  else
  begin
   while ANDL(M,$00000400)=0 do begin
	M:=BitToLeft(M,1);
	if E > 0 then begin
     dec(E);
	end;
   end;
  end;
 end
 else
 begin
  if E=31 then begin
   if M=0 then begin
      { inf }
	decompress_Float_16:=0;
    exit;
   end
   else
   begin
      { nan }
	decompress_Float_16:=0;
    exit;
   end;
  end;
 end;
 S:=BitToLeft(S,31);
 E:=BitToLeft((E+127)-15,23);
 M:=BitToLeft(M,13);
 S:=ORL(ORL(S,E),M);
 decompress_Float_16:=R;
end;

begin
end.


