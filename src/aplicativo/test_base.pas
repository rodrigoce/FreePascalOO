unit test_base;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Controls, Math, Contnrs,
  LCLIntf, Generics.Collections;

type

  {
  TIPOS DE TESTE
    1. End-To-End (e2e) - Testa a funcionalidade como se fosse a ator do caso de
       uso (pessoa, sistema, ...);
    2. Testes de Integração - Testa a funcionalidade mesmo que essa chama outra
       funcionalidade, incluvise chama banco de dados e qualquer outra camada;
    3. Teste Unitário - testa uma procedure ou function. Não deve ter
       dependências como banco de dados. Utiliza-se de mock ou fake de suas
       dependências forçando o código ser baixamente acoplado classes reais.
  }


  TTestPassStatus = (tpsNotExecuted, tpsFail, tpsPass);

  TTestResult = record
    Pass: TTestPassStatus;
    Message: string;
  end;

  TTestMethodDelegate = function: TTestResult of object;
  TTestItemAfterExecute = procedure(const TestNumber: Integer; const TestResult: TTestResult) of object;

  { TTestItem }

  TTestItem = class
  private
    FTestMethod: TTestMethodDelegate;
    FTestNumber: Integer;
    FTestResult: TTestResult;
    FTitle: string;
  public
    property TestNumber: Integer read FTestNumber write FTestNumber;
    property TestMethod: TTestMethodDelegate read FTestMethod write FTestMethod;
    property Title: string read FTitle write FTitle;
    property TestResult: TTestResult read FTestResult write FTestResult;
  end;

  { TTestsBase }

  TTestsBase = class
  private
    FDontRunTestsWithExceptionsBased: Boolean;
    FObjectsBag: TFPHashObjectList;
    FInitialTestNumber: Integer;
    FStopTests: Boolean;
    FTestItemAfterExecute: TTestItemAfterExecute;
    procedure ClearObjsBag;
  protected
    FTestItemList: specialize TList<TTestItem>;
    procedure AddTestItem(ATestMethod: TTestMethodDelegate; ATitle: string);

    procedure IsGreaterThan(Value, Reference: Integer; var TestResult: TTestResult);
    procedure IsEquals(Value1, Value2: string; var TestResult: TTestResult); overload;
    procedure IsEquals(Value1, Value2: Integer; var TestResult: TTestResult); overload;
    procedure IsEquals(Value1, Value2: Double; var TestResult: TTestResult); overload;
  public
    constructor Create(InitialTestNumber: Integer);
    destructor Destroy; override;

    procedure RegisterTests; virtual; abstract;
    procedure Execute(ADontRunTestsWithExceptionsBased: Boolean);
    function GetTestList: specialize TList<TTestItem>;
    property TestItemAfterExecute: TTestItemAfterExecute read FTestItemAfterExecute write FTestItemAfterExecute;
    property StopTests: Boolean read FStopTests write FStopTests;
    // após a execução dos testes os objetos dessa lista serão liberados da memória (.Free)
    property ObjectsBag: TFPHashObjectList read FObjectsBag write FObjectsBag;
    property DontRunTestsWithExceptionsBased: Boolean read FDontRunTestsWithExceptionsBased write FDontRunTestsWithExceptionsBased;
  end;

implementation

{ TTestsBase }

procedure TTestsBase.ClearObjsBag;
var
  i: Integer;
begin
  for i := 0 to ObjectsBag.Count -1 do
  begin
    try
      ObjectsBag.Items[i].Free;
    except
    end;
  end;
  ObjectsBag.Clear;
end;

procedure TTestsBase.AddTestItem(ATestMethod: TTestMethodDelegate; ATitle: string);
var
  item: TTestItem;
begin
  item := TTestItem.Create;
  item.TestNumber := FTestItemList.Count + 1 + FInitialTestNumber;
  item.TestMethod := ATestMethod;
  item.Title := ATitle;
  FTestItemList.Add(item);
end;

procedure TTestsBase.IsGreaterThan(Value, Reference: Integer;
  var TestResult: TTestResult);
begin
  if Value > Reference then
    TestResult.Pass := tpsPass
  else
    TestResult.Pass := tpsFail
end;

procedure TTestsBase.IsEquals(Value1, Value2: string;
  var TestResult: TTestResult);
begin
  if Value1 = Value2 then
    TestResult.Pass := tpsPass
  else
    TestResult.Pass := tpsFail
end;

procedure TTestsBase.IsEquals(Value1, Value2: Integer;
  var TestResult: TTestResult);
begin
  if Value1 = Value2 then
    TestResult.Pass := tpsPass
  else
    TestResult.Pass := tpsFail
end;

procedure TTestsBase.IsEquals(Value1, Value2: Double;
  var TestResult: TTestResult);
begin
  if SameValue(Value1, Value2) then
    TestResult.Pass := tpsPass
  else
    TestResult.Pass := tpsFail
end;

constructor TTestsBase.Create(InitialTestNumber: Integer);
begin
  FInitialTestNumber := InitialTestNumber;
  FTestItemList := specialize TList<TTestItem>.Create;
  FObjectsBag := TFPHashObjectList.Create(False);
end;

destructor TTestsBase.Destroy;
var
  item: TTestItem;
begin
  for item in FTestItemList do
  begin
    item.Free;
  end;

  FObjectsBag.Free;

  inherited;
end;

procedure TTestsBase.Execute(ADontRunTestsWithExceptionsBased: Boolean);
var
  item: TTestItem;
  testResult: TTestResult;
begin
  DontRunTestsWithExceptionsBased := ADontRunTestsWithExceptionsBased;
  StopTests := False;
  for item in FTestItemList do
  begin
    if StopTests then Break;
    try
      testResult := item.TestMethod();
    except
      on ex: Exception do
      begin
        testResult.Pass := tpsFail;
        testResult.Message := ex.Message;
      end;
    end;
    item.TestResult := testResult;
    try
      if TestItemAfterExecute <> nil then
        TestItemAfterExecute(item.TestNumber, item.TestResult);
    except
    end;
  end;
  ClearObjsBag;
end;

function TTestsBase.GetTestList: specialize TList<TTestItem>;
begin
  Result := FTestItemList;
end;



end.

