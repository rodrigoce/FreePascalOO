unit db_tests;

{$mode ObjFPC}{$H+}

interface

uses
  Dialogs, SysUtils,
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
    // testar se a revisão é = 1
    // testar se inseriou o log de inserção
    // testar update
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
  FTestEntityInsert.Id := FTestDal.GetNextSequence;
  FTestEntityInsert.Situacao := 'A';
  FTestEntityInsert.Int32 := 2123456789;
  FTestEntityInsert.Int32NullIfZero := 0;
  FTestEntityInsert.DateTime := Now;
  FTestEntityInsert.DateTimeNullIfZero := 0;
  FTestEntityInsert.Str := 'STR';
  FTestEntityInsert.StrNullIfEmpty := '';
  FTestEntityInsert.Decimal := 2123456789.1234567;
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
    (FTestEntityInsert.Decimal = FTestEntityRetrieve.Decimal)
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
end;

end.

