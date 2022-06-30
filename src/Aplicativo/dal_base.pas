unit dal_base;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Dialogs, mini_orm, TypInfo, StrUtils, SQLDB,
  Variants, conexao_dm, LazUTF8, entity_base, StdCtrls, application_delegates;

type

  { TDALBase }

  generic TDALBase<T: TEntityBase> = class
    private
      class var FLogSQLCommandsDelegate: TOneStrParam;

      procedure WriteLog(TextLog: string);
    public
      class property LogSQLCommandsDelegate: TOneStrParam read FLogSQLCommandsDelegate write FLogSQLCommandsDelegate;
      // para chaves compostas pode ser passado VarArrayOf
      function FindByPK(Id: Variant): T;
      // pega próximo valor da sequence
      function GetNextSequence: Integer;
      procedure Insert(Entity: T; AutoCommit: Boolean = True);
      procedure Update(Entity: T; AutoCommit: Boolean = True);
      function CreateSQLQuery: TSQLQuery;
      function GetDatabaseDateTime: TDateTime;
      // verifica se um valor string já existe no banco de dados,
      // se IsInsert for true, o ID será ignorado e pode ser passado qualque valor
      function Exists(ClassPropName, Value: string; IsInsert: Boolean; Id: Variant): Boolean;
  end;

implementation

{ TDALBase }

procedure TDALBase.WriteLog(TextLog: string);
begin
  if LogSQLCommandsDelegate <> nil then
    LogSQLCommandsDelegate(TextLog);
end;

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
  entity.OldVersion := T.Create;

  for ormField in ormEntity.FieldList do
  begin
    if not q.FieldByName(ormField.DBColumnName).IsNull then
      if ormField.PPropInfo^.SetProc <> nil then
      begin
        SetPropValue(entity, ormField.PPropInfo, q.FieldByName(ormField.DBColumnName).Value);
        SetPropValue(entity.OldVersion, ormField.PPropInfo, q.FieldByName(ormField.DBColumnName).Value);
      end;
  end;

  q.Close;
  q.Free;

  WriteLog(sql + LineEnding + LineEnding + 'Parâmetros' + LineEnding + LineEnding + strParams );

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
  q.SQL.Text := 'select next value for ' + ormEntity.DBTableName + '_SEQUENCE from RDB$DATABASE';
  q.Open;

  Result := q.Fields[0].AsInteger;

  q.Close;
  q.Free;
end;

procedure TDALBase.Insert(Entity: T; AutoCommit: Boolean);
var
  ormEntity: TORMEntity;
  ormField: TORMField;
  q: TSQLQuery;
  i: Integer;
  sql, strParams: string;
begin
  Entity.ValidateStringMaxLength(True);
  // alimenta campos de rastreamento
  Entity.DataCriacao := GetDatabaseDateTime;
  Entity.IdUserCriacao := 0; //// PEAGR O ID DO CARA LOGADO


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
    sql := sql + IfThen(i < ormEntity.FieldList.Count -1, ', ' + LineEnding, ')') ;
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
    q.ParamByName(ormField.DBColumnName).Value := GetPropValue(Entity, ormField.PPropInfo);
    strParams := strParams + VarToStr(GetPropValue(Entity, ormField.PPropInfo)) + LineEnding;
  end;

  q.ExecSQL;
  if AutoCommit then
    TSQLTransaction(q.Transaction).Commit;
  q.Free;

  WriteLog(sql + LineEnding + LineEnding + 'Parâmetros' + LineEnding + LineEnding + strParams);

end;

procedure TDALBase.Update(Entity: T; AutoCommit: Boolean);
var
  ormEntity: TORMEntity;
  ormField: TORMField;
  q: TSQLQuery;
  sql, strParams: string;
  i, countPKFields: Integer;
  alteredFields: TStringList;
