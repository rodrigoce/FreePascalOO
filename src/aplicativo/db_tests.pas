unit db_tests;

{$mode ObjFPC}{$H+}

interface

uses
  Dialogs, SysUtils, Math, SQLDB,
  test_base, test_dal, test_entity, db_context, mini_orm;

{ TDBTests }

type

  TDBTests = class(TTestsBase)
  private
    FTestDal: TTestDal;
    FTestEntityInsert: TTestEntity;
    FTestEntityRetrieve: TTestEntity;
    function must_get_sequence: TTestResult;
    function must_get_the_right_mapping: TTestResult;
    function must_perform_insert: TTestResult;
    function must_retrieve_insert: TTestResult;
    function must_retrieve_equals_inserted: TTestResult;
    function must_be_null_retrivied_specific_fields: TTestResult;
    function must_be_1_first_revision: TTestResult;
    function must_insert_log_insert: TTestResult;
    function must_perform_update_and_retrieve_equals_updated: TTestResult;
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

function TDBTests.must_perform_insert: TTestResult;
var
  testResult: TTestResult;
begin
  Randomize;

  FTestEntityInsert.Id := FTestDal.GetNextSequence;
  FTestEntityInsert.Situacao := 'A';
  FTestEntityInsert.Int32 := Random(MaxInt);
  FTestEntityInsert.Int32NullIfZero := 0;
  FTestEntityInsert.DateTime := Now;
  FTestEntityInsert.DateTimeNullIfZero := 0;
  FTestEntityInsert.Str := 'STR';
  FTestEntityInsert.StrNullIfEmpty := '';
  FTestEntityInsert.Decimal := RoundTo(StrToFloat(IntToStr(Random(MaxInt)) + ',' + IntToStr(Random(MaxInt))), -7);
  try
    FTestDal.DbContext.BeginTransaction;
    FTestDal.Insert(FTestEntityInsert);
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

function TDBTests.must_retrieve_insert: TTestResult;
var
  testResult: TTestResult;
begin
  FTestEntityRetrieve := FTestDal.FindByPK(FTestEntityInsert.Id);
  if FTestEntityRetrieve = nil then
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
  testResult: TTestResult;
begin
  if
    (FTestEntityInsert.Id = FTestEntityRetrieve.Id) and
    (FTestEntityInsert.Situacao = FTestEntityRetrieve.Situacao) and
    (FTestEntityInsert.Int32 = FTestEntityRetrieve.Int32) and
    (FTestEntityInsert.Int32NullIfZero = FTestEntityRetrieve.Int32NullIfZero) and
    (FTestEntityInsert.DateTime = FTestEntityRetrieve.DateTime) and
    (FTestEntityInsert.DateTimeNullIfZero = FTestEntityRetrieve.DateTimeNullIfZero) and
    (FTestEntityInsert.Str = FTestEntityRetrieve.Str) and
    (FTestEntityInsert.StrNullIfEmpty = FTestEntityRetrieve.StrNullIfEmpty) and
    (SameValue(FTestEntityInsert.Decimal, FTestEntityRetrieve.Decimal))
  then
    testResult.Pass := tpsPass
  else
    testResult.Pass := tpsFail;

  Result := testResult;
end;

function TDBTests.must_be_null_retrivied_specific_fields: TTestResult;
var
  testResult: TTestResult;
begin
  if
    (FTestEntityRetrieve.NullFields.IndexOf('Int32NullIfZero') >  -1) and
    (FTestEntityRetrieve.NullFields.IndexOf('DateTimeNullIfZero') >  -1) and
    (FTestEntityRetrieve.NullFields.IndexOf('StrNullIfEmpty') >  -1)
  then
    testResult.Pass := tpsPass
  else
    testResult.Pass := tpsFail;

  Result := testResult;
end;

function TDBTests.must_be_1_first_revision: TTestResult;
var
  testResult: TTestResult;
begin
  IsEquals(FTestEntityInsert.NroRevisao, 1, testResult);
  Result := testResult;
end;

function TDBTests.must_insert_log_insert: TTestResult;
var
  testResult: TTestResult;
  q: TSQLQuery;
