unit application_functions;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Dialogs, LazUTF8;

function RemoveAccent(Text: string): string;

implementation

function RemoveAccent(Text: string): string;
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

end.

