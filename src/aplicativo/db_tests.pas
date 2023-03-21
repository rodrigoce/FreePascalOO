unit db_tests;

{$mode ObjFPC}{$H+}

interface

uses
  Dialogs, SysUtils, Math, SQLDB, StrUtils,
  test_base, test_dal, test_entity, db_context, mini_orm, dal_base, entity_base;

{ TDBTests }

type

  TDBTests = class(TTestsBase)
  private
    FTestDal: TTestDal;
    function must_get_sequence: TTestResult;
    function must_get_the_right_mapping: TTestResult;
    function must_raise_EDBContextTransactionIsNotOpen_for_insert: TTestResult;
    function must_perform_insert: TTestResult;
    function must_update_null_fields_prop: TTestResult;
    function must_retrieve_insert: TTestResult;
    function must_retrieve_equals_inserted: TTestResult;
    function must_be_null_retrivied_specific_fields: TTestResult;
    function must_be_1_first_revision: TTestResult;
    function must_insert_log_insert: TTestResult;
    function must_raise_EDBContextTransactionIsNotOpen_for_update: TTestResult;
    function must_perform_update: TTestResult;
    function must_null_fields_be_zero: TTestResult;
    function must_retrieve_equals_updated: TTestResult;
    function must_be_revision_2: TTestResult;
    function must_insert_log_update: TTestResult;
    function must_update_fiels_to_null: TTestResult;
    function must_null_fields_be_three: TTestResult;
    function must_retrieve_updated_fields_as_null: TTestResult;
    function must_log_updated_fiels_as_null: TTestResult;
    function must_raise_EMaxLengthExceded: TTestResult;
    function must_rollback_objects_of_inserts: TTestResult;
    function must_rollback_objects_of_updates: TTestResult;
  public
    constructor Create(InitialTestNumber: Integer);
    destructor Destroy; override;
    procedure RegisterTests; override;
  end;

implementation

{ TDBTests }

function TDBTests.must_get_sequence: TTestResult;
var
  testResult: TTestResult;
  nextSeq: Integer;
begin
  nextSeq := FTestDal.GetNextSequence;
  IsGreaterThan(nextSeq, 0, testResult);
  Result := testResult;
end;

function TDBTests.must_get_the_right_mapping: TTestResult;
var
  testResult: TTestResult;
  ormEntity: TORMEntity;
begin
  ormEntity := TORM.FindORMEntity(TTestEntity.ClassName);
  IsEquals(TTestEntity.ClassName, ormEntity.EntityClassName, testResult);
  Result := testResult;
end;

function TDBTests.must_raise_EDBContextTransactionIsNotOpen_for_insert: TTestResult;
var
  temp: TTestEntity;
  testResult: TTestResult;
begin
  if DontRunTestsWithExceptionsBased then
  begin
    testResult.Pass := tpsNotExecuted;
    Result := testResult;
    Exit;
  end;

  temp := TTestEntity.Create;

  try
    FTestDal.Insert(temp);
    // se executar sem exception quer dizer que falhou
    testResult.Pass := tpsFail;
  except
    on Ex: EDBContextTransactionIsNotOpen do
    begin
      testResult.Pass := tpsPass;
      testResult.Message := ex.ClassName + ' - ' + ex.Message;
    end;

    on Ex: Exception do
    begin
      testResult.Pass := tpsFail;
      testResult.Message := ex.Message;
    end;
  end;

  temp.Free;
  Result := testResult;
end;

function TDBTests.must_perform_insert: TTestResult;
var
  insertTest: TTestEntity;
  testResult: TTestResult;