begin
  q := gAppDbContext.CreateSQLQuery;
  q.SQL.Text := 'select count(1) from test_log where id_pk = :id_pk and operacao = ''I''';
  q.Params[0].Value := FTestEntityInsert.Id;
  q.Open;

  IsEquals(q.Fields[0].AsInteger, 1, testResult);
  q.Free;

  Result := testResult;
end;

function TDBTests.must_perform_update_and_retrieve_equals_updated: TTestResult;
var
  testResult: TTestResult;
  onInsert, onUpdate, afterUpate: TTestEntity;
begin
  // aqui eu já confio na inserção pois ela já está testada
  onInsert := TTestEntity.Create;
  onInsert.Id := FTestDal.GetNextSequence;
  onInsert.Situacao := 'A';
  onInsert.Int32 := 1;
  onInsert.Int32NullIfZero := 0;
  onInsert.DateTime := EncodeDate(2023, 02, 23) + EncodeTime(13, 13, 13, 0);
  onInsert.DateTimeNullIfZero := 0;
  onInsert.Str := 'STR';
  onInsert.StrNullIfEmpty := '';
  onInsert.Decimal := 1.1111111;
  FTestDal.Insert(onInsert);

  // aqui eu já confio na recuperação pois ela já esta testada
  onUpdate := FTestDal.FindByPK(onInsert.Id);

  onUpdate.Situacao := 'E';
  onUpdate.Int32 := 2;
  onUpdate.Int32NullIfZero := 1;
  onUpdate.DateTime := EncodeDate(2024, 02, 23) + EncodeTime(14, 14, 14, 0);
  onUpdate.DateTimeNullIfZero := EncodeDate(2024, 02, 23) + EncodeTime(14, 14, 14, 0);
  onUpdate.Str := 'ABC';
  onUpdate.StrNullIfEmpty := 'NOT NULL NOW';
  onUpdate.Decimal := 2.22222222;

  try
    FTestDal.DbContext.BeginTransaction;
    FTestDal.Update(onUpdate);
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

  if not (testResult.Pass = tpsPass) then Exit;

  // o teste do update em sí
  afterUpate := FTestDal.FindByPK(onInsert.Id);

  //agora comparar tudo
  if
    (onUpdate.Id = afterUpate.Id) and
    (onUpdate.Situacao = afterUpate.Situacao) and
    (onUpdate.Int32 = afterUpate.Int32) and
    (onUpdate.Int32NullIfZero = afterUpate.Int32NullIfZero) and
    (onUpdate.DateTime = afterUpate.DateTime) and
    (onUpdate.DateTimeNullIfZero = afterUpate.DateTimeNullIfZero) and
    (onUpdate.Str = afterUpate.Str) and
    (onUpdate.StrNullIfEmpty = afterUpate.StrNullIfEmpty) and
    (SameValue(FTestEntityInsert.Decimal, afterUpate.Decimal))
  then
    testResult.Pass := tpsPass
  else
    testResult.Pass := tpsFail;

  Result := testResult;

end;

constructor TDBTests.Create(InitialTestNumber: Integer);
begin
  inherited Create(InitialTestNumber);
  FTestDal := TTestDAL.Create(gAppDbContext);
  FTestEntityInsert := TTestEntity.Create;
end;

destructor TDBTests.Destroy;
begin
  FTestDal.Free;
  FTestEntityInsert.Free;
  FTestEntityRetrieve.Free;
  inherited Destroy;
end;

procedure TDBTests.RegisterTests;
begin
  AddTestItem(@must_get_the_right_mapping, 'Deve obter o mapeamento de entidade correto');
  AddTestItem(@must_get_sequence, 'Deve obter o próximo número da sequence');
  AddTestItem(@must_perform_insert, 'Deve executar a inserção de registro');
  AddTestItem(@must_retrieve_insert, 'Deve recuperar o registro inserido');
  AddTestItem(@must_retrieve_equals_inserted, 'Deve recuperar os mesmos valores inseridos');
  AddTestItem(@must_be_null_retrivied_specific_fields, 'Devem ser nulos campos específicos recuperados');
  AddTestItem(@must_be_1_first_revision, 'Deve ser 1 o número da primeira revisão');
  AddTestItem(@must_insert_log_insert, 'Deve inserir o log de inserção');
  AddTestItem(@must_perform_update_and_retrieve_equals_updated, 'Deve executar a operação de update e recuperar os dados exatametne como atualizado');
end;

end.

