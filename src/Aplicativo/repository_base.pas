unit repository_base;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Dialogs, orm, TypInfo, StrUtils;

type

  { TRepositoryBase }

  generic TRepositoryBase<T: class> = class
    private
      function GenerateSelectById(table: TORMTable): string;
    public
      function FindByID(Id: Integer): T;
  end;

implementation

{ TRepositoryBase }

function TRepositoryBase.GenerateSelectById(table: TORMTable): string;
var
  i: Integer;
  s: string;
begin
  s := 'select ' + LineEnding;

  for i := 0 to table.FieldList.Count -1 do
  begin
    s := s + '  ' + table.FieldList[i].DBColumnName;
    s := s + IfThen(i < table.FieldList.Count -1, ', ', ' ') + LineEnding;
  end;
  s := s + 'from ' + table.DBTableName + LineEnding +
    'where id = :id';

  Result := s;
end;

function TRepositoryBase.FindByID(Id: Integer): T;
var
  table: TORMTable;
  model: T;
  select: string;
begin

  table := TORM.FindTableByName(T.ClassName);

  select := GenerateSelectById(table);
  ShowMessage(select);

  model := T.Create;
  SetPropValue(model, 'Nome', 'Rodrigo');

  Result := model;
end;

end.

