unit repository_base;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Dialogs, orm, TypInfo, StrUtils, SQLDB, DateUtils;

type

  { TRepositoryBase }

  generic TRepositoryBase<T: class> = class
    private
      function GenerateSelectByPK(table: TORMTable): string;
      function GenerateInsert(table: TORMTable): string;
    public
      function FindByPK(Id: Integer): T;
      function GetNextSequence: Integer;
      procedure Insert(model: T);
  end;

implementation

uses conexao_dm;

{ TRepositoryBase }

function TRepositoryBase.GenerateSelectByPK(table: TORMTable): string;
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

function TRepositoryBase.GenerateInsert(table: TORMTable): string;
var
  i: Integer;
  s: string;
begin
  s := 'insert into ' + table.DBTableName + '(' + LineEnding;

  for i := 0 to table.FieldList.Count -1 do
  begin
    s := s + '  ' + table.FieldList[i].DBColumnName;
    s := s + IfThen(i < table.FieldList.Count -1, ', ', ')') + LineEnding;
  end;
  s := s + 'values ( ' + LineEnding;

  for i := 0 to table.FieldList.Count -1 do
  begin
    s := s + '  :' + table.FieldList[i].DBColumnName;
    s := s + IfThen(i < table.FieldList.Count -1, ', ', ')') + LineEnding;
  end;

  Result := s;
end;

function TRepositoryBase.FindByPK(Id: Integer): T;
var
  table: TORMTable;
  field: TORMField;
  model: T;
  q:TSQLQuery;
begin

  table := TORM.FindTableByName(T.ClassName);

  q := TSQLQuery.Create(nil);
  q.DataBase := ConexaoDm.Conexao;
  q.SQL.Text := GenerateSelectByPK(table);
  q.ParamByName('Id').Value := Id;
  q.Open;

  model := T.Create;

  for field in table.FieldList do
  begin
    if not q.FieldByName(field.DBColumnName).IsNull then
      SetPropValue(model, field.PPropInfo, q.FieldByName(field.DBColumnName).Value);
  end;

  q.Close;
  q.Free;

  Result := model;
end;

function TRepositoryBase.GetNextSequence: Integer;
var
  table: TORMTable;
  q: TSQLQuery;
begin
  table := TORM.FindTableByName(T.ClassName);

  q := TSQLQuery.Create(nil);
  q.DataBase := ConexaoDm.Conexao;
  q.SQL.Text := 'select next value for SEQUENCE_' + table.DBTableName + ' from RDB$DATABASE';
  q.Open;

  Result := q.Fields[0].AsInteger;

  q.Close;
  q.Free;
end;

procedure TRepositoryBase.Insert(model: T);
var
  table: TORMTable;
  field: TORMField;
  q:TSQLQuery;
begin

  table := TORM.FindTableByName(T.ClassName);

  q := TSQLQuery.Create(nil);
  q.DataBase := ConexaoDm.Conexao;
  q.SQL.Text := GenerateInsert(table);

  for field in table.FieldList do
  begin
    q.ParamByName(field.DBColumnName).Value := GetPropValue(model, field.PPropInfo);
  end;

  q.ExecSQL;;
  q.Free;

end;


end.

