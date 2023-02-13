unit db_tests;

{$mode ObjFPC}{$H+}

interface

uses
  Dialogs,
  test_base, test_dal, test_entity, db_context, mini_orm;

{ TDBTests }

type

  TDBTests = class(TTestsBase)
  private
    FTestDal: TTestDal;
    function must_get_sequence: TTestResult;
    function must_get_the_right_mapping: TTestResult;
  public
    constructor Create;
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
  IsEquals(TTestEntity.ClassName, ormEntity.ClassName, testResult);
  Result := testResult;
end;

constructor TDBTests.Create;
begin
  inherited Create;
  FTestDal := TTestDAL.Create(gAppDbContext);
end;

destructor TDBTests.Destroy;
begin
  FTestDal.Free;
  inherited Destroy;
end;

procedure TDBTests.RegisterTests;
begin
  AddTestItem(@must_get_sequence, 'Deve obter o próximo número da sequence.');
end;

end.