begin
  Randomize;

  insertTest := TTestEntity.Create;
  ObjectsBag.Add('insertTest', insertTest);

  insertTest.Id := FTestDal.GetNextSequence;
  insertTest.Situacao := 'A';
  insertTest.Int32 := Random(MaxInt);
  insertTest.Int32NullIfZero := 0;
  insertTest.DateTime := Now;
  insertTest.DateTimeNullIfZero := 0;
  insertTest.Str := 'STR';
  insertTest.StrNullIfEmpty := '';
  insertTest.Decimal := RoundTo(StrToFloat(IntToStr(Random(MaxInt)) + ',' + IntToStr(Random(MaxInt))), -7);
  try
    FTestDal.DbContext.BeginTransaction;
    FTestDal.Insert(insertTest);
    FTestDal.DbContext.CommitTransaction;
    testResult.Pass := tpsPass;
  except on Ex: Exception do
    begin
      FTestDal.DbContext.RollbackTransaction;
      StopTests := True;
      testResult.Pass := tpsFail;
      testResult.Message := ex.Message;
    end;
  end;
  Result := testResult;
end;

function TDBTests.must_update_null_fields_prop: TTestResult;
var
  insertTest: TTestEntity;
  testResult: TTestResult;
begin
  insertTest := (ObjectsBag.Find('insertTest') as TTestEntity);

  if
    (insertTest.NullFields.IndexOf('Int32NullIfZero') >  -1) and
    (insertTest.NullFields.IndexOf('DateTimeNullIfZero') >  -1) and
    (insertTest.NullFields.IndexOf('StrNullIfEmpty') >  -1)
  then
    testResult.Pass := tpsPass
  else
    testResult.Pass := tpsFail;

  Result := testResult;
end;

function TDBTests.must_retrieve_insert: TTestResult;
var
  insertTest: TTestEntity;
  retrieveTest: TTestEntity;
  testResult: TTestResult;
begin
  insertTest := (ObjectsBag.Find('insertTest') as TTestEntity);
  retrieveTest := FTestDal.FindByPK(insertTest.Id);
  ObjectsBag.Add('retrieveTest', retrieveTest);
  if retrieveTest = nil then
  begin
    StopTests := True;
    testResult.Pass := tpsFail;
  end
  else
  begin
    testResult.Pass := tpsPass;
  end;
  Result := testResult;
end;

function TDBTests.must_retrieve_equals_inserted: TTestResult;
var
  insertTest: TTestEntity;
  retrieveTest: TTestEntity;
  testResult: TTestResult;
begin
  insertTest := (ObjectsBag.Find('insertTest') as TTestEntity);
  retrieveTest := (ObjectsBag.Find('retrieveTest') as TTestEntity);

  if
    (insertTest.Id = retrieveTest.Id) and
    (insertTest.Situacao = retrieveTest.Situacao) and
    (insertTest.Int32 = retrieveTest.Int32) and
    (insertTest.Int32NullIfZero = retrieveTest.Int32NullIfZero) and
    (insertTest.DateTime = retrieveTest.DateTime) and
    (insertTest.DateTimeNullIfZero = retrieveTest.DateTimeNullIfZero) and
    (insertTest.Str = retrieveTest.Str) and
    (insertTest.StrNullIfEmpty = retrieveTest.StrNullIfEmpty) and
    (SameValue(insertTest.Decimal, retrieveTest.Decimal))
  then
    testResult.Pass := tpsPass
  else
    testResult.Pass := tpsFail;

  Result := testResult;
end;

function TDBTests.must_be_null_retrivied_specific_fields: TTestResult;
var
  retrieveTest: TTestEntity;
  testResult: TTestResult;
begin
  retrieveTest := (ObjectsBag.Find('retrieveTest') as TTestEntity);

  if
    (retrieveTest.NullFields.IndexOf('Int32NullIfZero') >  -1) and
    (retrieveTest.NullFields.IndexOf('DateTimeNullIfZero') >  -1) and
    (retrieveTest.NullFields.IndexOf('StrNullIfEmpty') >  -1)
  then
    testResult.Pass := tpsPass
  else
    testResult.Pass := tpsFail;

  Result := testResult;
end;

