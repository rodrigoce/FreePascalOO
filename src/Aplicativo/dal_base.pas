unit dal_base;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Dialogs, mini_orm, TypInfo, StrUtils, SQLDB, DateUtils;

type

  { TDALBase }

  generic TDALBase<T: class> = class
    private
      function GenerateInsert(ormEntity: TORMEntity): string;
    public
      // para chaves compostas pode ser passado VarArrayOf
      function FindByPK(Id: Variant): T;
      // pega próximo valor da sequence
      function GetNextSequence: Integer;
      procedure Insert(entity: T);
      procedure Update(entity: T);
  end;

implementation

uses conexao_dm;

{ TDALBase }

function TDALBase.GenerateInsert(ormEntity: TORMEntity): string;
var
  i: Integer;
  s: string;
begin
  s := 'insert into ' + ormEntity.DBTableName + '(' + LineEnding;

  for i := 0 to ormEntity.FieldList.Count -1 do
  begin
    s := s + '  ' + ormEntity.FieldList[i].DBColumnName;
    s := s + IfThen(i < ormEntity.FieldList.Count -1, ', ', ')') + LineEnding;
  end;
  s := s + 'values ( ' + LineEnding;

  for i := 0 to ormEntity.FieldList.Count -1 do
  begin
    s := s + '  :' + ormEntity.FieldList[i].DBColumnName;
    s := s + IfThen(i < ormEntity.FieldList.Count -1, ', ', ')') + LineEnding;
  end;

  Result := s;
end;

function TDALBase.FindByPK(Id: Variant): T;
var
  ormEntity: TORMEntity;
  ormField: TORMField;
  entity: T;
  q: TSQLQuery;
  i, countPKFields: Integer;
  s: string;
begin

  ormEntity := TORM.FindORMEntity(T.ClassName);
  countPKFields := ormEntity.CountPK;

  //
  // monta o select
  //

  s := 'select ' + LineEnding;

  i := 0;
  for ormField in ormEntity.FieldList do
  begin
    s := s + '  ' + ormField.DBColumnName;
    s := s + IfThen(i < ormEntity.FieldList.Count -1, ', ', ' ') + LineEnding;
    Inc(i);
  end;
  s := s + 'from ' + ormEntity.DBTableName + LineEnding +
    'where';

  if (countPKFields = 0) then
    raise Exception.Create(ormEntity.DBTableName + ' não tem chave primária.');

  i := 1;
  for ormField in ormEntity.FieldList do
  begin
    if ormField.IsPK then
    begin
      s := s + '  ' + ormField.DBColumnName + ' = :' + ormField.DBColumnName;
      s := s + IfThen(i < countPKFields, LineEnding + '  and', '');
      Inc(i);
    end;
  end;

  //
  // alimenta os parâmetros
  //

  q := TSQLQuery.Create(nil);
  q.DataBase := ConexaoDm.Conexao;
  q.SQL.Text := s;

  // implementar alimentar o parâmetros de chave composta como
  // em TDataSet.Locate
  for ormField in ormEntity.FieldList do
  begin
    if ormField.IsPK then
      q.ParamByName(ormField.DBColumnName).Value := Id;
  end;

  q.Open;

  //
  // transpõem os valores para a entidade
  //

  entity := T.Create;

  for ormField in ormEntity.FieldList do
  begin
    if not q.FieldByName(ormField.DBColumnName).IsNull then
      SetPropValue(entity, ormField.PPropInfo, q.FieldByName(ormField.DBColumnName).Value);
  end;

  q.Close;
  q.Free;

  Result := entity;
end;

function TDALBase.GetNextSequence: Integer;
var
  ormEntity: TORMEntity;
  q: TSQLQuery;
begin
  ormEntity := TORM.FindORMEntity(T.ClassName);

  q := TSQLQuery.Create(nil);
  q.DataBase := ConexaoDm.Conexao;
  q.SQL.Text := 'select next value for SEQUENCE_' + ormEntity.DBTableName + ' from RDB$DATABASE';
  q.Open;

  Result := q.Fields[0].AsInteger;

  q.Close;
  q.Free;
end;

procedure TDALBase.Insert(entity: T);
var
  ormEntity: TORMEntity;
  ormField: TORMField;
  q: TSQLQuery;
begin

  ormEntity := TORM.FindORMEntity(T.ClassName);

  q := TSQLQuery.Create(nil);
  q.DataBase := ConexaoDm.Conexao;
  q.SQL.Text := GenerateInsert(ormEntity);

  for ormField in ormEntity.FieldList do
  begin
    q.ParamByName(ormField.DBColumnName).Value := GetPropValue(entity, ormField.PPropInfo);
  end;

  q.ExecSQL;;
  q.Free;

end;

procedure TDALBase.Update(entity: T);
var
  ormEntity: TORMEntity;
  ormField: TORMField;
  q: TSQLQuery;
  s: string;
  i, countPKFields, countCommonFields: Integer;

begin

  countPKFields := ormEntity.CountPK;
  countCommonFields := ormEntity.FieldList.Count - countPKFields;

  //
  // monta a string com o update
  //
  ormEntity := TORM.FindORMEntity(T.ClassName);

  s := 'update ' + ormEntity.DBTableName + ' set ' + LineEnding;

  i := 0;
  for ormField in ormEntity.FieldList do
  begin
    // apenas campos não PK entram no update
    if not ormField.IsPK then
    begin
      s := s + '  ' + ormField.DBColumnName + ' = :' + ormField.DBColumnName;
      s := s + IfThen(i < countCommonFields -1, ', ', '') + LineEnding;
      Inc(i);
    end;
  end;

  s := s + 'where' + LineEnding;

  if (countPKFields = 0) then
    raise Exception.Create(ormEntity.DBTableName + ' não tem chave primária não pode ser atualizada.');

  i := 1;
  for ormField in ormEntity.FieldList do
  begin
    if ormField.IsPK then
    begin
      s := s + '  ' + ormField.DBColumnName + ' = :' + ormField.DBColumnName;
      s := s + IfThen(i < countPKFields, LineEnding + '  and', '');
      Inc(i);
    end;
  end;

  //
  // alimenta os parâmetros da query
  //

  q := TSQLQuery.Create(nil);
  q.DataBase := ConexaoDm.Conexao;
  q.SQL.Text := s;

  for ormField in ormEntity.FieldList do
  begin
    q.ParamByName(ormField.DBColumnName).Value := GetPropValue(entity, ormField.PPropInfo);
  end;

  ShowMessage(s);

  q.ExecSQL;;
  q.Free;

end;


end.

