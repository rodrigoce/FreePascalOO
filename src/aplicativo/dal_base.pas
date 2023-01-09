unit dal_base;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Dialogs,  TypInfo, StrUtils, SQLDB, DB, Contnrs, Variants,
  LazUTF8, mini_orm, entity_base, application_delegates, db_context,
  application_session, application_types;

type

  { TDALBase }

  generic TDALBase<T: TEntityBase> = class
    private
      FDbContext: TDbContext;
      class var FLogSQLCommandsDelegate: TOneStrParam;
      procedure DoUpdateOldValues(Entity: T; ORMEntity: TORMEntity);
      procedure DoUpdate(Entity: T; UpdatedFields: TStringList);
      procedure DoLogUpdate(Entity: T; UpdatedFields: TStringList);
      procedure DoInsert(Entity: T);
      procedure DoLogInsert(Entity: T);
      function GetComparableValue(Value: Variant; ormField: TORMField): Variant;
      procedure GenerateSelect(var ORMEntity: TORMEntity; var sql: string);
      function CopyFromDataSetToEntity(DataSet: TSQLQuery; ORMEntity: TORMEntity): T;
    protected
      // passar o filtro como triades: VarArraOf(['NomeProp','=','rodrigo', ...])
      // não consegui fazer com generics dentro de uma classe génerica, por isso usei TFPObjectList
      function FindByFilterRaw(Params: Variant): TFPObjectList;
    public
      constructor Create(DbContext: TDbContext);
      //
      function FindByPK(Id: Integer): T;
      // pega próximo valor da sequence
      function GetNextSequence: Integer;
      //
      procedure Insert(Entity: T);
      procedure Update(Entity: T);
      // verifica se um valor string já existe no banco de dados,
      // se IsInsert for true, o ID será ignorado e pode ser passado qualque valor
      function Exists(EntityPropName, Value: Variant; IsInsert: Boolean; Id: Variant): Boolean; overload;
      function Exists(EntityPropName, Value: Variant): Boolean; overload;
      //
      class property LogSQLCommandsDelegate: TOneStrParam read FLogSQLCommandsDelegate write FLogSQLCommandsDelegate;
      property DbContext: TDbContext read FDbContext;
  end;

implementation

{ TDALBase }

procedure TDALBase.DoLogInsert(Entity: T);
var
  ormEntity: TORMEntity;
  q: TSQLQuery;
  sql: string;
begin
  q := DbContext.CreateSQLQuery;
  ormEntity := TORM.FindORMEntity(T.ClassName);

  sql := 'insert into ' + ormEntity.DBTableName + '_LOG (' + LineEnding;
  sql := sql + '  DATA_HORA, OPERACAO, ID_USUARIO, ID_PK, NOME_COLUNA)' + LineEnding;
  sql := sql + '  values (CURRENT_TIMESTAMP, ''I'', :ID_USUARIO, :ID_PK, ''*'')';

  q.SQL.Text := sql;

  if TApplicationSession.LogedUser = nil then
    q.ParamByName('ID_USUARIO').Value := Null
  else
    q.ParamByName('ID_USUARIO').Value := TApplicationSession.LogedUser.Id;

  q.ParamByName('ID_PK').Value := Entity.Id;
  q.ExecSQL;

  q.Free;

  DoUpdateOldValues(Entity, ormEntity);
end;

function TDALBase.GetComparableValue(Value: Variant; ormField: TORMField
  ): Variant;
begin
  if ormField.ORMType in [ormTypeDecimal] then
    Result := VarToStr(Value)
  else
    Result := Value;
end;

procedure TDALBase.GenerateSelect(var ORMEntity: TORMEntity; var sql: string);
var
  i: Integer;
  ormField: TORMField;
begin
  ORMEntity := TORM.FindORMEntity(T.ClassName);

  sql := 'select ' + LineEnding;

  i := 0;
  for ormField in ORMEntity.FieldList do
  begin
    sql := sql + '  ' + ormField.DBColumnName;
    sql := sql + IfThen(i < ORMEntity.FieldList.Count -1, ', ', ' ') + LineEnding;
    Inc(i);
  end;
  sql := sql + 'from ' + ormEntity.DBTableName + LineEnding;
end;

function TDALBase.CopyFromDataSetToEntity(DataSet: TSQLQuery;
  ORMEntity: TORMEntity): T;
var
  ormField: TORMField;
  entity: T;
begin
  entity := T.Create;
  entity.OldVersion := T.Create;

  for ormField in ORMEntity.FieldList do
  begin
    if not DataSet.FieldByName(ormField.DBColumnName).IsNull then
      if ormField.PPropInfo^.SetProc <> nil then
      begin
        SetPropValue(entity, ormField.PPropInfo, DataSet.FieldByName(ormField.DBColumnName).Value);
        SetPropValue(entity.OldVersion, ormField.PPropInfo, DataSet.FieldByName(ormField.DBColumnName).Value);
      end;
  end;
  Result := entity;