function TDBTests.must_be_1_first_revision: TTestResult;
var
  insertTest: TTestEntity;
  testResult: TTestResult;
begin
  insertTest := (ObjectsBag.Find('insertTest') as TTestEntity);

  IsEquals(insertTest.NroRevisao, 1, testResult);
  Result := testResult;
end;

function TDBTests.must_insert_log_insert: TTestResult;
var
  insertTest: TTestEntity;
  testResult: TTestResult;
  q: TSQLQuery;
begin
  insertTest := (ObjectsBag.Find('insertTest') as TTestEntity);

  q := gAppDbContext.CreateSQLQuery;
  q.SQL.Text := 'select count(1) from test_log where id_pk = :id_pk and operacao = ''I''';
  q.Params[0].Value := insertTest.Id;
  q.Open;

  IsEquals(q.Fields[0].AsInteger, 1, testResult);
  q.Free;

  Result := testResult;
end;

function TDBTests.must_raise_EDBContextTransactionIsNotOpen_for_update: TTestResult;
var
  retrieveTest: TTestEntity;
  testResult: TTestResult;
begin
  if DontRunTestsWithExceptionsBased then
  begin
    testResult.Pass := tpsNotExecuted;
    Result := testResult;
    Exit;
  end;

  retrieveTest := (ObjectsBag.Find('retrieveTest') as TTestEntity);

  try
    FTestDal.Update(retrieveTest);
    // se executar sem exception quer dizer que falhou
    testResult.Pass := tpsFail;
  except
    on Ex: EDBContextTransactionIsNotOpen do
    begin
      testResult.Pass := tpsPass;
      testResult.Message := ex.ClassName + ' - ' + ex.Message;
    end;

    on Ex: Exception do
    begin
      testResult.Pass := tpsFail;
      testResult.Message := ex.Message;
    end;
  end;

  Result := testResult;
end;

function TDBTests.must_perform_update: TTestResult;
var
  testResult: TTestResult;
  doInsert, doUpdate: TTestEntity;
begin
  // aqui eu já confio na inserção pois ela já está testada
  doInsert := TTestEntity.Create;
  ObjectsBag.Add('doInsert', doInsert);

  doInsert.Id := FTestDal.GetNextSequence;
  doInsert.Situacao := 'A';
  doInsert.Int32 := 1;
  doInsert.Int32NullIfZero := 0;
  doInsert.DateTime := EncodeDate(2023, 02, 23) + EncodeTime(13, 13, 13, 0);
  doInsert.DateTimeNullIfZero := 0;
  doInsert.Str := 'STR';
  doInsert.StrNullIfEmpty := '';
  doInsert.Decimal := 1.1111111;
  FTestDal.DbContext.BeginTransaction;
  FTestDal.Insert(doInsert);
  FTestDal.DbContext.CommitTransaction;

  // aqui eu já confio na recuperação pois ela já esta testada
  doUpdate := FTestDal.FindByPK(doInsert.Id);
  ObjectsBag.Add('doUpdate', doUpdate);

  doUpdate.Situacao := 'E';
  doUpdate.Int32 := 2;
  doUpdate.Int32NullIfZero := 1;
  doUpdate.DateTime := EncodeDate(2024, 02, 23) + EncodeTime(14, 14, 14, 0);
  doUpdate.DateTimeNullIfZero := EncodeDate(2024, 02, 23) + EncodeTime(14, 14, 14, 0);
  doUpdate.Str := 'ABC';
  doUpdate.StrNullIfEmpty := 'NOT NULL NOW';
  doUpdate.Decimal := 2.2222222;

  try
    FTestDal.DbContext.BeginTransaction;
    FTestDal.Update(doUpdate);
    FTestDal.DbContext.CommitTransaction;
    testResult.Pass := tpsPass;
  except on Ex: Exception do
    begin
      FTestDal.DbContext.RollbackTransaction;
      StopTests := True;
      testResult.Pass := tpsFail;
      testResult.Message := ex.Message;
    end;
  end;

  Result := testResult;