begin
  Entity.ValidateStringMaxLength(True);

  // alimenta campos de rastreamento
  Entity.DataAtualizacao := GetDatabaseDateTime;
  Entity.IdUserAtualizacao := 0; //// PEGAR O ID DO CARA LOGADO

  ormEntity := TORM.FindORMEntity(T.ClassName);
  countPKFields := ormEntity.CountPK;

  // marca os campos não PK alterados
  alteredFields := TStringList.Create;
  for ormField in ormEntity.FieldList do
  begin
    if not ormField.IsPK then
      if (not (VarCompareValue(GetPropValue(Entity, ormField.PPropInfo),
        GetPropValue(Entity.OldVersion, ormField.PPropInfo)) = vrEqual)) then
      begin
        alteredFields.Add(ormField.EntityPropName);
      end;
  end;

  //
  // monta a string com o update
  //

  sql := 'update ' + ormEntity.DBTableName + ' set ' + LineEnding;
  strParams := '';

  i := 0;
  for ormField in ormEntity.FieldList do
  begin
    // apenas campos não PK entram e alterados no update
    if (not ormField.IsPK) and (alteredFields.IndexOf(ormField.EntityPropName) > -1) then
    begin
      sql := sql + '  ' + ormField.DBColumnName + ' = :' + ormField.DBColumnName;
      sql := sql + IfThen(i < alteredFields.Count -1, ', ', '') + LineEnding;
      strParams := strParams + VarToStr(GetPropValue(Entity, ormField.PPropInfo)) + LineEnding;
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
      strParams := strParams + VarToStr(GetPropValue(Entity, ormField.PPropInfo)) + LineEnding;
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
    // apenas campos alterados e PK
    if (alteredFields.IndexOf(ormField.EntityPropName) > -1) or (ormField.IsPK) then
    begin
      q.ParamByName(ormField.DBColumnName).Value := GetPropValue(Entity, ormField.PPropInfo);
    end;
  end;

  q.ExecSQL;
  if AutoCommit then
    TSQLTransaction(q.Transaction).Commit;
  q.Free;

  WriteLog(sql + LineEnding + LineEnding + 'Parâmetros' + LineEnding + LineEnding + strParams);

end;

function TDALBase.CreateSQLQuery: TSQLQuery;
var
  q: TSQLQuery;
begin
  q := TSQLQuery.Create(nil);
  q.DataBase := ConexaoDm.Conexao;
  Result := q;
end;

function TDALBase.GetDatabaseDateTime: TDateTime;
var
  q: TSQLQuery;
begin
  q := CreateSQLQuery;
  q.SQL.Text := 'select cast(''NOW'' as timestamp) from rdb$database';
  q.Open;
  Result := q.Fields[0].AsDateTime;
  q.Free;
end;

function TDALBase.Exists(ClassPropName, Value: string; IsInsert: Boolean;
  Id: Variant): Boolean;
var
  ormEntity: TORMEntity;
  ormField: TORMField;
  q: TSQLQuery;
  i, countPKFields: Integer;
  sql, strParams: string;
begin

  ormEntity := TORM.FindORMEntity(T.ClassName);
  countPKFields := ormEntity.CountPK;

  //
  // monta o select
  //

  sql := 'select count(1) ' + LineEnding;
  sql := sql + 'from ' + ormEntity.DBTableName + LineEnding +
    'where';

  if (countPKFields = 0) then
    raise Exception.Create(ormEntity.DBTableName + ' não tem chave primária.');

  // se for update precisa comparar com registros diferentes dele mesmo
  i := -1;
  if not IsInsert then
  begin
    i := 1;
    sql := sql + '(';
    for ormField in ormEntity.FieldList do
    begin
      if ormField.IsPK then
      begin

        sql := sql + '  ' + ormField.DBColumnName + ' <> :' + ormField.DBColumnName;
        sql := sql + IfThen(i < countPKFields, LineEnding + '  and', '');
        Inc(i);
      end;
    end;
    sql := sql + ')';
  end;

  sql := sql + IfThen(i = -1, '  ', '  and ') + ormEntity.GetDBColumnNameOf(ClassPropName) + ' = :' + ClassPropName;

  //
  // alimenta os parâmetros
  //

  q := TSQLQuery.Create(nil);
  q.DataBase := ConexaoDm.Conexao;
  q.SQL.Text := sql;

  // se for update precisa comparar com registros diferentes dele mesmo
  if not IsInsert then
  begin
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
  end;

  q.ParamByName(ClassPropName).Value := Value;
  strParams := strParams + Value + LineEnding;

  q.Open;

  Result := q.Fields[0].Value > 0;

  q.Close;
  q.Free;

  WriteLog(sql + LineEnding + LineEnding + 'Parâmetros' + LineEnding + LineEnding + strParams );

end;

end.