end;

procedure TDALBase.DoUpdateOldValues(Entity: T; ORMEntity: TORMEntity);
var
  rollbackObj: TRollbackOjb;
begin
  rollbackObj := TRollbackOjb.Create;
  rollbackObj.InstanceEntityBase := Entity;

  if Entity.OldVersion = nil then
  begin
    Entity.OldVersion := T.Create;
    rollbackObj.CopyOfOldVersion := nil;
  end
  else
  begin
    // copia os valores de old para a versão de rollback do obj
    rollbackObj.CopyOfOldVersion := T.Create;
    TORMEntity.CloneTo(Entity.OldVersion, rollbackObj.CopyOfOldVersion, ORMEntity);
  end;

  // registra o ojeto de rollback de objetos
  DbContext.AddRollBackObj(rollbackObj);

  // copia os novos valores para Old
  TORMEntity.CloneTo(Entity, Entity.OldVersion, ORMEntity);
end;

procedure TDALBase.DoUpdate(Entity: T; UpdatedFields: TStringList);
var
  ormEntity: TORMEntity;
  ormField: TORMField;
  q: TSQLQuery;
  sql, DBNroRevisaoColumnName: string;
  i, countPKFields, count: Integer;
begin
  Entity.ValidateStringMaxLength;

  ormEntity := TORM.FindORMEntity(T.ClassName);
  countPKFields := ormEntity.CountPK;

  Entity.NroRevisao := Entity.NroRevisao + 1;

  // marca os campos não PK alterados
  for ormField in ormEntity.FieldList do
  begin
    if not (ormField.ORMType = ormTypeInt32PK) then
    begin
      if (not (VarCompareValue(GetComparableValue(GetPropValue(Entity, ormField.PPropInfo), ormField),
        GetComparableValue(GetPropValue(Entity.OldVersion, ormField.PPropInfo), ormField)) = vrEqual)) then
      begin
        UpdatedFields.AddObject(ormField.EntityPropName, ormField);
      end;
    end;
  end;

  //
  // monta a string com o update
  //

  sql := 'update ' + ormEntity.DBTableName + ' set ' + LineEnding;

  i := 0;
  for ormField in ormEntity.FieldList do
  begin
    // apenas campos não PK e alterados entram no update
    if (not (ormField.ORMType = ormTypeInt32PK)) and (UpdatedFields.IndexOf(ormField.EntityPropName) > -1) then
    begin
      sql := sql + '  ' + ormField.DBColumnName + ' = :' + ormField.DBColumnName;
      sql := sql + IfThen(i < UpdatedFields.Count -1, ', ', '') + LineEnding;
      Inc(i);
    end;
  end;

  sql := sql + 'where' + LineEnding;

  if (countPKFields = 0) then
    raise Exception.Create(ormEntity.DBTableName + ' não tem chave primária não pode ser atualizada.');

  // coloca a PK no update
  for ormField in ormEntity.FieldList do
  begin
    if ormField.ORMType = ormTypeInt32PK then
    begin
      sql := sql + '  ' + ormField.DBColumnName + ' = :' + ormField.DBColumnName;
      Break;
    end;
  end;

  // valida se o usuário tem a última revisão
  DBNroRevisaoColumnName := ormEntity.GetDBColumnNameOf('NroRevisao');
  sql := sql + '  and ' + DBNroRevisaoColumnName + ' = :' + DBNroRevisaoColumnName + '_OLD';

  //
  // alimenta os parâmetros da query
  //

  q := DbContext.CreateSQLQuery;
  q.SQL.Text := sql;

  for ormField in ormEntity.FieldList do
  begin
    // apenas campos alterados e PK
    if (UpdatedFields.IndexOf(ormField.EntityPropName) > -1) or (ormField.ORMType = ormTypeInt32PK) then
    begin
      q.ParamByName(ormField.DBColumnName).Value :=
        ormField.ProcessedParamValue(GetPropValue(Entity, ormField.PPropInfo));

      if ormField.ORMType in [ormTypeDecimal] then
        q.ParamByName(ormField.DBColumnName).DataType := ftFMTBcd; // para inserir mais que 4 digitos decimais tem que fazer assim
    end;
  end;

  // valida se o usuário tem a última revisão
  q.ParamByName(DBNroRevisaoColumnName + '_OLD').Value := GetPropValue(Entity.OldVersion, 'NroRevisao');

  q.ExecSQL;
  count := q.RowsAffected;
  q.Free;

  if count = 0 then
    raise Exception.Create('O registro a ser alterado não foi encontrado ou essa não é mais a última versão.');