end;

function TDBTests.must_null_fields_be_zero: TTestResult;
var
  doUpdate: TTestEntity;
  testResult: TTestResult;
begin
  doUpdate := (ObjectsBag.Find('doUpdate') as TTestEntity);

  if doUpdate.NullFields.Count = 0 then
    testResult.Pass := tpsPass
  else
    testResult.Pass := tpsFail;

  Result := testResult;
end;

function TDBTests.must_retrieve_equals_updated: TTestResult;
var
  testResult: TTestResult;
  doUpdate, afterUpdate: TTestEntity;
begin
  doUpdate := (ObjectsBag.Find('doUpdate') as TTestEntity);

  afterUpdate := FTestDal.FindByPK(doUpdate.Id);
  ObjectsBag.Add('afterUpdate', afterUpdate);

  if
    (doUpdate.Id = afterUpdate.Id) and
    (doUpdate.Situacao = afterUpdate.Situacao) and
    (doUpdate.Int32 = afterUpdate.Int32) and
    (doUpdate.Int32NullIfZero = afterUpdate.Int32NullIfZero) and
    (doUpdate.DateTime = afterUpdate.DateTime) and
    (doUpdate.DateTimeNullIfZero = afterUpdate.DateTimeNullIfZero) and
    (doUpdate.Str = afterUpdate.Str) and
    (doUpdate.StrNullIfEmpty = afterUpdate.StrNullIfEmpty) and
    (SameValue(doUpdate.Decimal, afterUpdate.Decimal))
  then
    testResult.Pass := tpsPass
  else
    testResult.Pass := tpsFail;

  Result := testResult;
end;

function TDBTests.must_be_revision_2: TTestResult;
var
  testResult: TTestResult;
  afterUpdate: TTestEntity;
begin
  afterUpdate := (ObjectsBag.Find('afterUpdate') as TTestEntity);
  IsEquals(afterUpdate.NroRevisao, 2, testResult);
  Result := testResult;
end;

function TDBTests.must_insert_log_update: TTestResult;
var
  doInsert, afterUpdate: TTestEntity;
  testResult: TTestResult;
  q: TSQLQuery;

  procedure TestField(NomeColuna: string; OldValue, NewValue: Variant; var aTestResult: TTestResult);
  var
    s: string;
  begin
    q := gAppDbContext.CreateSQLQuery;
    s := 'select count(1) from test_log where id_pk = :id_pk and operacao = ''U'' ' +
                'and nome_coluna = :nome_coluna';

    if OldValue = Null then
      s := s + ' and valor_anterior is null'
    else
      s := s + ' and valor_anterior = :valor_anterior ';

    if NewValue = Null then
      s := s + ' and valor_novo is null'
    else
      s := s + ' and valor_novo = :valor_novo';

    q.SQL.Text := s;
    q.ParamByName('id_pk').Value := doInsert.Id;

    q.ParamByName('nome_coluna').Value := NomeColuna;

    if OldValue <> Null then
      q.ParamByName('valor_anterior').Value := OldValue;

    if NewValue <> Null then
      q.ParamByName('valor_novo').Value := NewValue;

    q.Open;

    IsEquals(q.Fields[0].AsInteger, 1, aTestResult);
    q.Free;
  end;

