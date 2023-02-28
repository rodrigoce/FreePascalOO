unit application_functions;

{$mode ObjFPC}{$H+}

interface

uses
  SysUtils, Dialogs, Math;

function RemoveAccent2(Text: string): string;
function PPConvert(Text: string): string;
procedure FreeAndNil2(Obj: TObject);
function TBRound(Value: Extended; Decimals: integer): Extended;

implementation

function RemoveAccent2(Text: string): string;
const
  acentos: string =    'ÄÅÁÂÀÃäáâàãÉÊËÈéêëèÍÎÏÌíîïìÖÓÔÒÕöóôòõÜÚÛüúûùÇç';
  semAcentos: string = 'AAAAAAaaaaaEEEEeeeeIIIIiiiiOOOOOoooooUUUuuuuCc';
var
  unicodeAcentos, unicodeText: UnicodeString;
  i, k: Integer;
begin
  // as strings no freepascal (com projeto/diretivas padrão) são UTF8
  // então caracteres com ascii > 127 usam dois bytes (ou mais)
  // https://wiki.lazarus.freepascal.org/UTF8_strings_and_characters
  // com a função UTF8Decode, nos testes, cada caracter ficou com
  // um byte e o algoritmo funcionou corretamente.
  unicodeAcentos := UTF8Decode(acentos);
  unicodeText := UTF8Decode(Text);

  for i := 1 to Length(unicodeAcentos) do
    for k := 1 to Length(unicodeText) do
      if unicodeText[k] = unicodeAcentos[i] then
        unicodeText[k] := semAcentos[i];

  Result := UTF8Encode(unicodeText);
end;

function PPConvert(Text: string): string;
begin
  Result := LowerCase(RemoveAccent2(Text));
end;

procedure FreeAndNil2(Obj: TObject);
begin
  if Assigned(Obj) then
    FreeAndNil(obj);
end;

{ Esta função faz arredondamento de valores reais para "n" casas
  decimais após o separador decimal, seguindo os critérios das
  calculadoras financeiras e dos bancos de dados InterBase e FireBird.
  https://tecnobyte.com.br/124613446/Delphi-Outros/Como-fazer-arredondamento-financeiro
}
function TBRound(Value: Extended; Decimals: integer): Extended;
var
  Factor, Fraction: Extended;
begin
  Factor := IntPower(10, Decimals);
  { A conversão para string e depois para float evita
    erros de arredondamentos indesejáveis. }
  Value := StrToFloat(FloatToStr(Value * Factor));
  Result := Int(Value);
  Fraction := Frac(Value);
  if Fraction >= 0.5 then
    Result := Result + 1
  else if Fraction <= -0.5 then
    Result := Result - 1;
  Result := Result / Factor;
end;

end.