end;

procedure TDALBase.DoLogUpdate(Entity: T; UpdatedFields: TStringList);
var
  ormEntity: TORMEntity;
  q: TSQLQuery;
  sql: string;
  i: Integer;
  timeStamp: TDateTime;
begin
  timeStamp := DbContext.GetDatabaseDateTime;

  q := DbContext.CreateSQLQuery;
  ormEntity := TORM.FindORMEntity(T.ClassName);

  sql := 'insert into ' + ormEntity.DBTableName + '_LOG (' + LineEnding;
  sql := sql + '  DATA_HORA, OPERACAO, ID_USUARIO, ID_PK, NOME_COLUNA, VALOR_ANTERIOR, VALOR_NOVO)' + LineEnding;
  sql := sql + '  values (:DATA_HORA, ''U'', :ID_USUARIO, :ID_PK, :NOME_COLUNA, :VALOR_ANTERIOR, :VALOR_NOVO)';

  q.SQL.Text := sql;

  for i := 0 to Pred(UpdatedFields.Count) do
  begin
    q.ParamByName('DATA_HORA').Value := timeStamp;

    if TApplicationSession.LogedUser = nil then
      q.ParamByName('ID_USUARIO').Value := Null
    else
      q.ParamByName('ID_USUARIO').Value := TApplicationSession.LogedUser.Id;

    q.ParamByName('ID_PK').Value := Entity.Id;
    q.ParamByName('NOME_COLUNA').Value :=  (UpdatedFields.Objects[i] as TORMField).DBColumnName;
    q.ParamByName('VALOR_ANTERIOR').Value := VarToStrSQLParam((UpdatedFields.Objects[i] as TORMField),
      GetPropValue(Entity.OldVersion, UpdatedFields[i]));
    q.ParamByName('VALOR_NOVO').Value := VarToStrSQLParam((UpdatedFields.Objects[i] as TORMField),
      GetPropValue(Entity, UpdatedFields[i]));
    q.ExecSQL;
  end;

  q.Free;

  DoUpdateOldValues(Entity, ormEntity);
end;

procedure TDALBase.DoInsert(Entity: T);
var
  ormEntity: TORMEntity;
  ormField: TORMField;
  q: TSQLQuery;
  i: Integer;
  sql: string;
begin
  Entity.ValidateStringMaxLength;

  ormEntity := TORM.FindORMEntity(T.ClassName);

  Entity.NroRevisao := 1;

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

  q := DbContext.CreateSQLQuery;
  q.SQL.Text := sql;

  for ormField in ormEntity.FieldList do
  begin
    q.ParamByName(ormField.DBColumnName).Value :=
      ormField.ProcessedParamValue(GetPropValue(Entity, ormField.PPropInfo));

    if ormField.ORMType in [ormTypeDecimal] then
      q.ParamByName(ormField.DBColumnName).DataType := ftFMTBcd; // para inserir mais que 4 digitos decimais tem que fazer assim
  end;

  q.ExecSQL;
  q.Free;
end;

function TDALBase.FindByPK(Id: Integer): T;
var
  ormEntity: TORMEntity;
  ormField: TORMField;
  q: TSQLQuery;
  i, countPKFields: Integer;
  sql: string;
begin

  sql := '';
  // monta o select com os campos
  GenerateSelect(ormEntity, sql);
  countPKFields := ormEntity.CountPK;

  // monta o where
  sql := sql + 'where' + LineEnding;

  if (countPKFields = 0) then
    raise Exception.Create(ormEntity.DBTableName + ' não tem chave primária.');

  for ormField in ormEntity.FieldList do
  begin
    if ormField.ORMType = ormTypeInt32PK then
    begin
      sql := sql + '  ' + ormField.DBColumnName + ' = :' + ormField.DBColumnName;
      Break;
    end;
  end;

  // cria o dataset e alimenta os parâmetros
  q := DbContext.CreateSQLQuery;
  q.SQL.Text := sql;

  for ormField in ormEntity.FieldList do
  begin
    if ormField.ORMType = ormTypeInt32PK then
    begin
      q.ParamByName(ormField.DBColumnName).Value := Id;
      Break;
    end;
  end;

  // copia do dataset para o objeto entity
  q.Open;

  if q.EOF then
    Result := nil
  else
    Result := CopyFromDataSetToEntity(q, ormEntity);

  q.Close;
  q.Free;
end;

function TDALBase.FindByFilterRaw(Params: Variant): TFPObjectList;
var
  ormEntity: TORMEntity;
  q: TSQLQuery;
  i, low, high: Integer;
  sql: string;
  objeto: T;