begin
  doInsert := (ObjectsBag.Find('doInsert') as TTestEntity);
  afterUpdate := (ObjectsBag.Find('afterUpdate') as TTestEntity);

  TestField('SITUACAO', doInsert.Situacao, afterUpdate.Situacao, testResult);
  if testResult.Pass = tpsPass then
    TestField('NRO_REVISAO', IntToStr(doInsert.NroRevisao), IntToStr(afterUpdate.NroRevisao), testResult);
  if testResult.Pass = tpsPass then
    TestField('INT_32', IntToStr(doInsert.Int32), IntToStr(afterUpdate.Int32), testResult);
  if testResult.Pass = tpsPass then
    TestField('INT_32_NULL_IF_ZERO', Null, IntToStr(afterUpdate.Int32NullIfZero), testResult);
  if testResult.Pass = tpsPass then
    TestField('DATE_TIME', FormatDateTime('DD/MM/YYYY hh:nn:ss', doInsert.DateTime), FormatDateTime('DD/MM/YYYY hh:nn:ss', afterUpdate.DateTime), testResult);
  if testResult.Pass = tpsPass then
    TestField('DATE_TIME_NULL_IF_ZERO', Null, FormatDateTime('DD/MM/YYYY hh:nn:ss', afterUpdate.DateTimeNullIfZero), testResult);
  if testResult.Pass = tpsPass then
    TestField('STR', doInsert.Str, afterUpdate.Str, testResult);
  if testResult.Pass = tpsPass then
    TestField('STR_NULL_IF_EMPTY', Null, afterUpdate.StrNullIfEmpty, testResult);
  if testResult.Pass = tpsPass then
    TestField('NUMERO_DECIMAL', FloatToStr(doInsert.Decimal), FloatToStr(afterUpdate.Decimal), testResult);
  Result := testResult;
end;

function TDBTests.must_update_fiels_to_null: TTestResult;
var
  afterUpdate, onUpdateToNull: TTestEntity;
  testResult: TTestResult;
begin
  afterUpdate := (ObjectsBag.Find('afterUpdate') as TTestEntity);
  onUpdateToNull := FTestDal.FindByPK(afterUpdate.Id);
  ObjectsBag.Add('onUpdateToNull', onUpdateToNull);

  onUpdateToNull.Int32NullIfZero := 0;
  onUpdateToNull.DateTimeNullIfZero := 0;
  onUpdateToNull.StrNullIfEmpty := '';

  try
    FTestDal.DbContext.BeginTransaction;
    FTestDal.Update(onUpdateToNull);
    FTestDal.DbContext.CommitTransaction;
    testResult.Pass := tpsPass;
  except on Ex: Exception do
    begin
      FTestDal.DbContext.RollbackTransaction;
      StopTests := True;
      testResult.Pass := tpsFail;
      testResult.Message := ex.Message;
    end;
  end;

  Result := testResult;

end;

function TDBTests.must_null_fields_be_three: TTestResult;
var
  onUpdateToNull: TTestEntity;
  testResult: TTestResult;
begin
  onUpdateToNull := (ObjectsBag.Find('onUpdateToNull') as TTestEntity);

  if onUpdateToNull.NullFields.Count = 3 then
    testResult.Pass := tpsPass
  else
    testResult.Pass := tpsFail;

  Result := testResult;
end;

function TDBTests.must_retrieve_updated_fields_as_null: TTestResult;
var
  afterUpdate, retrieveUpdateToNull: TTestEntity;
  testResult: TTestResult;
begin
  afterUpdate := (ObjectsBag.Find('afterUpdate') as TTestEntity);
  retrieveUpdateToNull := FTestDal.FindByPK(afterUpdate.Id);
  ObjectsBag.Add('retrieveUpdateToNull', retrieveUpdateToNull);
  if
    (retrieveUpdateToNull.NullFields.IndexOf('Int32NullIfZero') >  -1) and
    (retrieveUpdateToNull.NullFields.IndexOf('DateTimeNullIfZero') >  -1) and
    (retrieveUpdateToNull.NullFields.IndexOf('StrNullIfEmpty') >  -1)
  then
    testResult.Pass := tpsPass
  else
    testResult.Pass := tpsFail;

  Result := testResult;
end;

