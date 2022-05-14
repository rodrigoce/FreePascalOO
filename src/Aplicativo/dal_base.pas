unit dal_base;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Dialogs, mini_orm, TypInfo, StrUtils, SQLDB, DateUtils, Variants, conexao_dm;

type

  { TDALBase }

  generic TDALBase<T: class> = class
    private
      FShowSQLAndParams: Boolean;
    public
      property ShowSQLAndParams: Boolean read FShowSQLAndParams write FShowSQLAndParams;
      // para chaves compostas pode ser passado VarArrayOf
      function FindByPK(Id: Variant): T;
      // pega próximo valor da sequence
      function GetNextSequence: Integer;
      procedure Insert(entity: T);
      procedure Update(entity: T);
      function CreateSQLQuery: TSQLQuery;
  end;

implementation

{ TDALBase }

function TDALBase.FindByPK(Id: Variant): T;
var
  ormEntity: TORMEntity;
  ormField: TORMField;
  entity: T;
  q: TSQLQuery;
  i, countPKFields: Integer;
  sql, strParams: string;
begin

  ormEntity := TORM.FindORMEntity(T.ClassName);
  countPKFields := ormEntity.CountPK;

  //
  // monta o select
  //

  sql := 'select ' + LineEnding;

  i := 0;
  for ormField in ormEntity.FieldList do
  begin
    sql := sql + '  ' + ormField.DBColumnName;
    sql := sql + IfThen(i < ormEntity.FieldList.Count -1, ', ', ' ') + LineEnding;
    Inc(i);
  end;
  sql := sql + 'from ' + ormEntity.DBTableName + LineEnding +
    'where';

  if (countPKFields = 0) then
    raise Exception.Create(ormEntity.DBTableName + ' não tem chave primária.');

  i := 1;
  for ormField in ormEntity.FieldList do
  begin
    if ormField.IsPK then
    begin
      sql := sql + '  ' + ormField.DBColumnName + ' = :' + ormField.DBColumnName;
      sql := sql + IfThen(i < countPKFields, LineEnding + '  and', '');
      Inc(i);
    end;
  end;

  //
  // alimenta os parâmetros
  //

  q := TSQLQuery.Create(nil);
  q.DataBase := ConexaoDm.Conexao;
  q.SQL.Text := sql;

  // implementar alimentar o parâmetros de chave composta como
  // em TDataSet.Locate
  strParams := '';
  for ormField in ormEntity.FieldList do
  begin
    if ormField.IsPK then
    begin
      q.ParamByName(ormField.DBColumnName).Value := Id;
      strParams := strParams + VarToStr(Id) + LineEnding;
    end;
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

  if ShowSQLAndParams then
    ShowMessage(sql + LineEnding + LineEnding + strParams);


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
  i: Integer;
  sql, strParams: string;
begin

  ormEntity := TORM.FindORMEntity(T.ClassName);

  //
  // gera o sql
  //

  sql := 'insert into ' + ormEntity.DBTableName + ' (' + LineEnding;

  i := 0;
  for ormField in ormEntity.FieldList do
  begin
    sql := sql + '  ' + ormField.DBColumnName;
    sql := sql + IfThen(i < ormEntity.FieldList.Count -1, ', ', ')') + LineEnding;
    Inc(i);
  end;
  sql := sql + 'values ( ' + LineEnding;

  i := 0;
  for ormField in ormEntity.FieldList do
  begin
    sql := sql + '  :' + ormField.DBColumnName;
    sql := sql + IfThen(i < ormEntity.FieldList.Count -1, ', ', ')') + LineEnding;
    Inc(i);
  end;

  //
  // alimentas os parâmetros
  //

  q := TSQLQuery.Create(nil);
  q.DataBase := ConexaoDm.Conexao;
  q.SQL.Text := sql;

  strParams := '';
  for ormField in ormEntity.FieldList do
  begin
    q.ParamByName(ormField.DBColumnName).Value := GetPropValue(entity, ormField.PPropInfo);
    strParams := strParams + VarToStr(GetPropValue(entity, ormField.PPropInfo)) + LineEnding;
  end;

  q.ExecSQL;;
  q.Free;

  if ShowSQLAndParams then
    ShowMessage(sql + LineEnding + strParams);

end;

procedure TDALBase.Update(entity: T);
var
  ormEntity: TORMEntity;
  ormField: TORMField;
  q: TSQLQuery;
  sql, strParams: string;
  i, countPKFields, countCommonFields: Integer;

begin

  ormEntity := TORM.FindORMEntity(T.ClassName);
  countPKFields := ormEntity.CountPK;
  countCommonFields := ormEntity.FieldList.Count - countPKFields;

  //
  // monta a string com o update
  //

  sql := 'update ' + ormEntity.DBTableName + ' set ' + LineEnding;
  strParams := '';

  i := 0;
  for ormField in ormEntity.FieldList do
  begin
    // apenas campos não PK entram no update
    if not ormField.IsPK then
    begin
      sql := sql + '  ' + ormField.DBColumnName + ' = :' + ormField.DBColumnName;
      sql := sql + IfThen(i < countCommonFields -1, ', ', '') + LineEnding;
      strParams := strParams + VarToStr(GetPropValue(entity, ormField.PPropInfo)) + LineEnding;
      Inc(i);
    end;
  end;

  sql := sql + 'where' + LineEnding;

  if (countPKFields = 0) then
    raise Exception.Create(ormEntity.DBTableName + ' não tem chave primária não pode ser atualizada.');

  i := 1;
  for ormField in ormEntity.FieldList do
  begin
    if ormField.IsPK then
    begin
      sql := sql + '  ' + ormField.DBColumnName + ' = :' + ormField.DBColumnName;
      sql := sql + IfThen(i < countPKFields, LineEnding + '  and', '');
      strParams := strParams + VarToStr(GetPropValue(entity, ormField.PPropInfo)) + LineEnding;
      Inc(i);
    end;
  end;

  //
  // alimenta os parâmetros da query
  //

  q := TSQLQuery.Create(nil);
  q.DataBase := ConexaoDm.Conexao;
  q.SQL.Text := sql;

  for ormField in ormEntity.FieldList do
  begin
    q.ParamByName(ormField.DBColumnName).Value := GetPropValue(entity, ormField.PPropInfo);
  end;

  q.ExecSQL;;
  q.Free;

  if ShowSQLAndParams then
    ShowMessage(sql + LineEnding + LineEnding + strParams);

end;

function TDALBase.CreateSQLQuery: TSQLQuery;
var
  q: TSQLQuery;
begin
  q := TSQLQuery.Create(nil);
  q.DataBase := ConexaoDm.Conexao;
  Result := q;
end;


end.