begin
  if not VarIsArray(Params) then
    raise Exception.Create('O parâmetro deve ser um VarArray');

  low := VarArrayLowBound(Params, 1);
  high := VarArrayHighBound(Params, 1);

  if (((high - low) + 1) mod 3) <> 0 then
    raise Exception.Create('O número de parâmetros deve ser 0 ou múltiplo de 3.');

  sql := '';
  // monta o select com os campos
  GenerateSelect(ormEntity, sql);

  // monta o where
  if low <> high then
  begin
    sql := sql + 'where' + LineEnding;

    for i := low to (((high - low) + 1) div 3) -1 do
    begin
      sql := sql + '  ' + ormEntity.GetDBColumnNameOf(Params[i * 3]) + ' ' +
        Params[(i * 3) + 1] + ' :' + ormEntity.GetDBColumnNameOf(Params[i * 3]);
    end;
  end;

  // cria o dataset e alimenta os parâmetros
  q := DbContext.CreateSQLQuery;
  q.SQL.Text := sql;

  if low <> high then
    for i := low to (((high - low) + 1) div 3) -1 do
      q.ParamByName(ormEntity.GetDBColumnNameOf(Params[i * 3])).Value := Params[(i * 3) + 2];

  // copia do dataset para o objeto entity
  q.Open;

  Result := TFPObjectList.Create(False);
  if not q.EOF then
  begin
    while not q.EOF do
    begin
      objeto := CopyFromDataSetToEntity(q, ormEntity);
      Result.Add(objeto);
      q.Next;
    end;
  end;

  q.Close;
  q.Free;
end;

constructor TDALBase.Create(DbContext: TDbContext);
begin
  FDbContext := DbContext;
end;

function TDALBase.GetNextSequence: Integer;
var
  ormEntity: TORMEntity;
  q: TSQLQuery;
begin
  ormEntity := TORM.FindORMEntity(T.ClassName);

  q := DbContext.CreateSQLQuery;
  q.SQL.Text := 'select next value for ' + ormEntity.DBTableName + '_SEQUENCE from RDB$DATABASE';
  q.Open;

  Result := q.Fields[0].AsInteger;

  q.Close;
  q.Free;
end;

procedure TDALBase.Insert(Entity: T);
begin
  if not DbContext.IsInTransaction then
    raise Exception.Create('O DbContext não estava com uma transação aberta para realizar inserts.');

  DoInsert(Entity);
  DoLogInsert(Entity);
end;

procedure TDALBase.Update(Entity: T);
var
  updatedFields: TStringList;
begin
  if not DbContext.IsInTransaction then
    raise Exception.Create('O DbContext não estava com uma transação aberta para realizar updates.');

  updatedFields := TStringList.Create;

  DoUpdate(Entity, updatedFields);
  DoLogUpdate(Entity, updatedFields);

  updatedFields.Free;
end;

function TDALBase.Exists(EntityPropName, Value: Variant; IsInsert: Boolean;
  Id: Variant): Boolean;
var
  ormEntity: TORMEntity;
  ormField: TORMField;
  q: TSQLQuery;
  countPKFields: Integer;
  sql: string;
begin

  ormEntity := TORM.FindORMEntity(T.ClassName);
  countPKFields := ormEntity.CountPK;

  //
  // monta o select
  //

  sql := 'select count(1) ' + LineEnding;
  sql := sql + 'from ' + ormEntity.DBTableName + LineEnding +
    'where ';

  if (countPKFields = 0) then
    raise Exception.Create(ormEntity.DBTableName + ' não tem chave primária.');

  // se for update precisa comparar com registros diferentes dele mesmo

  if not IsInsert then
  begin
    for ormField in ormEntity.FieldList do
    begin
      if ormField.ORMType = ormTypeInt32PK then
      begin
        sql := sql +  ormField.DBColumnName + ' <> :' + ormField.DBColumnName;
        Break;
      end;
    end;
    sql := sql + ' and ';
  end;

  sql := sql + ormEntity.GetDBColumnNameOf(EntityPropName) + ' = :' + EntityPropName;

  //
  // alimenta os parâmetros
  //

  q := DbContext.CreateSQLQuery;
  q.SQL.Text := sql;

  // se for update precisa comparar com registros diferentes dele mesmo
  if not IsInsert then
  begin
    for ormField in ormEntity.FieldList do
    begin
      if ormField.ORMType = ormTypeInt32PK then
      begin
        q.ParamByName(ormField.DBColumnName).Value := Id;
        Break;
      end;
    end;
  end;

  q.ParamByName(EntityPropName).Value := Value;

  q.Open;

  Result := q.Fields[0].Value > 0;

  q.Close;
  q.Free;
end;

function TDALBase.Exists(EntityPropName, Value: Variant): Boolean;
begin
  Result := Exists(EntityPropName, Value, True, '');
end;

end.