function TDBTests.must_log_updated_fiels_as_null: TTestResult;
var
  afterUpdate, onUpdateToNull: TTestEntity;
  testResult: TTestResult;
  q: TSQLQuery;

  procedure TestField(NomeColuna: string; OldValue: Variant; var aTestResult: TTestResult);
  var
    s: string;
  begin
    q := gAppDbContext.CreateSQLQuery;
    s := 'select count(1) from test_log where id_pk = :id_pk and operacao = ''U'' ' +
                'and nome_coluna = :nome_coluna ' +
                'and valor_anterior = :valor_anterior ' +
                'and valor_novo is null';

    q.SQL.Text := s;

    q.ParamByName('id_pk').Value := afterUpdate.Id;

    q.ParamByName('nome_coluna').Value := NomeColuna;

    q.ParamByName('valor_anterior').Value := OldValue;

    q.Open;

    IsEquals(q.Fields[0].AsInteger, 1, aTestResult);
    q.Free;
  end;

begin
  afterUpdate := (ObjectsBag.Find('afterUpdate') as TTestEntity);

  TestField('INT_32_NULL_IF_ZERO', IntToStr(afterUpdate.Int32NullIfZero), testResult);
  if testResult.Pass = tpsPass then
    TestField('DATE_TIME_NULL_IF_ZERO', FormatDateTime('DD/MM/YYYY hh:nn:ss', afterUpdate.DateTimeNullIfZero), testResult);
  if testResult.Pass = tpsPass then
    TestField('STR_NULL_IF_EMPTY', afterUpdate.StrNullIfEmpty, testResult);

  Result := testResult;
end;

function TDBTests.must_raise_EMaxLengthExceded: TTestResult;
var
  temp: TTestEntity;
  testResult: TTestResult;
begin
  if DontRunTestsWithExceptionsBased then
  begin
    testResult.Pass := tpsNotExecuted;
    Result := testResult;
    Exit;
  end;

  temp := TTestEntity.Create;
  temp.Id := FTestDal.GetNextSequence;
  temp.Str := DupeString('A', 70);
  try
    FTestDal.DbContext.BeginTransaction;
    FTestDal.Insert(temp);
    FTestDal.DbContext.CommitTransaction;
    // se executar sem exception quer dizer que falhou
    testResult.Pass := tpsFail;
  except
    on Ex: EMaxLengthExceded do
    begin
      testResult.Pass := tpsPass;
      testResult.Message := ex.ClassName + ' - ' + ex.Message;
    end;

    on Ex: Exception do
    begin
      testResult.Pass := tpsFail;
      testResult.Message := ex.Message;
    end;
  end;
  temp.Free;
  Result := testResult;
end;

function TDBTests.must_rollback_objects_of_inserts: TTestResult;
var
  temp1, temp2: TTestEntity;
  testResult: TTestResult;
begin
  temp1 := TTestEntity.Create;
  temp1.Id := FTestDAL.GetNextSequence;
  temp1.Situacao := 'A';

  temp2 := TTestEntity.Create;
  temp2.Id := FTestDAL.GetNextSequence;
  temp2.Situacao := 'A';

  FTestDal.DbContext.BeginTransaction;
  FTestDal.Insert(temp1);
  FTestDal.Insert(temp2);
  FTestDal.DbContext.RollbackTransaction;

  if (temp1.NroRevisao = 0) and (temp1.OldVersion = nil) then
    testResult.Pass  := tpsPass;

  if testResult.Pass = tpsPass then
    if (temp2.NroRevisao = 0) and (temp2.OldVersion = nil) then
      testResult.Pass  := tpsPass;

  temp1.Free;
  temp2.Free;

  Result := testResult;

end;

function TDBTests.must_rollback_objects_of_updates: TTestResult;
var
  temp1, temp2: TTestEntity;
  testResult: TTestResult;
begin
  temp1 := TTestEntity.Create;
  temp1.Id := FTestDAL.GetNextSequence;
  temp1.Situacao := 'A';

  temp2 := TTestEntity.Create;
  temp2.Id := FTestDAL.GetNextSequence;
  temp2.Situacao := 'A';

  FTestDal.DbContext.BeginTransaction;
  FTestDal.Insert(temp1);
  FTestDal.Insert(temp2);
  FTestDal.DbContext.CommitTransaction;

  FTestDal.DbContext.BeginTransaction;
  FTestDal.Update(temp1);
  FTestDal.DbContext.CommitTransaction;

  FTestDal.DbContext.BeginTransaction;
  FTestDal.Update(temp1);
  FTestDal.Update(temp2);
  FTestDal.DbContext.RollbackTransaction;

  if (temp1.NroRevisao = 2) and (temp1.OldVersion.NroRevisao = 2) then
    testResult.Pass  := tpsPass;

  if testResult.Pass = tpsPass then
    if (temp2.NroRevisao = 1) and (temp2.OldVersion.NroRevisao = 1) then
      testResult.Pass  := tpsPass;

  temp1.Free;
  temp2.Free;

  Result := testResult;

end;


constructor TDBTests.Create(InitialTestNumber: Integer);
begin
  inherited Create(InitialTestNumber);
  FTestDal := TTestDAL.Create(gAppDbContext);
end;

destructor TDBTests.Destroy;
begin
  FTestDal.Free;
  inherited Destroy;
end;

procedure TDBTests.RegisterTests;
begin
  AddTestItem(@must_get_the_right_mapping, 'Deve obter o mapeamento de entidade correto');
  AddTestItem(@must_get_sequence, 'Deve obter o próximo número da sequence');
  AddTestItem(@must_raise_EDBContextTransactionIsNotOpen_for_insert, 'Deve ter o DBContext uma transação aberta para realizar inserts');
  AddTestItem(@must_perform_insert, 'Deve executar a inserção de registro');
  AddTestItem(@must_update_null_fields_prop, 'Deve alimentar em NullFields os campos inseridos como Null');
  AddTestItem(@must_retrieve_insert, 'Deve recuperar o registro inserido');
  AddTestItem(@must_retrieve_equals_inserted, 'Deve recuperar os mesmos valores inseridos');
  AddTestItem(@must_be_null_retrivied_specific_fields, 'Devem ser nulos campos específicos recuperados');
  AddTestItem(@must_be_1_first_revision, 'Deve ser 1 o número da primeira revisão');
  AddTestItem(@must_insert_log_insert, 'Deve inserir o log de inserção');
  AddTestItem(@must_raise_EDBContextTransactionIsNotOpen_for_update, 'Deve ter o DBContext uma transação aberta para realizar updates');
  AddTestItem(@must_perform_update, 'Deve executar a operação de update de registro');
  AddTestItem(@must_null_fields_be_zero, 'Deve ser 0 o número de campos nulos');
  AddTestItem(@must_retrieve_equals_updated, 'Deve recuperar o registro como atualizado (mesmos valores)');
  AddTestItem(@must_be_revision_2, 'Deve set 2 o número da revisão');
  AddTestItem(@must_insert_log_update, 'Deve inserir o log de atualização');
  AddTestItem(@must_update_fiels_to_null, 'Deve atualizar os valores nuláveis para Null');
  AddTestItem(@must_null_fields_be_three, 'Deve ser 3 o número de campos nulos');
  AddTestItem(@must_retrieve_updated_fields_as_null, 'Deve recuperar os valores atualizados para Null como Null');
  AddTestItem(@must_log_updated_fiels_as_null, 'Deve inserir no log de atualização as alterações de nuláveis');
  AddTestItem(@must_raise_EMaxLengthExceded, 'Deve levantar a exception EMaxLengthExceded');
  AddTestItem(@must_rollback_objects_of_inserts, 'Deve fazer Rollback dos objetos dos inserts');
  AddTestItem(@must_rollback_objects_of_updates, 'Deve fazer Rollback dos objetos dos updates');
end;

end.

